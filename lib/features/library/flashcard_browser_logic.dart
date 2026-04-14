import 'package:flashcards_app/data/models/flashcard.dart';

enum FlashcardBrowserSortMode {
  original,
  hardest,
  overdue,
  nextReview,
  lastReview,
}

class FlashcardBrowserFilters {
  const FlashcardBrowserFilters({
    this.query = '',
    this.showRecog = true,
    this.showProd = true,
    this.stateFilter,
    this.sortMode = FlashcardBrowserSortMode.original,
    this.highlightedId,
  });

  final String query;
  final bool showRecog;
  final bool showProd;
  final CardState? stateFilter;
  final FlashcardBrowserSortMode sortMode;
  final int? highlightedId;
}

List<Flashcard> buildVisibleFlashcards(
  List<Flashcard> allCards, {
  required FlashcardBrowserFilters filters,
  DateTime? now,
}) {
  final normalizedQuery = filters.query.trim().toLowerCase();
  final visible = allCards.where((card) {
    if (!filters.showRecog && card.cardType.endsWith('recog')) {
      return false;
    }
    if (!filters.showProd && card.cardType.endsWith('prod')) {
      return false;
    }
    if (filters.stateFilter != null && card.state != filters.stateFilter) {
      return false;
    }

    if (normalizedQuery.isEmpty) {
      return true;
    }

    final question = card.question.toLowerCase();
    final answer = card.answer.toLowerCase();
    final sentence = (card.sentence ?? '').toLowerCase();
    final translation = (card.translation ?? '').toLowerCase();
    return question.contains(normalizedQuery) ||
        answer.contains(normalizedQuery) ||
        sentence.contains(normalizedQuery) ||
        translation.contains(normalizedQuery);
  }).toList();

  sortVisibleFlashcards(
    visible,
    sortMode: filters.sortMode,
    highlightedId: filters.highlightedId,
    now: now,
  );
  return visible;
}

void sortVisibleFlashcards(
  List<Flashcard> cards, {
  required FlashcardBrowserSortMode sortMode,
  required int? highlightedId,
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();
  switch (sortMode) {
    case FlashcardBrowserSortMode.original:
      cards.sort((a, b) => a.originalId.compareTo(b.originalId));
      break;
    case FlashcardBrowserSortMode.hardest:
      cards.sort((a, b) => difficultyScore(b).compareTo(difficultyScore(a)));
      break;
    case FlashcardBrowserSortMode.overdue:
      cards.sort(
        (a, b) => overdueDays(
          b,
          effectiveNow,
        ).compareTo(overdueDays(a, effectiveNow)),
      );
      break;
    case FlashcardBrowserSortMode.nextReview:
      cards.sort((a, b) => a.nextReview.compareTo(b.nextReview));
      break;
    case FlashcardBrowserSortMode.lastReview:
      cards.sort((a, b) => b.lastReview.compareTo(a.lastReview));
      break;
  }

  if (highlightedId == null) {
    return;
  }
  final index = cards.indexWhere((card) => card.id == highlightedId);
  if (index <= 0) {
    return;
  }
  final highlighted = cards.removeAt(index);
  cards.insert(0, highlighted);
}

int difficultyScore(Flashcard card) {
  final reviews = card.lifetimeReviewCount;
  final accuracy = reviews == 0 ? 0.0 : card.lifetimeCorrectCount / reviews;
  return (((1 - accuracy) * 50) +
          (card.consecutiveLapses * 10) +
          (card.decayRate * 100))
      .round();
}

int overdueDays(Flashcard card, DateTime now) {
  if (!card.nextReview.isBefore(now)) {
    return 0;
  }
  return now.difference(card.nextReview).inDays;
}
