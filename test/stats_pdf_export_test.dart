import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flashcards_app/data/models/deck_daily_stats.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/features/stats/stats_export_service.dart';
import 'package:flashcards_app/features/stats/stats_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buildDeckStatsPdfBytes creates a non-empty pdf file', () async {
    final settings = DeckSettings()..packName = 'Demo deck 日本語';
    final today = DateTime(2026, 3, 24);

    final flashcard = Flashcard()
      ..originalId = 'demo::1'
      ..isoCode = 'en'
      ..packName = 'Demo deck 日本語'
      ..cardType = 'vocab_recog'
      ..question = 'árbol 日本語 alpha'
      ..answer = 'first'
      ..state = CardState.review
      ..nextReview = today
      ..lastReview = today.subtract(const Duration(days: 1))
      ..lifetimeReviewCount = 12
      ..lifetimeCorrectCount = 10
      ..lifetimeWrongCount = 2
      ..totalStudyTimeMs = 720000;

    final dailyRows = <DeckDailyStats>[
      DeckDailyStats()
        ..packDayKey = 'Demo deck 日本語::2026-03-23'
        ..packName = 'Demo deck 日本語'
        ..studyDay = DateTime(2026, 3, 23)
        ..reviewCount = 8
        ..correctCount = 6
        ..wrongCount = 2
        ..uniqueCardCount = 5
        ..sessionCount = 1
        ..totalStudyTimeMs = 420000
        ..averageAnswerTimeMs = 5250,
      DeckDailyStats()
        ..packDayKey = 'Demo deck 日本語::2026-03-24'
        ..packName = 'Demo deck 日本語'
        ..studyDay = today
        ..reviewCount = 4
        ..correctCount = 4
        ..wrongCount = 0
        ..uniqueCardCount = 3
        ..sessionCount = 1
        ..totalStudyTimeMs = 300000
        ..averageAnswerTimeMs = 5000,
    ];

    final insight = DeckCardInsight(
      id: 1,
      question: 'árbol 日本語 alpha',
      cardType: 'vocab_recog',
      state: CardState.review,
      nextReview: today,
      lastReview: today.subtract(const Duration(days: 1)),
      lifetimeReviewCount: 12,
      lifetimeCorrectCount: 10,
      lifetimeWrongCount: 2,
      totalStudyTimeMs: 720000,
      consecutiveLapses: 1,
      overdueDays: 0,
      averageStudyTimeMs: 6000,
      difficultyScore: 18.5,
      problemTags: const <String>['slow'],
    );

    final session = DeckSessionInsight(
      sessionId: 'session-1',
      startedAt: today.subtract(const Duration(minutes: 15)),
      endedAt: today,
      answerCount: 12,
      correctCount: 10,
      wrongCount: 2,
      uniqueCardCount: 7,
      totalStudyTimeMs: 720000,
      averageAnswerTimeMs: 6000,
    );

    final stats = DeckStatsData(
      settings: settings,
      labelToday: today,
      cardSnapshots: <Flashcard>[flashcard],
      dailyStatsRows: dailyRows,
      totalCards: 1,
      newAvailableToday: 0,
      newCards: 0,
      learningDueNow: 0,
      learningCards: 0,
      reviewDueNow: 1,
      reviewCards: 1,
      overdueCards: 0,
      relearningCards: 0,
      lifetimeReviewCount: 12,
      lifetimeCorrectCount: 10,
      lifetimeWrongCount: 2,
      totalStudyTimeMs: 720000,
      averageAnswerTimeMs: 6000,
      reviewCount7d: 12,
      correctCount7d: 10,
      reviewCount30d: 12,
      correctCount30d: 10,
      studyTime7dMs: 720000,
      studyTime30dMs: 720000,
      sessionCount7d: 1,
      sessionCount30d: 1,
      activeDays7d: 2,
      activeDays30d: 2,
      hardestCards: <DeckCardInsight>[insight],
      problemCards: <DeckCardInsight>[insight],
      recentSessions: <DeckSessionInsight>[session],
    );

    final bytes = await buildDeckStatsPdfBytes(
      'Demo deck 日本語',
      stats,
      charts: <DeckStatsPdfChart>[
        DeckStatsPdfChart(
          title: 'Study time',
          subtitle: '7d',
          child: pw.Center(child: pw.Text('chart')),
          landscape: true,
        ),
      ],
    );

    expect(bytes.length, greaterThan(1000));

    final dir = Directory('tmp/pdfs')..createSync(recursive: true);
    final file = File('${dir.path}/stats_report_test.pdf');
    await file.writeAsBytes(bytes, flush: true);

    expect(file.existsSync(), isTrue);
  });
}
