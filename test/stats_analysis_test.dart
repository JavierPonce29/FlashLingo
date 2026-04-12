import 'package:flutter_test/flutter_test.dart';

import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/features/stats/stats_analysis.dart';
import 'package:flashcards_app/features/stats/stats_provider.dart';

void main() {
  group('buildForecastSeries', () {
    test('distributes remaining new cards across future study days', () {
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
      expect(points[1].newCards, 2);
      expect(points[2].newCards, 1);
      expect(points.skip(3).every((point) => point.newCards == 0), isTrue);
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
      expect(points[1].newCards, 2);
    });
  });
}
