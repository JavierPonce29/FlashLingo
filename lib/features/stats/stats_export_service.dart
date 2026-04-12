import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:flashcards_app/data/models/deck_daily_stats.dart';
import 'package:flashcards_app/data/models/review_log.dart';
import 'package:flashcards_app/data/models/study_session_history.dart';
import 'package:flashcards_app/features/stats/stats_provider.dart';

class DeckStatsExportResult {
  final Directory directory;
  final List<File> files;

  const DeckStatsExportResult({required this.directory, required this.files});
}

class DeckStatsPdfChart {
  final String title;
  final String? subtitle;
  final pw.Widget child;
  final bool landscape;

  const DeckStatsPdfChart({
    required this.title,
    this.subtitle,
    required this.child,
    this.landscape = false,
  });
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

Future<File> exportDeckStatsPdf(
  String packName,
  DeckStatsData stats, {
  List<DeckStatsPdfChart> charts = const <DeckStatsPdfChart>[],
}) async {
  final exportDir = await _createExportDirectory(packName);
  final file = File(p.join(exportDir.path, 'stats_report.pdf'));
  final bytes = await buildDeckStatsPdfBytes(packName, stats, charts: charts);
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

Future<void> shareDeckStatsCsvResult(
  DeckStatsExportResult result, {
  String? text,
}) async {
  await Share.shareXFiles(
    result.files.map((file) => XFile(file.path)).toList(growable: false),
    text: text,
  );
}

Future<void> shareDeckStatsPdfFile(File file, {String? text}) async {
  await Share.shareXFiles(<XFile>[XFile(file.path)], text: text);
}

Future<List<int>> buildDeckStatsPdfBytes(
  String packName,
  DeckStatsData stats, {
  List<DeckStatsPdfChart> charts = const <DeckStatsPdfChart>[],
}) async {
  final pdfTheme = await _loadPdfTheme();
  final document = pw.Document(
    title: 'FlashLingo stats report - $packName',
    author: 'FlashLingo',
  );

  final recentDailyStats = _takeLast(stats.dailyStatsRows, 30);

  document.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        theme: pdfTheme,
      ),
      build: (context) => <pw.Widget>[
        _pdfHeader(packName),
        pw.SizedBox(height: 14),
        _pdfMetricGrid(<_PdfMetric>[
          _PdfMetric('Total cards', '${stats.totalCards}'),
          _PdfMetric('New today', '${stats.newAvailableToday}'),
          _PdfMetric('Learning now', '${stats.learningDueNow}'),
          _PdfMetric('Review now', '${stats.reviewDueNow}'),
          _PdfMetric('Overdue', '${stats.overdueCards}'),
          _PdfMetric('Lifetime reviews', '${stats.lifetimeReviewCount}'),
          _PdfMetric('Lifetime accuracy', _pdfPercent(stats.lifetimeAccuracy)),
          _PdfMetric('Accuracy 7d', _pdfPercent(stats.accuracy7d)),
          _PdfMetric('Accuracy 30d', _pdfPercent(stats.accuracy30d)),
          _PdfMetric(
            'Avg answer time',
            _pdfDuration(stats.averageAnswerTimeMs),
          ),
          _PdfMetric('Study time total', _pdfDuration(stats.totalStudyTimeMs)),
          _PdfMetric('Study time 7d', _pdfDuration(stats.studyTime7dMs)),
        ]),
        pw.SizedBox(height: 18),
        _pdfSectionTitle('Deck state'),
        _pdfSimpleTable(
          headers: const <String>['Metric', 'Value'],
          rows: <List<String>>[
            <String>['New cards', '${stats.newCards}'],
            <String>['Learning cards', '${stats.learningCards}'],
            <String>['Review cards', '${stats.reviewCards}'],
            <String>['Relearning cards', '${stats.relearningCards}'],
            <String>['Sessions 7d', '${stats.sessionCount7d}'],
            <String>['Sessions 30d', '${stats.sessionCount30d}'],
            <String>['Active days 7d', '${stats.activeDays7d}/7'],
            <String>['Active days 30d', '${stats.activeDays30d}/30'],
          ],
        ),
        pw.SizedBox(height: 18),
        _pdfSectionTitle('Problem cards'),
        _pdfSimpleTable(
          headers: const <String>[
            'Question',
            'State',
            'Accuracy',
            'Fail',
            'Overdue',
            'Avg time',
          ],
          rows: stats.problemCards
              .map(
                (card) => <String>[
                  _pdfClip(card.question, 42),
                  card.state.name,
                  _pdfPercent(card.accuracy),
                  '${card.lifetimeWrongCount}',
                  '${card.overdueDays}d',
                  _pdfDuration(card.averageStudyTimeMs),
                ],
              )
              .toList(),
          emptyLabel: 'No problem cards',
        ),
        pw.SizedBox(height: 18),
        _pdfSectionTitle('Hardest cards'),
        _pdfSimpleTable(
          headers: const <String>[
            'Question',
            'Accuracy',
            'Fail',
            'Reviews',
            'Study time',
          ],
          rows: stats.hardestCards
              .map(
                (card) => <String>[
                  _pdfClip(card.question, 48),
                  _pdfPercent(card.accuracy),
                  '${card.lifetimeWrongCount}',
                  '${card.lifetimeReviewCount}',
                  _pdfDuration(card.totalStudyTimeMs),
                ],
              )
              .toList(),
          emptyLabel: 'No card history',
        ),
        pw.SizedBox(height: 18),
        _pdfSectionTitle('Recent sessions'),
        _pdfSimpleTable(
          headers: const <String>[
            'Ended at',
            'Answers',
            'Accuracy',
            'Duration',
            'Avg answer',
          ],
          rows: stats.recentSessions
              .map(
                (session) => <String>[
                  _dateTime(session.endedAt),
                  '${session.answerCount}',
                  _pdfPercent(session.accuracy),
                  _pdfDuration(session.totalStudyTimeMs),
                  _pdfDuration(session.averageAnswerTimeMs),
                ],
              )
              .toList(),
          emptyLabel: 'No completed sessions',
        ),
        pw.SizedBox(height: 18),
        _pdfSectionTitle('Daily stats (last 30 study days)'),
        _pdfSimpleTable(
          headers: const <String>[
            'Day',
            'Reviews',
            'Accuracy',
            'Unique',
            'Sessions',
            'Time',
          ],
          rows: recentDailyStats
              .map(
                (day) => <String>[
                  _studyDay(day.studyDay),
                  '${day.reviewCount}',
                  day.reviewCount == 0
                      ? '0%'
                      : _pdfPercent(day.correctCount / day.reviewCount),
                  '${day.uniqueCardCount}',
                  '${day.sessionCount}',
                  _pdfDuration(day.totalStudyTimeMs),
                ],
              )
              .toList(),
          emptyLabel: 'No daily stats yet',
        ),
      ],
    ),
  );

  for (final chart in charts) {
    document.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: chart.landscape
              ? PdfPageFormat.a4.landscape
              : PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          theme: pdfTheme,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(
                chart.title,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
              if (chart.subtitle != null && chart.subtitle!.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  chart.subtitle!,
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.blueGrey700,
                  ),
                ),
              ],
              pw.SizedBox(height: 12),
              pw.Expanded(child: chart.child),
            ],
          );
        },
      ),
    );
  }

  return document.save();
}

