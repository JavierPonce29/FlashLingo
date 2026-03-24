import 'dart:io';

import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:flashcards_app/data/models/deck_daily_stats.dart';
import 'package:flashcards_app/data/models/review_log.dart';
import 'package:flashcards_app/data/models/study_session_history.dart';
import 'package:flashcards_app/features/stats/stats_provider.dart';

class DeckStatsExportResult {
  final Directory directory;
  final List<File> files;

  const DeckStatsExportResult({required this.directory, required this.files});
}

Future<DeckStatsExportResult> exportDeckStatsCsv(
  Isar isar,
  String packName,
  DeckStatsData stats,
) async {
  final dailyStats = await isar.deckDailyStats
      .filter()
      .packNameEqualTo(packName)
      .sortByStudyDay()
      .findAll();
  final reviewLogs = await isar.reviewLogs
      .filter()
      .packNameEqualTo(packName)
      .sortByTimestamp()
      .findAll();
  final sessions = await isar.studySessionHistorys
      .filter()
      .packNameEqualTo(packName)
      .sortByEndedAt()
      .findAll();

  final exportDir = await _createExportDirectory(packName);
  final files = <File>[
    await _writeSummaryCsv(exportDir, packName, stats),
    await _writeDailyStatsCsv(exportDir, packName, dailyStats),
    await _writeProblemCardsCsv(exportDir, packName, stats.problemCards),
    await _writeSessionsCsv(exportDir, packName, sessions),
    await _writeReviewHistoryCsv(exportDir, packName, reviewLogs),
  ];

  return DeckStatsExportResult(directory: exportDir, files: files);
}

Future<Directory> _createExportDirectory(String packName) async {
  final baseDir = await _resolveExportBaseDirectory();
  final sanitized = packName.replaceAll(RegExp(r'[^\w\-]+'), '_');
  final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final directory = Directory(
    p.join(baseDir.path, 'FlashLingo', '${sanitized}_$timestamp'),
  );
  await directory.create(recursive: true);
  return directory;
}

Future<Directory> _resolveExportBaseDirectory() async {
  if (Platform.isAndroid) {
    final external = await getExternalStorageDirectory();
    if (external != null) {
      final path = external.path;
      final marker =
          '${Platform.pathSeparator}Android${Platform.pathSeparator}data${Platform.pathSeparator}';
      final index = path.indexOf(marker);
      if (index > 0) {
        final sharedRoot = Directory(path.substring(0, index));
        try {
          if (await sharedRoot.exists()) {
            return sharedRoot;
          }
        } catch (_) {}
      }
    }
    for (final candidatePath in const <String>[
      '/storage/emulated/0',
      '/sdcard',
    ]) {
      final candidate = Directory(candidatePath);
      try {
        if (await candidate.exists()) {
          return candidate;
        }
      } catch (_) {}
    }
  }

  final downloads = await getDownloadsDirectory();
  if (downloads != null) {
    return downloads;
  }
  return getApplicationDocumentsDirectory();
}

Future<File> _writeSummaryCsv(
  Directory directory,
  String packName,
  DeckStatsData stats,
) {
  return _writeCsv(
    File(p.join(directory.path, 'summary.csv')),
    <String>[
      'pack_name',
      'exported_at',
      'total_cards',
      'new_available_today',
      'learning_due_now',
      'review_due_now',
      'overdue_cards',
      'lifetime_reviews',
      'lifetime_accuracy_percent',
      'accuracy_7d_percent',
      'accuracy_30d_percent',
      'reviews_per_day_7d',
      'reviews_per_day_30d',
      'study_time_per_day_7d_minutes',
      'study_time_per_day_30d_minutes',
      'avg_answer_time_ms',
      'total_study_time_ms',
      'session_count_7d',
      'session_count_30d',
    ],
    <List<Object?>>[
      <Object?>[
        packName,
        _dateTime(DateTime.now()),
        stats.totalCards,
        stats.newAvailableToday,
        stats.learningDueNow,
        stats.reviewDueNow,
        stats.overdueCards,
        stats.lifetimeReviewCount,
        (stats.lifetimeAccuracy * 100).toStringAsFixed(1),
        (stats.accuracy7d * 100).toStringAsFixed(1),
        (stats.accuracy30d * 100).toStringAsFixed(1),
        stats.reviewsPerDay7d.toStringAsFixed(2),
        stats.reviewsPerDay30d.toStringAsFixed(2),
        (stats.studyTimePerDay7dMs / 60000).toStringAsFixed(2),
        (stats.studyTimePerDay30dMs / 60000).toStringAsFixed(2),
        stats.averageAnswerTimeMs,
        stats.totalStudyTimeMs,
        stats.sessionCount7d,
        stats.sessionCount30d,
      ],
    ],
  );
}

