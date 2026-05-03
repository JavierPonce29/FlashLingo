import 'dart:math';

import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/features/library/study_queue_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildStudySessionCards', () {
    test('keeps the legacy order when randomization is disabled', () {
      final settings = DeckSettings()
        ..packName = 'Demo'
        ..studyMixMode = DeckStudyMixMode.reviewsFirst;
      final reviews = <Flashcard>[
        _card(id: 1, originalId: 'a', type: 'en_recog', state: CardState.review),
        _card(id: 2, originalId: 'a', type: 'en_prod', state: CardState.review),
      ];
      final newCards = <Flashcard>[
        _card(id: 3, originalId: 'b', type: 'en_recog'),
        _card(id: 4, originalId: 'b', type: 'en_prod'),
      ];

      final queue = buildStudySessionCards(
        settings: settings,
        reviews: reviews,
        newCards: newCards,
        randomizeReviews: false,
        avoidSiblingAdjacency: false,
      );

      expect(queue.map((card) => card.id), <int>[1, 2, 3, 4]);
    });

    test('spreads sibling cards across the final queue when possible', () {
      final settings = DeckSettings()
        ..packName = 'Demo'
        ..studyMixMode = DeckStudyMixMode.reviewsFirst;
      final reviews = <Flashcard>[
        _card(id: 1, originalId: 'a', type: 'en_recog', state: CardState.review),
        _card(id: 2, originalId: 'a', type: 'en_prod', state: CardState.review),
        _card(id: 3, originalId: 'b', type: 'en_recog', state: CardState.review),
      ];
      final newCards = <Flashcard>[
        _card(id: 4, originalId: 'c', type: 'en_recog'),
      ];

      final queue = buildStudySessionCards(
        settings: settings,
        reviews: reviews,
        newCards: newCards,
        randomizeReviews: false,
        avoidSiblingAdjacency: true,
      );

      expect(queue.map((card) => card.id), <int>[1, 3, 2, 4]);
      expect(_hasAdjacentSiblings(queue), isFalse);
    });

    test('adds a light randomization layer to scheduled reviews', () {
      final reviews = <Flashcard>[
        _card(id: 1, originalId: 'a', type: 'en_recog', state: CardState.review),
        _card(id: 2, originalId: 'a', type: 'en_prod', state: CardState.review),
        _card(id: 3, originalId: 'b', type: 'en_recog', state: CardState.review),
        _card(id: 4, originalId: 'c', type: 'en_recog', state: CardState.review),
        _card(id: 5, originalId: 'd', type: 'en_recog', state: CardState.review),
      ];

      final mixed = lightlyMixScheduledReviewCards(
        reviews,
        random: Random(7),
        windowSize: 3,
      );

      expect(mixed.map((card) => card.id), isNot(<int>[1, 2, 3, 4, 5]));
      expect(mixed.map((card) => card.id).toSet(), <int>{1, 2, 3, 4, 5});
      expect(_hasAdjacentSiblings(mixed), isFalse);
    });
  });

  group('insertRepeatedStudyCard', () {
    test('uses the latest safe slot instead of appending next to a sibling', () {
      final queue = <Flashcard>[
        _card(id: 1, originalId: 'a', type: 'en_recog', state: CardState.review),
        _card(id: 2, originalId: 'b', type: 'en_recog', state: CardState.review),
        _card(id: 3, originalId: 'c', type: 'en_recog', state: CardState.review),
        _card(id: 4, originalId: 'a', type: 'en_prod', state: CardState.review),
      ];
      final repeated = _card(
        id: 1,
        originalId: 'a',
        type: 'en_recog',
        state: CardState.review,
      );

      final insertedIndex = insertRepeatedStudyCard(
        queue,
        repeated,
        minimumIndex: 1,
      );

      expect(insertedIndex, 2);
      expect(queue.map((card) => card.id), <int>[1, 2, 1, 3, 4]);
      expect(_hasAdjacentSiblings(queue), isFalse);
    });

    test('falls back to the end when no safe slot exists', () {
      final queue = <Flashcard>[
        _card(id: 1, originalId: 'a', type: 'en_recog', state: CardState.review),
      ];

      final insertedIndex = insertRepeatedStudyCard(
        queue,
        _card(id: 1, originalId: 'a', type: 'en_recog', state: CardState.review),
        minimumIndex: 1,
      );

      expect(insertedIndex, 1);
      expect(queue.map((card) => card.id), <int>[1, 1]);
    });
  });
}

bool _hasAdjacentSiblings(List<Flashcard> cards) {
  for (int i = 1; i < cards.length; i++) {
    if (cards[i - 1].originalId == cards[i].originalId) {
      return true;
    }
  }
  return false;
}

Flashcard _card({
  required int id,
  required String originalId,
  required String type,
  CardState state = CardState.newCard,
}) {
  return Flashcard()
    ..id = id
    ..originalId = originalId
    ..isoCode = 'en'
    ..packName = 'Demo'
    ..cardType = type
    ..question = 'Q$id'
    ..answer = 'A$id'
    ..state = state
    ..nextReview = DateTime(2026, 5, 3, 4);
}
