import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/features/library/flashcard_browser_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildVisibleFlashcards', () {
    test('applies the initial query across question and answer fields', () {
      final cards = <Flashcard>[
        _card(
          id: 1,
          originalId: 'b',
          question: 'Difficult card',
          answer: 'Tarjeta dificil',
        ),
        _card(
          id: 2,
          originalId: 'a',
          question: 'Unrelated card',
          answer: 'Otra',
        ),
      ];

      final visible = buildVisibleFlashcards(
        cards,
        filters: const FlashcardBrowserFilters(query: 'difficult'),
      );

      expect(visible.map((card) => card.id), <int>[1]);
    });

    test('promotes the highlighted card to the top after sorting', () {
      final cards = <Flashcard>[
        _card(
          id: 1,
          originalId: 'a',
          question: 'Earlier',
          answer: 'A',
          nextReview: DateTime(2026, 4, 12),
        ),
        _card(
          id: 2,
          originalId: 'b',
          question: 'Highlighted',
          answer: 'B',
          nextReview: DateTime(2026, 4, 20),
        ),
      ];

      final visible = buildVisibleFlashcards(
        cards,
        filters: const FlashcardBrowserFilters(
          sortMode: FlashcardBrowserSortMode.nextReview,
          highlightedId: 2,
        ),
      );

      expect(visible.first.id, 2);
      expect(visible.last.id, 1);
    });

    test('sorts hardest cards first using accuracy, lapses and decay', () {
      final easy = _card(
        id: 1,
        originalId: 'a',
        question: 'Easy',
        answer: 'A',
        lifetimeReviewCount: 10,
        lifetimeCorrectCount: 9,
        consecutiveLapses: 0,
        decayRate: 0.01,
      );
      final hard = _card(
        id: 2,
        originalId: 'b',
        question: 'Hard',
        answer: 'B',
        lifetimeReviewCount: 10,
        lifetimeCorrectCount: 4,
        consecutiveLapses: 2,
        decayRate: 0.2,
      );

      final visible = buildVisibleFlashcards(
        <Flashcard>[easy, hard],
        filters: const FlashcardBrowserFilters(
          sortMode: FlashcardBrowserSortMode.hardest,
        ),
      );

      expect(visible.first.id, 2);
      expect(difficultyScore(hard), greaterThan(difficultyScore(easy)));
    });
  });
}

Flashcard _card({
  required int id,
  required String originalId,
  required String question,
  required String answer,
  DateTime? nextReview,
  int lifetimeReviewCount = 0,
  int lifetimeCorrectCount = 0,
  int consecutiveLapses = 0,
  double decayRate = 0.015,
}) {
  return Flashcard()
    ..id = id
    ..originalId = originalId
    ..isoCode = 'en'
    ..packName = 'Demo'
    ..cardType = 'en_recog'
    ..question = question
    ..answer = answer
    ..state = CardState.review
    ..nextReview = nextReview ?? DateTime(2026, 4, 15)
    ..lastReview = DateTime(2026, 4, 10)
    ..lifetimeReviewCount = lifetimeReviewCount
    ..lifetimeCorrectCount = lifetimeCorrectCount
    ..consecutiveLapses = consecutiveLapses
    ..decayRate = decayRate;
}