Future<Directory> _createExportDirectory(String packName) async {
  final sanitized = packName.replaceAll(RegExp(r'[^\w\-]+'), '_');
  final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final folderName = '${sanitized}_$timestamp';
  final baseDir = await getApplicationSupportDirectory();
  final directory = Directory(
    p.join(baseDir.path, 'flashlingo_exports', folderName),
  );
  await directory.create(recursive: true);
  return directory;
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

Future<pw.ThemeData> _loadPdfTheme() async {
  try {
    final unicode = await rootBundle.load(
      'lib/assets/fonts/ArialUnicodeMS.ttf',
    );
    final unicodeFont = pw.Font.ttf(unicode);
    return pw.ThemeData.withFont(base: unicodeFont, bold: unicodeFont);
  } catch (_) {
    final regular = await rootBundle.load('lib/assets/fonts/DejaVuSans.ttf');
    final bold = await rootBundle.load('lib/assets/fonts/DejaVuSans-Bold.ttf');
    return pw.ThemeData.withFont(
      base: pw.Font.ttf(regular),
      bold: pw.Font.ttf(bold),
    );
  }
}

class _PdfMetric {
  final String label;
  final String value;

  const _PdfMetric(this.label, this.value);
}

List<T> _takeLast<T>(List<T> values, int count) {
  if (values.length <= count) {
    return List<T>.from(values);
  }
  return values.sublist(values.length - count);
}

pw.Widget _pdfHeader(String packName) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: <pw.Widget>[
      pw.Text(
        'FlashLingo stats report',
        style: pw.TextStyle(
          fontSize: 22,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey900,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        packName,
        style: pw.TextStyle(fontSize: 15, color: PdfColors.blueGrey700),
      ),
      pw.SizedBox(height: 2),
      pw.Text(
        'Exported: ${_dateTime(DateTime.now())}',
        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
      ),
    ],
  );
}

pw.Widget _pdfSectionTitle(String title) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blueGrey900,
      ),
    ),
  );
}

pw.Widget _pdfMetricGrid(List<_PdfMetric> metrics) {
  return pw.Wrap(
    spacing: 10,
    runSpacing: 10,
    children: metrics
        .map(
          (metric) => pw.Container(
            width: 162,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.blueGrey50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: PdfColors.blueGrey100),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  metric.value,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey900,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  metric.label,
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.blueGrey700,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList(),
  );
}

pw.Widget _pdfSimpleTable({
  required List<String> headers,
  required List<List<String>> rows,
  String emptyLabel = 'No data',
}) {
  if (rows.isEmpty) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Text(
        emptyLabel,
        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
      ),
    );
  }

  return pw.TableHelper.fromTextArray(
    headers: headers,
    data: rows,
    headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
    headerStyle: pw.TextStyle(
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blueGrey900,
    ),
    cellStyle: const pw.TextStyle(fontSize: 8.5, color: PdfColors.black),
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    border: pw.TableBorder.all(color: PdfColors.blueGrey100, width: 0.5),
    oddRowDecoration: const pw.BoxDecoration(color: PdfColors.white),
    rowDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
  );
}

String _pdfPercent(double value) => '${(value * 100).round()}%';

String _pdfDuration(num totalMs) {
  final ms = totalMs.round();
  if (ms <= 0) return '0s';
  final totalSeconds = Duration(milliseconds: ms).inSeconds;
  if (totalSeconds < 60) return '${totalSeconds}s';
  final totalMinutes = Duration(milliseconds: ms).inMinutes;
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours <= 0) return '${minutes}m';
  if (minutes == 0) return '${hours}h';
  return '${hours}h ${minutes}m';
}

String _pdfClip(String value, int maxLength) {
  if (value.length <= maxLength) {
    return value;
  }
  return '${value.substring(0, maxLength - 3)}...';
}
