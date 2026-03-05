import 'dart:async';

import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/models/review_log.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/utils/study_day.dart';

class DeckStatsData {
  final int totalCards;
  final int newCards;
  final int learningCards;
  final int reviewCards;
  final int relearningCards;
  /// Para grafico de barras (futuro): 0..14 dias desde hoy -> cantidad de repasos programados.
  final Map<int, int> futureReviews;
  /// Para mapa de calor (pasado): fecha (normalizada a dia) -> cantidad de repasos.
  final Map<DateTime, int> heatmapData;
  DeckStatsData({
    required this.totalCards,
    required this.newCards,
    required this.learningCards,
    required this.reviewCards,
    required this.relearningCards,
    required this.futureReviews,
    required this.heatmapData,
  });
}

Future<DeckStatsData> _computeDeckStats(Isar isar, String packName) async {
  final now = DateTime.now();
  final settings = await isar.deckSettings
          .filter()
          .packNameEqualTo(packName)
          .findFirst() ??
      (DeckSettings()..packName = packName);

  final startOfStudyDay = StudyDay.start(now, settings);
  final labelToday = StudyDay.label(now, settings);

  // =========================
  // 1) ESTADO ACTUAL (counts)
  // =========================
  final totalCards = await isar.flashcards
      .filter()
      .packNameEqualTo(packName)
      .count();
  final newCards = await isar.flashcards
      .filter()
      .packNameEqualTo(packName)
      .stateEqualTo(CardState.newCard)
      .count();
  final learningCards = await isar.flashcards
      .filter()
      .packNameEqualTo(packName)
      .stateEqualTo(CardState.learning)
      .count();
  final reviewCards = await isar.flashcards
      .filter()
      .packNameEqualTo(packName)
      .stateEqualTo(CardState.review)
      .count();
  final relearningCards = await isar.flashcards
      .filter()
      .packNameEqualTo(packName)
      .stateEqualTo(CardState.relearning)
      .count();

  // =========================
  // 2) FORECAST (0..14 dias)
  //    Incluye atrasadas en bucket 0 (hoy)
  // =========================
  final Map<int, int> forecast = {for (int i = 0; i <= 14; i++) i: 0};
  final forecastEnd = startOfStudyDay.add(const Duration(days: 15));

  final upcomingCards = await isar.flashcards
      .filter()
      .packNameEqualTo(packName)
      .not()
      .stateEqualTo(CardState.newCard)
      .and()
      .nextReviewBetween(
        DateTime.fromMillisecondsSinceEpoch(0),
        forecastEnd,
        includeLower: true,
        includeUpper: false,
      )
      .findAll();

  for (final card in upcomingCards) {
    final dateOnly = StudyDay.label(card.nextReview, settings);
    int diff = dateOnly.difference(labelToday).inDays;
    if (diff < 0) diff = 0;
    if (diff <= 14) {
      forecast[diff] = (forecast[diff] ?? 0) + 1;
    }
  }

  // =========================
  // 3) HEATMAP (ultimos 60 dias)
  // =========================
  final heatmapStart = startOfStudyDay.subtract(const Duration(days: 60));
  final heatmapEnd = startOfStudyDay.add(const Duration(days: 1));

  final logs = await isar.reviewLogs
      .filter()
      .packNameEqualTo(packName)
      .timestampBetween(
        heatmapStart,
        heatmapEnd,
        includeLower: true,
        includeUpper: false,
      )
      .findAll();

  final Map<DateTime, int> heatmap = {};
  for (final ReviewLog log in logs) {
    final dateKey = StudyDay.label(log.timestamp, settings);
    heatmap[dateKey] = (heatmap[dateKey] ?? 0) + 1;
  }

  return DeckStatsData(
    totalCards: totalCards,
    newCards: newCards,
    learningCards: learningCards,
    reviewCards: reviewCards,
    relearningCards: relearningCards,
    futureReviews: forecast,
    heatmapData: heatmap,
  );
}

final deckStatsProvider =
    StreamProvider.family.autoDispose<DeckStatsData, String>((ref, packName) async* {
  final isar = await ref.watch(isarDbProvider.future);

  Future<DeckStatsData> compute() => _computeDeckStats(isar, packName);

  yield await compute();

  final controller = StreamController<void>(sync: true);
  final sub1 = isar.flashcards.watchLazy().listen((_) {
    if (!controller.isClosed) controller.add(null);
  });
  final sub2 = isar.reviewLogs.watchLazy().listen((_) {
    if (!controller.isClosed) controller.add(null);
  });
  final sub3 = isar.deckSettings.watchLazy().listen((_) {
    if (!controller.isClosed) controller.add(null);
  });

  ref.onDispose(() async {
    await sub1.cancel();
    await sub2.cancel();
    await sub3.cancel();
    await controller.close();
  });

  await for (final _ in controller.stream) {
    yield await compute();
  }
});
