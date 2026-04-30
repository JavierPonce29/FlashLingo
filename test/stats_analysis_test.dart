import 'package:flutter_test/flutter_test.dart';

import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/features/stats/stats_analysis.dart';
import 'package:flashcards_app/features/stats/stats_provider.dart';

void main() {
  group('buildForecastSeries', () {
    test('shows remaining new cards only for the current study day', () {
      final settings = DeckSettings()
        ..packName = 'Demo'
        ..newCardsPerDay = 2
        ..dayCutoffHour = 4
        ..dayCutoffMinute = 0;
      final labelToday = DateTime(2026, 4, 12);
      final cards = List<Flashcard>.generate(5, (index) {
        return Flashcard()
          ..id = index + 1
          ..originalId = 'card-$index'
          ..isoCode = 'en'
          ..packName = 'Demo'
          ..cardType = 'en_recog'
          ..question = 'Q$index'
          ..answer = 'A$index'
          ..state = CardState.newCard;
      });

      final data = DeckStatsData(
        settings: settings,
        labelToday: labelToday,
        cardSnapshots: cards,
        dailyStatsRows: const [],
        totalCards: cards.length,
        newAvailableToday: 2,
        newCards: cards.length,
        learningDueNow: 0,
        learningCards: 0,
        reviewDueNow: 0,
        reviewCards: 0,
        overdueCards: 0,
        relearningCards: 0,
        lifetimeReviewCount: 0,
        lifetimeCorrectCount: 0,
        lifetimeWrongCount: 0,
        totalStudyTimeMs: 0,
        averageAnswerTimeMs: 0,
        reviewCount7d: 0,
        correctCount7d: 0,
        reviewCount30d: 0,
        correctCount30d: 0,
        studyTime7dMs: 0,
        studyTime30dMs: 0,
        sessionCount7d: 0,
        sessionCount30d: 0,
        activeDays7d: 0,
        activeDays30d: 0,
        hardestCards: const [],
        problemCards: const [],
        recentSessions: const [],
      );

      final points = buildForecastSeries(data, StatsRangeOption.days7);

      expect(points[0].newCards, 2);
      expect(points.skip(1).every((point) => point.newCards == 0), isTrue);
    });

    test('respects remaining quota for the current study day', () {
      final settings = DeckSettings()
        ..packName = 'Demo'
        ..newCardsPerDay = 2
        ..newCardsSeenToday = 1
        ..lastNewCardStudyDate = DateTime(2026, 4, 12, 10)
        ..dayCutoffHour = 4
        ..dayCutoffMinute = 0;
      final labelToday = DateTime(2026, 4, 12);
      final cards = List<Flashcard>.generate(3, (index) {
        return Flashcard()
          ..id = index + 1
          ..originalId = 'card-$index'
          ..isoCode = 'en'
          ..packName = 'Demo'
          ..cardType = 'en_recog'
          ..question = 'Q$index'
          ..answer = 'A$index'
          ..state = CardState.newCard;
      });

      final data = DeckStatsData(
        settings: settings,
        labelToday: labelToday,
        cardSnapshots: cards,
        dailyStatsRows: const [],
        totalCards: cards.length,
        newAvailableToday: 1,
        newCards: cards.length,
        learningDueNow: 0,
        learningCards: 0,
        reviewDueNow: 0,
        reviewCards: 0,
        overdueCards: 0,
        relearningCards: 0,
        lifetimeReviewCount: 0,
        lifetimeCorrectCount: 0,
        lifetimeWrongCount: 0,
        totalStudyTimeMs: 0,
        averageAnswerTimeMs: 0,
        reviewCount7d: 0,
        correctCount7d: 0,
        reviewCount30d: 0,
        correctCount30d: 0,
        studyTime7dMs: 0,
        studyTime30dMs: 0,
        sessionCount7d: 0,
        sessionCount30d: 0,
        activeDays7d: 0,
        activeDays30d: 0,
        hardestCards: const [],
        problemCards: const [],
        recentSessions: const [],
      );

      final points = buildForecastSeries(data, StatsRangeOption.days7);

      expect(points[0].newCards, 1);
      expect(points.skip(1).every((point) => point.newCards == 0), isTrue);
    });

    test('async forecast builder matches the sync output', () async {
      final settings = DeckSettings()
        ..packName = 'Demo'
        ..newCardsPerDay = 3
        ..dayCutoffHour = 4
        ..dayCutoffMinute = 0;
      final labelToday = DateTime(2026, 4, 12);
      final cards = <Flashcard>[
        Flashcard()
          ..id = 1
          ..originalId = 'new-1'
          ..isoCode = 'en'
          ..packName = 'Demo'
          ..cardType = 'en_recog'
          ..question = 'Q1'
          ..answer = 'A1'
          ..state = CardState.newCard,
        Flashcard()
          ..id = 2
          ..originalId = 'review-1'
          ..isoCode = 'en'
          ..packName = 'Demo'
          ..cardType = 'en_recog'
          ..question = 'Q2'
          ..answer = 'A2'
          ..state = CardState.review
          ..nextReview = DateTime(2026, 4, 13, 8),
        Flashcard()
          ..id = 3
          ..originalId = 'learning-1'
          ..isoCode = 'en'
          ..packName = 'Demo'
          ..cardType = 'en_recog'
          ..question = 'Q3'
          ..answer = 'A3'
          ..state = CardState.learning
          ..nextReview = DateTime(2026, 4, 12, 9),
      ];

      final data = DeckStatsData(
        settings: settings,
        labelToday: labelToday,
        cardSnapshots: cards,
        dailyStatsRows: const [],
        totalCards: cards.length,
        newAvailableToday: 1,
        newCards: 1,
        learningDueNow: 1,
        learningCards: 1,
        reviewDueNow: 0,
        reviewCards: 1,
        overdueCards: 0,
        relearningCards: 0,
        lifetimeReviewCount: 0,
        lifetimeCorrectCount: 0,
        lifetimeWrongCount: 0,
        totalStudyTimeMs: 0,
        averageAnswerTimeMs: 0,
        reviewCount7d: 0,
        correctCount7d: 0,
        reviewCount30d: 0,
        correctCount30d: 0,
        studyTime7dMs: 0,
        studyTime30dMs: 0,
        sessionCount7d: 0,
        sessionCount30d: 0,
        activeDays7d: 0,
        activeDays30d: 0,
        hardestCards: const [],
        problemCards: const [],
        recentSessions: const [],
      );

      final syncPoints = buildForecastSeries(data, StatsRangeOption.days7);
      final asyncPoints = await buildForecastSeriesAsync(
        data,
        StatsRangeOption.days7,
      );

      expect(asyncPoints.length, syncPoints.length);
      for (int i = 0; i < syncPoints.length; i++) {
        expect(asyncPoints[i].day, syncPoints[i].day);
        expect(asyncPoints[i].overdue, syncPoints[i].overdue);
        expect(asyncPoints[i].learning, syncPoints[i].learning);
        expect(asyncPoints[i].review, syncPoints[i].review);
        expect(asyncPoints[i].newCards, syncPoints[i].newCards);
      }
    });
  });
}
