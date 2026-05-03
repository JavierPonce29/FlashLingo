import 'dart:collection';
import 'dart:math';

import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';

const int _defaultReviewShuffleWindow = 10;
const int _minTimedRepeatAnswerTimeMs = 5000;
const int _maxTimedRepeatAnswerTimeMs = 120000;

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
  final safeIndex = _findLatestSafeInsertionIndex(queue, card, normalizedMinimum);
  if (safeIndex != null) {
    queue.insert(safeIndex, card);
    return safeIndex;
  }

  queue.insert(queue.length, card);
  return queue.length - 1;
}

int insertTimedRepeatStudyCard(
  List<Flashcard> queue,
  Flashcard card, {
  required int minimumIndex,
  required DeckSettings settings,
  required int delayMinutes,
  required int averageAnswerTimeMs,
}) {
  final normalizedMinimum = minimumIndex.clamp(0, queue.length);
  final normalizedDelayMinutes = max(1, delayMinutes);
  final normalizedAverageMs = averageAnswerTimeMs
      .clamp(_minTimedRepeatAnswerTimeMs, _maxTimedRepeatAnswerTimeMs)
      .toInt();
  var cardsUntilDue = max(
    1,
    (normalizedDelayMinutes * Duration.millisecondsPerMinute / normalizedAverageMs)
        .ceil(),
  );

  if (isInterleaveStudyMixMode(settings.studyMixMode)) {
    final blockSize =
        max(1, settings.interleaveReviewsCount).toInt() +
        max(1, settings.interleaveNewCardsCount).toInt();
    cardsUntilDue = ((cardsUntilDue + blockSize - 1) ~/ blockSize) * blockSize;
  }

  final preferredIndex = min(queue.length, normalizedMinimum + cardsUntilDue);
  final safeIndex = _findFirstSafeInsertionIndex(
    queue,
    card,
    preferredIndex,
    queue.length,
  );
  if (safeIndex != null) {
    queue.insert(safeIndex, card);
    return safeIndex;
  }

  return insertRepeatedStudyCard(queue, card, minimumIndex: normalizedMinimum);
}

bool isInterleaveStudyMixMode(String mixMode) {
  return mixMode == DeckStudyMixMode.interleaveReviewsThenNew ||
      mixMode == DeckStudyMixMode.interleaveNewThenReviews;
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

int? _findLatestSafeInsertionIndex(
  List<Flashcard> queue,
  Flashcard card,
  int minimumIndex,
) {
  for (int index = queue.length; index >= minimumIndex; index--) {
    if (_isSafeInsertionIndex(queue, card, index)) {
      return index;
    }
  }
  return null;
}

int? _findFirstSafeInsertionIndex(
  List<Flashcard> queue,
  Flashcard card,
  int fromIndex,
  int toIndex,
) {
  for (int index = fromIndex; index <= toIndex; index++) {
    if (_isSafeInsertionIndex(queue, card, index)) {
      return index;
    }
  }
  return null;
}

bool _isSafeInsertionIndex(List<Flashcard> queue, Flashcard card, int index) {
  final key = _siblingKey(card);
  final prevKey = index > 0 ? _siblingKey(queue[index - 1]) : null;
  final nextKey = index < queue.length ? _siblingKey(queue[index]) : null;
  return prevKey != key && nextKey != key;
}

class _QueuedCard {
  final int originalIndex;
  final Flashcard card;

  const _QueuedCard({required this.originalIndex, required this.card});
}