Future<File> _writeDailyStatsCsv(
  Directory directory,
  String packName,
  List<DeckDailyStats> dailyStats,
) {
  final rows = dailyStats.map(
    (day) => <Object?>[
      packName,
      _studyDay(day.studyDay),
      day.reviewCount,
      day.correctCount,
      day.wrongCount,
      day.reviewCount == 0
          ? '0.0'
          : ((day.correctCount / day.reviewCount) * 100).toStringAsFixed(1),
      day.uniqueCardCount,
      day.sessionCount,
      day.totalStudyTimeMs,
      day.averageAnswerTimeMs,
    ],
  );
  return _writeCsv(
    File(p.join(directory.path, 'daily_stats.csv')),
    const <String>[
      'pack_name',
      'study_day',
      'review_count',
      'correct_count',
      'wrong_count',
      'accuracy_percent',
      'unique_card_count',
      'session_count',
      'total_study_time_ms',
      'avg_answer_time_ms',
    ],
    rows,
  );
}

Future<File> _writeProblemCardsCsv(
  Directory directory,
  String packName,
  List<DeckCardInsight> problemCards,
) {
  final rows = problemCards.map(
    (card) => <Object?>[
      packName,
      card.id,
      card.cardType,
      card.state.name,
      card.question,
      card.overdueDays,
      card.consecutiveLapses,
      card.lifetimeReviewCount,
      card.lifetimeCorrectCount,
      card.lifetimeWrongCount,
      (card.accuracy * 100).toStringAsFixed(1),
      card.averageStudyTimeMs,
      card.difficultyScore.toStringAsFixed(1),
      card.problemTags.join('|'),
      _dateTime(card.lastReview),
      _dateTime(card.nextReview),
    ],
  );
  return _writeCsv(
    File(p.join(directory.path, 'problem_cards.csv')),
    const <String>[
      'pack_name',
      'flashcard_id',
      'card_type',
      'state',
      'question',
      'overdue_days',
      'consecutive_lapses',
      'lifetime_reviews',
      'lifetime_correct',
      'lifetime_wrong',
      'accuracy_percent',
      'avg_answer_time_ms',
      'difficulty_score',
      'problem_tags',
      'last_review',
      'next_review',
    ],
    rows,
  );
}

Future<File> _writeSessionsCsv(
  Directory directory,
  String packName,
  List<StudySessionHistory> sessions,
) {
  final rows = sessions.map(
    (session) => <Object?>[
      packName,
      session.sessionId,
      _studyDay(session.sessionDay),
      _dateTime(session.startedAt),
      _dateTime(session.endedAt),
      session.answerCount,
      session.correctCount,
      session.wrongCount,
      session.uniqueCardCount,
      session.totalStudyTimeMs,
      session.averageAnswerTimeMs,
    ],
  );
  return _writeCsv(File(p.join(directory.path, 'sessions.csv')), const <String>[
    'pack_name',
    'session_id',
    'session_day',
    'started_at',
    'ended_at',
    'answer_count',
    'correct_count',
    'wrong_count',
    'unique_card_count',
    'total_study_time_ms',
    'avg_answer_time_ms',
  ], rows);
}

Future<File> _writeReviewHistoryCsv(
  Directory directory,
  String packName,
  List<ReviewLog> logs,
) {
  final rows = logs.map(
    (log) => <Object?>[
      packName,
      _dateTime(log.timestamp),
      _studyDay(log.studyDay),
      log.sessionId,
      log.flashcardId,
      log.cardOriginalId,
      log.cardType,
      log.isCorrect,
      log.previousState,
      log.newState,
      _dateTime(log.previousNextReview),
      _dateTime(log.newNextReview),
      log.daysLate,
      log.rating,
      log.scheduledDays,
      log.studyDurationMs,
    ],
  );
  return _writeCsv(
    File(p.join(directory.path, 'review_history.csv')),
    const <String>[
      'pack_name',
      'timestamp',
      'study_day',
      'session_id',
      'flashcard_id',
      'card_original_id',
      'card_type',
      'is_correct',
      'previous_state',
      'new_state',
      'previous_next_review',
      'new_next_review',
      'days_late',
      'rating',
      'scheduled_days',
      'study_duration_ms',
    ],
    rows,
  );
}

Future<File> _writeCsv(
  File file,
  List<String> headers,
  Iterable<List<Object?>> rows,
) async {
  final buffer = StringBuffer()..writeln(headers.map(_escapeCsv).join(','));
  for (final row in rows) {
    buffer.writeln(row.map(_escapeCsvValue).join(','));
  }
  await file.writeAsString(buffer.toString());
  return file;
}

String _escapeCsvValue(Object? value) => _escapeCsv(value?.toString() ?? '');

String _escapeCsv(String value) {
  final escaped = value.replaceAll('"', '""');
  if (escaped.contains(',') ||
      escaped.contains('"') ||
      escaped.contains('\n')) {
    return '"$escaped"';
  }
  return escaped;
}

String _dateTime(DateTime value) {
  if (value.millisecondsSinceEpoch == 0) return '';
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(value);
}

String _studyDay(DateTime value) {
  if (value.millisecondsSinceEpoch == 0) return '';
  return DateFormat('yyyy-MM-dd').format(value);
}
