import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/features/stats/problem_card_actions.dart';
import 'package:flashcards_app/features/stats/stats_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'test_support.dart';

void main() {
  group('canBringProblemCardToToday', () {
    test('allows only non-new cards scheduled in the future', () {
      final now = DateTime(2026, 4, 14, 10);

      expect(
        canBringProblemCardToToday(
          _insight(
            state: CardState.review,
            nextReview: now.add(const Duration(days: 1)),
          ),
          now,
        ),
        isTrue,
      );
      expect(
        canBringProblemCardToToday(
          _insight(
            state: CardState.newCard,
            nextReview: now.add(const Duration(days: 1)),
          ),
          now,
        ),
        isFalse,
      );
      expect(
        canBringProblemCardToToday(
          _insight(
            state: CardState.review,
            nextReview: now.subtract(const Duration(minutes: 1)),
          ),
          now,
        ),
        isFalse,
      );
    });
  });

  group('bringProblemCardToToday', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    late TestIsarHarness harness;

    setUp(() async {
      harness = await openTestIsarHarness(<CollectionSchema<dynamic>>[
        DeckSettingsSchema,
        FlashcardSchema,
      ]);
    });

    tearDown(() async {
      await harness.dispose();
    });

    test('updates nextReview to now for review cards', () async {
      final card = Flashcard()
        ..originalId = '1'
        ..isoCode = 'en'
        ..packName = 'Demo'
        ..cardType = 'en_recog'
        ..question = 'Future card'
        ..answer = 'A'
        ..state = CardState.review
        ..nextReview = DateTime(2026, 4, 20);
      await harness.isar.writeTxn(() async {
        await harness.isar.flashcards.put(card);
      });

      final updated = await bringProblemCardToToday(
        harness.isar,
        card.id,
        now: DateTime(2026, 4, 14, 12),
      );

      expect(updated, isNotNull);
      expect(updated!.nextReview, DateTime(2026, 4, 14, 12));

      final persisted = await harness.isar.flashcards.get(card.id);
      expect(persisted!.nextReview, DateTime(2026, 4, 14, 12));
    });

    test('ignores new cards', () async {
      final card = Flashcard()
        ..originalId = '2'
        ..isoCode = 'en'
        ..packName = 'Demo'
        ..cardType = 'en_recog'
        ..question = 'New card'
        ..answer = 'B'
        ..state = CardState.newCard
        ..nextReview = DateTime(2026, 4, 20);
      await harness.isar.writeTxn(() async {
        await harness.isar.flashcards.put(card);
      });

      final updated = await bringProblemCardToToday(
        harness.isar,
        card.id,
        now: DateTime(2026, 4, 14, 12),
      );

      expect(updated, isNull);
      final persisted = await harness.isar.flashcards.get(card.id);
      expect(persisted!.nextReview, DateTime(2026, 4, 20));
    });
  });
}

DeckCardInsight _insight({
  required CardState state,
  required DateTime nextReview,
}) {
  return DeckCardInsight(
    id: 1,
    question: 'Card',
    cardType: 'en_recog',
    state: state,
    nextReview: nextReview,
    lastReview: DateTime(2026, 4, 10),
    lifetimeReviewCount: 4,
    lifetimeCorrectCount: 2,
    lifetimeWrongCount: 2,
    totalStudyTimeMs: 30000,
    consecutiveLapses: 1,
    overdueDays: 0,
    averageStudyTimeMs: 7500,
    difficultyScore: 25,
    problemTags: const <String>['low_accuracy'],
  );
}
