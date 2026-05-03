import 'package:flutter_test/flutter_test.dart';

import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/utils/review_daily_limit.dart';

void main() {
  group('review daily limit planner', () {
    test('keeps the oldest due reviews today and defers overflow', () {
      final settings = DeckSettings()
        ..packName = 'Demo'
        ..maxReviewsPerDay = 2
        ..dayCutoffHour = 4
        ..dayCutoffMinute = 0;
      final now = DateTime(2026, 4, 12, 12);
      final cards = <Flashcard>[
        _reviewCard(
          id: 1,
          nextReview: DateTime(2026, 4, 8, 4),
        ),
        _reviewCard(
          id: 2,
          nextReview: DateTime(2026, 4, 9, 4),
        ),
        _reviewCard(
          id: 3,
          nextReview: DateTime(2026, 4, 10, 4),
        ),
        _reviewCard(
          id: 4,
          nextReview: DateTime(2026, 4, 12, 4),
        ),
        _reviewCard(
          id: 5,
          nextReview: DateTime(2026, 4, 13, 4),
        ),
      ];

      final plan = planFlashcardReviewDailyLimit(
        cards: cards,
        settings: settings,
        now: now,
      );
      final assignedById = <int, DateTime>{
        for (final assignment in plan.assignments)
          assignment.item.id: assignment.assignedDay,
      };

      expect(plan.hasOverflowToday, isTrue);
      expect(assignedById[1], DateTime(2026, 4, 12));
      expect(assignedById[2], DateTime(2026, 4, 12));
      expect(assignedById[3], DateTime(2026, 4, 13));
      expect(assignedById[4], DateTime(2026, 4, 13));
      expect(assignedById[5], DateTime(2026, 4, 14));
    });

    test('carried reviews keep priority over originally scheduled next-day cards', () {
      final settings = DeckSettings()
        ..packName = 'Demo'
        ..maxReviewsPerDay = 1
        ..dayCutoffHour = 4
        ..dayCutoffMinute = 0;
      final dayOne = DateTime(2026, 4, 12, 12);
      final todayFirst = _reviewCard(
        id: 1,
        nextReview: DateTime(2026, 4, 12, 4),
      );
      final carriedCard = _reviewCard(
        id: 2,
        nextReview: DateTime(2026, 4, 12, 4),
      );
      final tomorrowCard = _reviewCard(
        id: 3,
        nextReview: DateTime(2026, 4, 13, 4),
      );

      final syncResult = syncFlashcardReviewDailyLimit(
        cards: [todayFirst, carriedCard, tomorrowCard],
        settings: settings,
        now: dayOne,
      );

      expect(syncResult.plan.hasOverflowToday, isTrue);
      expect(carriedCard.nextReview, DateTime(2026, 4, 13, 4));

      final dayTwoPlan = planFlashcardReviewDailyLimit(
        cards: [carriedCard, tomorrowCard],
        settings: settings,
        now: DateTime(2026, 4, 13, 12),
      );
      final assignedById = <int, DateTime>{
        for (final assignment in dayTwoPlan.assignments)
          assignment.item.id: assignment.assignedDay,
      };

      expect(assignedById[2], DateTime(2026, 4, 13));
      expect(assignedById[3], DateTime(2026, 4, 14));
    });

    test('manual overrides bypass the automatic cap for today', () {
      final settings = DeckSettings()
        ..packName = 'Demo'
        ..maxReviewsPerDay = 1
        ..dayCutoffHour = 4
        ..dayCutoffMinute = 0;
      final now = DateTime(2026, 4, 12, 12);
      final cards = <Flashcard>[
        _reviewCard(
          id: 1,
          nextReview: DateTime(2026, 4, 10, 4),
        ),
        _reviewCard(
          id: 2,
          nextReview: DateTime(2026, 4, 11, 4),
        ),
        _reviewCard(
          id: 3,
          nextReview: DateTime(2026, 4, 15, 4),
        )..manualReviewOverrideDay = DateTime(2026, 4, 12),
      ];
      cards[2].nextReview = now;
      cards[2].reviewPriorityAnchor = now;

      final plan = planFlashcardReviewDailyLimit(
        cards: cards,
        settings: settings,
        now: now,
      );
      final todayAssignments = plan.assignments
          .where((assignment) => assignment.assignedDay == DateTime(2026, 4, 12))
          .toList();

      expect(plan.hasOverflowToday, isTrue);
      expect(todayAssignments.length, 2);
      expect(
        todayAssignments.where((assignment) => assignment.isManualOverrideToday),
        hasLength(1),
      );
    });

    test('sync persists deferred cards and seeds priority metadata', () {
      final settings = DeckSettings()
        ..packName = 'Demo'
        ..maxReviewsPerDay = 1
        ..dayCutoffHour = 4
        ..dayCutoffMinute = 0;
      final first = _reviewCard(
        id: 1,
        nextReview: DateTime(2026, 4, 11, 4),
      );
      final second = _reviewCard(
        id: 2,
        nextReview: DateTime(2026, 4, 12, 4),
      );

      final result = syncFlashcardReviewDailyLimit(
        cards: [first, second],
        settings: settings,
        now: DateTime(2026, 4, 12, 12),
      );

      expect(result.changedCards, hasLength(2));
      expect(first.reviewPriorityAnchor, DateTime(2026, 4, 11, 4));
      expect(second.nextReview, DateTime(2026, 4, 13, 4));
      expect(second.reviewPriorityAnchor, DateTime(2026, 4, 12, 4));
    });
  });
}

Flashcard _reviewCard({
  required int id,
  required DateTime nextReview,
}) {
  return Flashcard()
    ..id = id
    ..originalId = 'card-$id'
    ..isoCode = 'en'
    ..packName = 'Demo'
    ..cardType = 'en_recog'
    ..question = 'Q$id'
    ..answer = 'A$id'
    ..state = CardState.review
    ..nextReview = nextReview;
}
