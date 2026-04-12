import 'dart:async';

import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/deck_daily_stats.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/models/review_log.dart';
import 'package:flashcards_app/data/models/study_session.dart';
import 'package:flashcards_app/data/models/study_session_history.dart';
import 'package:flashcards_app/data/utils/study_day.dart';
import 'package:flashcards_app/features/importer/media_asset_cleanup.dart';
part 'deck_provider.g.dart';

class DeckSummary {
  final String packName;
  final String? iconUri;
  final int newCardsDue;
  final int learningDueToday;
  final int reviewCardsDueToday;
  final int overdueCards;
  final double accuracy7d;
  final int reviewCount7d;
  DeckSummary({
    required this.packName,
    required this.iconUri,
    required this.newCardsDue,
    required this.learningDueToday,
    required this.reviewCardsDueToday,
    required this.overdueCards,
    required this.accuracy7d,
    required this.reviewCount7d,
  });
  String get name => packName;
}

@Riverpod(keepAlive: true)
Stream<List<DeckSummary>> decksStream(DecksStreamRef ref) async* {
  final isar = await ref.watch(isarDbProvider.future);

  Future<List<DeckSummary>> compute() async {
    final now = DateTime.now();
    final decks = await isar.deckSettings.where().findAll();
    final summaries = <DeckSummary>[];

    for (final s in decks) {
      // Keep this read-only: writing here can race with deletions and recreate rows.
      final currentLabel = StudyDay.label(now, s);
      final currentStudyStart = StudyDay.start(now, s);
      final nextStudyStart = currentStudyStart.add(const Duration(days: 1));
      final last = s.lastNewCardStudyDate;
      final lastLabel = last == null ? null : StudyDay.label(last, s);
      final bool sameStudyDay =
          lastLabel != null &&
          lastLabel.year == currentLabel.year &&
          lastLabel.month == currentLabel.month &&
          lastLabel.day == currentLabel.day;
      final effectiveNewCardsSeenToday = sameStudyDay ? s.newCardsSeenToday : 0;

      // Blue: new cards allowed by today's quota.
      final remainingQuota = (s.newCardsPerDay - effectiveNewCardsSeenToday)
          .clamp(0, 999999);

      final newCount = remainingQuota > 0
          ? await isar.flashcards
                .filter()
                .packNameEqualTo(s.packName)
                .stateEqualTo(CardState.newCard)
                .limit(remainingQuota)
                .count()
          : 0;

      final overdueCards = await isar.flashcards
          .filter()
          .packNameEqualTo(s.packName)
          .not()
          .stateEqualTo(CardState.newCard)
          .and()
          .nextReviewLessThan(currentStudyStart)
          .count();

      final learningDueToday = await isar.flashcards
          .filter()
          .packNameEqualTo(s.packName)
          .stateEqualTo(CardState.learning)
          .and()
          .nextReviewGreaterThan(currentStudyStart, include: true)
          .and()
          .nextReviewLessThan(nextStudyStart)
          .count();
      final relearningDueToday = await isar.flashcards
          .filter()
          .packNameEqualTo(s.packName)
          .stateEqualTo(CardState.relearning)
          .and()
          .nextReviewGreaterThan(currentStudyStart, include: true)
          .and()
          .nextReviewLessThan(nextStudyStart)
          .count();
      final reviewDueToday = await isar.flashcards
          .filter()
          .packNameEqualTo(s.packName)
          .stateEqualTo(CardState.review)
          .and()
          .nextReviewGreaterThan(currentStudyStart, include: true)
          .and()
          .nextReviewLessThan(nextStudyStart)
          .count();

      final recentDailyStats = await isar.deckDailyStats
          .filter()
          .packNameEqualTo(s.packName)
          .studyDayBetween(
            currentLabel.subtract(const Duration(days: 6)),
            currentLabel,
            includeLower: true,
            includeUpper: true,
          )
          .findAll();
      final reviewCount7d = recentDailyStats.fold<int>(
        0,
        (sum, day) => sum + day.reviewCount,
      );
      final correct7d = recentDailyStats.fold<int>(
        0,
        (sum, day) => sum + day.correctCount,
      );
      final accuracy7d = reviewCount7d == 0 ? 0.0 : correct7d / reviewCount7d;
      summaries.add(
        DeckSummary(
          packName: s.packName,
          iconUri: s.deckIconUri,
          newCardsDue: newCount,
          learningDueToday: learningDueToday + relearningDueToday,
          reviewCardsDueToday: reviewDueToday,
          overdueCards: overdueCards,
          accuracy7d: accuracy7d,
          reviewCount7d: reviewCount7d,
        ),
      );
    }

    return summaries;
  }

  yield await compute();
  final controller = StreamController<void>(sync: true);
  final sub1 = isar.flashcards.watchLazy().listen((_) {
    if (!controller.isClosed) controller.add(null);
  });
  final sub2 = isar.deckSettings.watchLazy().listen((_) {
    if (!controller.isClosed) controller.add(null);
  });

  ref.onDispose(() async {
    await sub1.cancel();
    await sub2.cancel();
    await controller.close();
  });

  await for (final _ in controller.stream) {
    yield await compute();
  }
}

