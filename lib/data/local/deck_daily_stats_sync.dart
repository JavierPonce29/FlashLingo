import 'package:isar/isar.dart';

import 'package:flashcards_app/data/models/deck_daily_stats.dart';
import 'package:flashcards_app/data/models/review_log.dart';
import 'package:flashcards_app/data/models/study_session_history.dart';

String deckStudyDayKey(String packName, DateTime studyDay) {
  final month = studyDay.month.toString().padLeft(2, '0');
  final day = studyDay.day.toString().padLeft(2, '0');
  return '$packName::${studyDay.year}-$month-$day';
}

class _DeckDayBucket {
  int reviewCount = 0;
  int correctCount = 0;
  int wrongCount = 0;
  int sessionCount = 0;
  int totalStudyTimeMs = 0;
  int newReviewCount = 0;
  int learningReviewCount = 0;
  int reviewStateCount = 0;
  int newStudyTimeMs = 0;
  int learningStudyTimeMs = 0;
  int reviewStudyTimeMs = 0;
  final Set<String> uniqueCards = <String>{};
  final List<int> quarterHourBuckets = List<int>.filled(96, 0);

  void addLog(ReviewLog log) {
    reviewCount++;
    if (log.isCorrect || log.rating >= 3) {
      correctCount++;
    } else {
      wrongCount++;
    }
    totalStudyTimeMs += log.studyDurationMs;
    uniqueCards.add(
      log.flashcardId > 0
          ? 'id:${log.flashcardId}'
          : 'key:${log.cardOriginalId}',
    );
    switch (log.previousState) {
      case 'newCard':
        newReviewCount++;
        newStudyTimeMs += log.studyDurationMs;
        break;
      case 'learning':
      case 'relearning':
        learningReviewCount++;
        learningStudyTimeMs += log.studyDurationMs;
        break;
      default:
        reviewStateCount++;
        reviewStudyTimeMs += log.studyDurationMs;
        break;
    }
    final minutes = (log.timestamp.hour * 60) + log.timestamp.minute;
    final bucket = (minutes ~/ 15).clamp(0, 95);
    quarterHourBuckets[bucket] = quarterHourBuckets[bucket] + 1;
  }

  void addSession(StudySessionHistory history) {
    sessionCount++;
  }

  DeckDailyStats toStats(String packName, DateTime studyDay) {
    return DeckDailyStats()
      ..packDayKey = deckStudyDayKey(packName, studyDay)
      ..packName = packName
      ..studyDay = studyDay
      ..reviewCount = reviewCount
      ..correctCount = correctCount
      ..wrongCount = wrongCount
      ..uniqueCardCount = uniqueCards.length
      ..newReviewCount = newReviewCount
      ..learningReviewCount = learningReviewCount
      ..reviewStateCount = reviewStateCount
      ..sessionCount = sessionCount
      ..totalStudyTimeMs = totalStudyTimeMs
      ..newStudyTimeMs = newStudyTimeMs
      ..learningStudyTimeMs = learningStudyTimeMs
      ..reviewStudyTimeMs = reviewStudyTimeMs
      ..averageAnswerTimeMs = reviewCount == 0
          ? 0
          : (totalStudyTimeMs / reviewCount).round()
      ..quarterHourBuckets = List<int>.from(quarterHourBuckets);
  }
}

Future<void> rebuildAllDeckDailyStats(Isar isar) async {
  final logs = await isar.reviewLogs.where().findAll();
  final histories = await isar.studySessionHistorys.where().findAll();
  final buckets = <String, _DeckDayBucket>{};
  final packNames = <String, String>{};
  final studyDays = <String, DateTime>{};

  for (final log in logs) {
    final studyDay = log.studyDay.millisecondsSinceEpoch == 0
        ? DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day)
        : log.studyDay;
    final key = deckStudyDayKey(log.packName, studyDay);
    final bucket = buckets.putIfAbsent(key, _DeckDayBucket.new);
    bucket.addLog(log);
    packNames[key] = log.packName;
    studyDays[key] = studyDay;
  }

  for (final history in histories) {
    final studyDay = history.sessionDay.millisecondsSinceEpoch == 0
        ? DateTime(
            history.endedAt.year,
            history.endedAt.month,
            history.endedAt.day,
          )
        : history.sessionDay;
    final key = deckStudyDayKey(history.packName, studyDay);
    final bucket = buckets.putIfAbsent(key, _DeckDayBucket.new);
    bucket.addSession(history);
    packNames[key] = history.packName;
    studyDays[key] = studyDay;
  }

  final rows =
      buckets.entries
          .map(
            (entry) => entry.value.toStats(
              packNames[entry.key]!,
              studyDays[entry.key]!,
            ),
          )
          .toList()
        ..sort((a, b) {
          final packCompare = a.packName.compareTo(b.packName);
          if (packCompare != 0) return packCompare;
          return a.studyDay.compareTo(b.studyDay);
        });

  await isar.writeTxn(() async {
    await isar.deckDailyStats.clear();
    if (rows.isNotEmpty) {
      await isar.deckDailyStats.putAll(rows);
    }
  });
}

Future<void> syncDeckDailyStatsForPackDay(
  Isar isar,
  String packName,
  DateTime studyDay,
) async {
  final key = deckStudyDayKey(packName, studyDay);
  final logs = await isar.reviewLogs
      .filter()
      .packNameEqualTo(packName)
      .studyDayEqualTo(studyDay)
      .findAll();
  final histories = await isar.studySessionHistorys
      .filter()
      .packNameEqualTo(packName)
      .sessionDayEqualTo(studyDay)
      .findAll();

  if (logs.isEmpty && histories.isEmpty) {
    await isar.writeTxn(() async {
      await isar.deckDailyStats.filter().packDayKeyEqualTo(key).deleteAll();
    });
    return;
  }

  final bucket = _DeckDayBucket();
  for (final log in logs) {
    bucket.addLog(log);
  }
  for (final history in histories) {
    bucket.addSession(history);
  }

  await isar.writeTxn(() async {
    await isar.deckDailyStats.put(bucket.toStats(packName, studyDay));
  });
}
