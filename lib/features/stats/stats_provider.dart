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

  /// Para gráfico de barras (futuro): 0..14 días desde hoy -> cantidad de repasos programados
  final Map<int, int> futureReviews;

  /// Para mapa de calor (pasado): fecha (normalizada a día) -> cantidad de repasos
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

final deckStatsProvider =
FutureProvider.family.autoDispose<DeckStatsData, String>((ref, packName) async {
  final isar = await ref.watch(isarDbProvider.future);

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
  // 2) FORECAST (0..14 días)
  //    Solo cartas NO nuevas
  // =========================
  final Map<int, int> forecast = {for (int i = 0; i <= 14; i++) i: 0};

  final forecastEnd =
  startOfStudyDay.add(const Duration(days: 15)); // hoy..hoy+14 (15 excl.)

  final upcomingCards = await isar.flashcards
      .filter()
      .packNameEqualTo(packName)
      .not()
      .stateEqualTo(CardState.newCard)
      .and()
      .nextReviewBetween(
    startOfStudyDay,
    forecastEnd,
    includeLower: true,
    includeUpper: false,
  )
      .findAll();

  for (final card in upcomingCards) {
    final d = card.nextReview;
    final dateOnly = StudyDay.label(d, settings);
    final diff = dateOnly.difference(labelToday).inDays;

    if (diff >= 0 && diff <= 14) {
      forecast[diff] = (forecast[diff] ?? 0) + 1;
    }
  }

  // =========================
  // 3) HEATMAP (últimos 60 días)
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
    final t = log.timestamp;
    final dateKey = StudyDay.label(t, settings);
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
});