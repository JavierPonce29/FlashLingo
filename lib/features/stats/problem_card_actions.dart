import 'package:isar/isar.dart';

import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/features/stats/stats_provider.dart';

bool canBringProblemCardToToday(DeckCardInsight card, DateTime now) {
  return card.state != CardState.newCard && card.nextReview.isAfter(now);
}

Future<Flashcard?> bringProblemCardToToday(
  Isar isar,
  int cardId, {
  DateTime? now,
}) async {
  final flashcard = await isar.flashcards.get(cardId);
  if (flashcard == null || flashcard.state == CardState.newCard) {
    return null;
  }

  final reviewTime = now ?? DateTime.now();
  await isar.writeTxn(() async {
    flashcard.nextReview = reviewTime;
    await isar.flashcards.put(flashcard);
  });
  return flashcard;
}
