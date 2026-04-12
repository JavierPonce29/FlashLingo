import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flashcards_app/data/local/deck_daily_stats_sync.dart';
import 'package:flashcards_app/data/models/app_meta.dart';
import 'package:flashcards_app/data/models/deck_daily_stats.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/models/review_log.dart';
import 'package:flashcards_app/data/models/study_session.dart';
import 'package:flashcards_app/data/models/study_session_history.dart';
import 'package:flashcards_app/data/utils/study_day.dart';
part 'isar_provider.g.dart';

const _lifetimeBackfillMigrationKey = 'migration:lifetime_backfill:v1';
const _deckDailyStatsMigrationKey = 'migration:deck_daily_stats:v2';

class _LifetimeBackfillStats {
  int reviews = 0;
  int correct = 0;
  int wrong = 0;
}

Future<bool> _hasCompletedMigration(Isar isar, String key) async {
  final meta = await isar.appMetas.filter().keyEqualTo(key).findFirst();
  return meta != null;
}

Future<void> _markMigrationComplete(Isar isar, String key) async {
  await isar.writeTxn(() async {
    await isar.appMetas.putByIndex(
      'key',
      AppMeta()
        ..key = key
        ..updatedAt = DateTime.now(),
    );
  });
}

Future<bool> _needsDeckDailyStatsRebuild(Isar isar) async {
  final reviewCount = await isar.reviewLogs.count();
  final sessionCount = await isar.studySessionHistorys.count();
  if (reviewCount == 0 && sessionCount == 0) {
    return false;
  }

  final rows = await isar.deckDailyStats.where().findAll();
  if (rows.isEmpty) {
    return true;
  }

  for (final row in rows) {
    if (row.reviewCount > 0 &&
        row.newReviewCount + row.learningReviewCount + row.reviewStateCount <
            row.reviewCount) {
      return true;
    }
    if (row.reviewCount > 0 && row.quarterHourBuckets.length != 96) {
      return true;
    }
  }

  return false;
}

Future<void> _backfillLifetimeStatsIfNeeded(Isar isar) async {
  final cards = await isar.flashcards.where().findAll();
  final logs = await isar.reviewLogs.where().findAll();
  if (cards.isEmpty && logs.isEmpty) return;

  final needsCardBackfill = cards.any(
    (card) =>
        card.lifetimeReviewCount == 0 &&
        card.lifetimeCorrectCount == 0 &&
        card.lifetimeWrongCount == 0,
  );
  final needsLogBackfill = logs.any(
    (log) =>
        log.flashcardId == 0 ||
        log.cardType.isEmpty ||
        log.studyDay.millisecondsSinceEpoch == 0 ||
        log.previousState.isEmpty ||
        log.newState.isEmpty,
  );
  if (!needsCardBackfill && !needsLogBackfill) return;

  final statsByCardKey = <String, _LifetimeBackfillStats>{};
  final cardByLogKey = <String, Flashcard>{};
  for (final card in cards) {
    final key = '${card.packName}::${card.originalId}::${card.cardType}';
    cardByLogKey[key] = card;
  }

  final settingsByPack = <String, DeckSettings>{};
  final settingsList = await isar.deckSettings.where().findAll();
  for (final settings in settingsList) {
    settingsByPack[settings.packName] = settings;
  }

  for (final log in logs) {
    final key = '${log.packName}::${log.cardOriginalId}';
    final stats = statsByCardKey.putIfAbsent(key, _LifetimeBackfillStats.new);
    stats.reviews++;
    if (log.rating >= 3) {
      stats.correct++;
    } else {
      stats.wrong++;
    }
  }

  final updates = <Flashcard>[];
  for (final card in cards) {
    if (card.lifetimeReviewCount != 0 ||
        card.lifetimeCorrectCount != 0 ||
        card.lifetimeWrongCount != 0) {
      continue;
    }
    final key = '${card.packName}::${card.originalId}::${card.cardType}';
    final stats = statsByCardKey[key];
    if (stats == null) continue;
    card.lifetimeReviewCount = stats.reviews;
    card.lifetimeCorrectCount = stats.correct;
    card.lifetimeWrongCount = stats.wrong;
    updates.add(card);
  }

  final updatedLogs = <ReviewLog>[];
  if (needsLogBackfill) {
    for (final log in logs) {
      bool changed = false;
      final key = '${log.packName}::${log.cardOriginalId}';
      final card = cardByLogKey[key];
      if (log.flashcardId == 0 && card != null) {
        log.flashcardId = card.id;
        changed = true;
      }
      if (log.cardType.isEmpty) {
        final parts = log.cardOriginalId.split('::');
        if (parts.isNotEmpty) {
          log.cardType = parts.last;
          changed = true;
        }
      }
      if (log.studyDay.millisecondsSinceEpoch == 0) {
        final settings =
            settingsByPack[log.packName] ??
            (DeckSettings()..packName = log.packName);
        log.studyDay = StudyDay.label(log.timestamp, settings);
        changed = true;
      }
      if (log.previousState.isEmpty) {
        log.previousState = 'unknown';
        changed = true;
      }
      if (log.newState.isEmpty) {
        log.newState = 'unknown';
        changed = true;
      }
      if (!log.isCorrect && log.rating >= 3) {
        log.isCorrect = true;
        changed = true;
      }
      if (log.newNextReview.millisecondsSinceEpoch == 0 &&
          log.scheduledDays > 0 &&
          log.timestamp.millisecondsSinceEpoch != 0) {
        log.newNextReview = log.timestamp.add(
          Duration(days: log.scheduledDays),
        );
        changed = true;
      }
      if (changed) {
        updatedLogs.add(log);
      }
    }
  }

  if (updates.isEmpty && updatedLogs.isEmpty) return;
  await isar.writeTxn(() async {
    if (updates.isNotEmpty) {
      await isar.flashcards.putAll(updates);
    }
    if (updatedLogs.isNotEmpty) {
      await isar.reviewLogs.putAll(updatedLogs);
    }
  });
}

@Riverpod(keepAlive: true)
Future<Isar> isarDb(IsarDbRef ref) async {
  final existing = Isar.getInstance();
  if (existing != null) return existing;
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      AppMetaSchema,
      FlashcardSchema,
      DeckDailyStatsSchema,
      DeckSettingsSchema,
      ReviewLogSchema,
      StudySessionSchema,
      StudySessionHistorySchema,
    ],
    directory: dir.path,
    inspector: kDebugMode,
  );

  if (!await _hasCompletedMigration(isar, _lifetimeBackfillMigrationKey)) {
    await _backfillLifetimeStatsIfNeeded(isar);
    await _markMigrationComplete(isar, _lifetimeBackfillMigrationKey);
  }

  if (!await _hasCompletedMigration(isar, _deckDailyStatsMigrationKey)) {
    if (await _needsDeckDailyStatsRebuild(isar)) {
      await rebuildAllDeckDailyStats(isar);
    }
    await _markMigrationComplete(isar, _deckDailyStatsMigrationKey);
  }

  ref.onDispose(() {
    if (isar.isOpen) {
      isar.close();
    }
  });
  return isar;
}
