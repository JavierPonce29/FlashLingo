import 'dart:collection';
import 'dart:math';

import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';

const int _defaultReviewShuffleWindow = 10;

List<Flashcard> buildStudySessionCards({
  required DeckSettings settings,
  required List<Flashcard> reviews,
  required List<Flashcard> newCards,
  Random? random,
  bool randomizeReviews = true,
  bool avoidSiblingAdjacency = true,
}) {
  final orderedReviews = randomizeReviews
      ? lightlyMixScheduledReviewCards(reviews, random: random)
      : List<Flashcard>.from(reviews);
  final mixed = _mergeStudyCardsByMode(
    settings: settings,
    reviews: orderedReviews,
    newCards: newCards,
  );
  if (!avoidSiblingAdjacency) {
    return mixed;
  }
  return spreadSiblingCards(mixed);
}

List<Flashcard> lightlyMixScheduledReviewCards(
  List<Flashcard> cards, {
  Random? random,
  int windowSize = _defaultReviewShuffleWindow,
}) {
  if (cards.length < 2) {
    return List<Flashcard>.from(cards);
  }

  final rng = random ?? Random();
  final pending = List<Flashcard>.from(cards);
  final mixed = <Flashcard>[];
  final lookahead = max(2, windowSize);

  while (pending.isNotEmpty) {
    final candidateCount = min(lookahead, pending.length);
    final previousKey = mixed.isEmpty ? null : _siblingKey(mixed.last);
    final eligible = <int>[
      for (int i = 0; i < candidateCount; i++)
        if (previousKey == null || _siblingKey(pending[i]) != previousKey) i,
    ];

    int selectedIndex;
    if (eligible.isNotEmpty) {
      selectedIndex = eligible[rng.nextInt(eligible.length)];
    } else {
      selectedIndex = pending.indexWhere(
        (card) => _siblingKey(card) != previousKey,
        candidateCount,
      );
      if (selectedIndex < 0) {
        selectedIndex = rng.nextInt(candidateCount);
      }
    }

    mixed.add(pending.removeAt(selectedIndex));
  }

  return mixed;
}

List<Flashcard> spreadSiblingCards(List<Flashcard> cards) {
  if (cards.length < 2) {
    return List<Flashcard>.from(cards);
  }

  final groups = <String, ListQueue<_QueuedCard>>{};
  for (int index = 0; index < cards.length; index++) {
    final card = cards[index];
    groups
        .putIfAbsent(_siblingKey(card), ListQueue<_QueuedCard>.new)
        .add(_QueuedCard(originalIndex: index, card: card));
  }

  final result = <Flashcard>[];
  String? previousKey;

  while (groups.isNotEmpty) {
    String? selectedKey;
    _QueuedCard? selected;

    for (final entry in groups.entries) {
      if (entry.value.isEmpty) {
        continue;
      }
      if (entry.key == previousKey && groups.length > 1) {
        continue;
      }
      final candidate = entry.value.first;
      if (selected == null || candidate.originalIndex < selected.originalIndex) {
        selected = candidate;
        selectedKey = entry.key;
      }
    }

    if (selected == null) {
      for (final entry in groups.entries) {
        if (entry.value.isEmpty) {
          continue;
        }
        final candidate = entry.value.first;
        if (selected == null ||
            candidate.originalIndex < selected.originalIndex) {
          selected = candidate;
          selectedKey = entry.key;
        }
      }
    }

    if (selected == null || selectedKey == null) {
      break;
    }

    groups[selectedKey]!.removeFirst();
    if (groups[selectedKey]!.isEmpty) {
      groups.remove(selectedKey);
    }
    result.add(selected.card);
    previousKey = selectedKey;
  }

  return result;
}

int insertRepeatedStudyCard(
  List<Flashcard> queue,
  Flashcard card, {
  required int minimumIndex,
}) {
  final normalizedMinimum = minimumIndex.clamp(0, queue.length);
  final key = _siblingKey(card);

  for (int index = queue.length; index >= normalizedMinimum; index--) {
    final prevKey = index > 0 ? _siblingKey(queue[index - 1]) : null;
    final nextKey = index < queue.length ? _siblingKey(queue[index]) : null;
    if (prevKey != key && nextKey != key) {
      queue.insert(index, card);
      return index;
    }
  }

  queue.insert(queue.length, card);
  return queue.length - 1;
}

List<Flashcard> _mergeStudyCardsByMode({
  required DeckSettings settings,
  required List<Flashcard> reviews,
  required List<Flashcard> newCards,
}) {
  final mode = DeckStudyMixMode.values.contains(settings.studyMixMode)
      ? settings.studyMixMode
      : DeckStudyMixMode.reviewsFirst;

  switch (mode) {
    case DeckStudyMixMode.newFirst:
      return <Flashcard>[...newCards, ...reviews];
    case DeckStudyMixMode.reviewsFirst:
      return <Flashcard>[...reviews, ...newCards];
    case DeckStudyMixMode.interleaveReviewsThenNew:
      return _interleaveChunks(
        first: reviews,
        firstChunkSize: settings.interleaveReviewsCount,
        second: newCards,
        secondChunkSize: settings.interleaveNewCardsCount,
      );
    case DeckStudyMixMode.interleaveNewThenReviews:
      return _interleaveChunks(
        first: newCards,
        firstChunkSize: settings.interleaveNewCardsCount,
        second: reviews,
        secondChunkSize: settings.interleaveReviewsCount,
      );
    default:
      return <Flashcard>[...reviews, ...newCards];
  }
}

List<Flashcard> _interleaveChunks({
  required List<Flashcard> first,
  required int firstChunkSize,
  required List<Flashcard> second,
  required int secondChunkSize,
}) {
  final aChunk = max(1, firstChunkSize);
  final bChunk = max(1, secondChunkSize);
  final result = <Flashcard>[];
  int i = 0;
  int j = 0;
  while (i < first.length || j < second.length) {
    if (i < first.length) {
      final endA = min(i + aChunk, first.length);
      result.addAll(first.sublist(i, endA));
      i = endA;
    }
    if (j < second.length) {
      final endB = min(j + bChunk, second.length);
      result.addAll(second.sublist(j, endB));
      j = endB;
    }
  }
  return result;
}

String _siblingKey(Flashcard card) => card.originalId;

class _QueuedCard {
  final int originalIndex;
  final Flashcard card;

  const _QueuedCard({required this.originalIndex, required this.card});
}
