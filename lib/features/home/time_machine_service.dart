import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/utils/review_daily_limit.dart';

Future<void> applyTimeTravel(WidgetRef ref) async {
  final isar = await ref.read(isarDbProvider.future);
  final allCards = await isar.flashcards.where().findAll();

  await isar.writeTxn(() async {
    for (final card in allCards) {
      card.nextReview = card.nextReview.subtract(const Duration(days: 1));
      if (!isZeroDateTime(card.reviewPriorityAnchor)) {
        card.reviewPriorityAnchor = card.reviewPriorityAnchor.subtract(
          const Duration(days: 1),
        );
      }
      card.manualReviewOverrideDay = DateTime.fromMillisecondsSinceEpoch(0);
      await isar.flashcards.put(card);
    }

    final allSettings = await isar.deckSettings.where().findAll();
    for (final settings in allSettings) {
      settings.newCardsSeenToday = 0;
      await isar.deckSettings.put(settings);
    }
  });
}