@Riverpod(keepAlive: true)
Future<void> deleteDeck(DeleteDeckRef ref, String packName) async {
  final isar = await ref.watch(isarDbProvider.future);
  final normalizedPackName = packName.trim();
  if (normalizedPackName.isEmpty) return;

  await isar.writeTxn(() async {
    await isar.flashcards
        .filter()
        .packNameEqualTo(normalizedPackName)
        .deleteAll();
    await isar.reviewLogs
        .filter()
        .packNameEqualTo(normalizedPackName)
        .deleteAll();
    await isar.deckSettings
        .filter()
        .packNameEqualTo(normalizedPackName)
        .deleteAll();
    await isar.studySessions
        .filter()
        .packNameEqualTo(normalizedPackName)
        .deleteAll();
    await isar.studySessionHistorys
        .filter()
        .packNameEqualTo(normalizedPackName)
        .deleteAll();
    await isar.deckDailyStats
        .filter()
        .packNameEqualTo(normalizedPackName)
        .deleteAll();
  });
  await purgeOrphanedMediaAssets(isar);
}

@Riverpod(keepAlive: true)
Future<void> renameDeck(
  RenameDeckRef ref,
  String oldPackName,
  String newPackName,
) async {
  final isar = await ref.watch(isarDbProvider.future);

  final oldName = oldPackName.trim();
  final newName = newPackName.trim();

  if (oldName.isEmpty) {
    throw ArgumentError('El nombre actual del mazo es invalido.');
  }
  if (newName.isEmpty) {
    throw ArgumentError('El nuevo nombre no puede estar vacio.');
  }
  if (oldName == newName) return;

  // Evitar colisiones
  final existingSettings = await isar.deckSettings
      .filter()
      .packNameEqualTo(newName)
      .findFirst();
  if (existingSettings != null) {
    throw StateError("Ya existe un mazo con el nombre '$newName'.");
  }

  final existingGhost = await isar.flashcards
      .filter()
      .packNameEqualTo(newName)
      .limit(1)
      .count();
  if (existingGhost > 0) {
    throw StateError(
      "Ya existen tarjetas con el packName '$newName'. "
      'Elige otro nombre o elimina ese mazo primero.',
    );
  }

  await isar.writeTxn(() async {
    final settings = await isar.deckSettings
        .filter()
        .packNameEqualTo(oldName)
        .findFirst();

    if (settings == null) {
      throw StateError("No se encontro el mazo '$oldName'.");
    }

    // 1) DeckSettings
    settings.packName = newName;
    await isar.deckSettings.put(settings);

    // 2) Flashcards
    final cards = await isar.flashcards
        .filter()
        .packNameEqualTo(oldName)
        .findAll();
    for (final c in cards) {
      c.packName = newName;
    }
    if (cards.isNotEmpty) {
      await isar.flashcards.putAll(cards);
    }

    // 3) ReviewLogs
    final logs = await isar.reviewLogs
        .filter()
        .packNameEqualTo(oldName)
        .findAll();
    for (final l in logs) {
      l.packName = newName;
    }
    if (logs.isNotEmpty) {
      await isar.reviewLogs.putAll(logs);
    }

    // 4) StudySession
    final session = await isar.studySessions
        .filter()
        .packNameEqualTo(oldName)
        .findFirst();
    if (session != null) {
      session.packName = newName;
      await isar.studySessions.put(session);
    }

    final histories = await isar.studySessionHistorys
        .filter()
        .packNameEqualTo(oldName)
        .findAll();
    for (final history in histories) {
      history.packName = newName;
    }
    if (histories.isNotEmpty) {
      await isar.studySessionHistorys.putAll(histories);
    }

    final dailyStats = await isar.deckDailyStats
        .filter()
        .packNameEqualTo(oldName)
        .findAll();
    for (final day in dailyStats) {
      day.packName = newName;
      day.packDayKey = '$newName${day.packDayKey.substring(oldName.length)}';
    }
    if (dailyStats.isNotEmpty) {
      await isar.deckDailyStats.putAll(dailyStats);
    }
  });
}
