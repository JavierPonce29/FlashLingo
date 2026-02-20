import 'dart:async';

import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/models/review_log.dart';
import 'package:flashcards_app/data/models/study_session.dart';

part 'deck_provider.g.dart';

class DeckSummary {
  final String packName;

  /// Nuevas que aún pueden entrar hoy (limitadas por cuota restante).
  final int newCardsDue;

  /// Cartas en “primer paso” (learningStep==0), aunque aún no estén vencidas.
  /// Esto es exactamente lo que quieres mostrar en naranja.
  final int firstStepDue;

  /// Repasos vencidos (no-new) excluyendo las del primer paso vencidas,
  /// respetando maxReviewsPerDay.
  final int reviewCardsDue;

  DeckSummary({
    required this.packName,
    required this.newCardsDue,
    required this.firstStepDue,
    required this.reviewCardsDue,
  });

  // Compatibilidad con HomePage (usa deck.name)
  String get name => packName;
}

@Riverpod(keepAlive: true)
Stream<List<DeckSummary>> decksStream(DecksStreamRef ref) async* {
  final isar = await ref.watch(isarDbProvider.future);

  Future<List<DeckSummary>> compute() async {
    final now = DateTime.now();

    final decks = await isar.deckSettings.where().findAll();
    final summaries = <DeckSummary>[];

    for (final s in decks) {
      // Reset diario newCardsSeenToday
      final last = s.lastNewCardStudyDate;
      final bool sameDay = last != null &&
          last.year == now.year &&
          last.month == now.month &&
          last.day == now.day;

      if (!sameDay) {
        s.newCardsSeenToday = 0;
        s.lastNewCardStudyDate = now;
        await isar.writeTxn(() async {
          await isar.deckSettings.put(s);
        });
      }

      // ========== AZUL (nuevas que pueden entrar hoy) ==========
      final remainingQuota =
      (s.newCardsPerDay - s.newCardsSeenToday).clamp(0, 999999);

      final newCount = remainingQuota > 0
          ? await isar.flashcards
          .filter()
          .packNameEqualTo(s.packName)
          .stateEqualTo(CardState.newCard)
          .limit(remainingQuota)
          .count()
          : 0;

      // ========== NARANJA (primer paso TOTAL, aunque no esté vencido) ==========
      // Cartas en learning con learningStep==0 (ya tuvieron el primer "Bien")
      final firstStepTotal = await isar.flashcards
          .filter()
          .packNameEqualTo(s.packName)
          .stateEqualTo(CardState.learning)
          .and()
          .learningStepEqualTo(0)
          .count();

      // ========== VERDE (repasos vencidos, excluyendo primer paso vencido) ==========
      // Primero traemos lo vencido “no-new” con límite.
      final dueNonNew = await isar.flashcards
          .filter()
          .packNameEqualTo(s.packName)
          .not()
          .stateEqualTo(CardState.newCard)
          .and()
      // lessThan(now) deja fuera igualdad exacta. Para ser inclusivos:
          .nextReviewLessThan(now.add(const Duration(seconds: 1)))
          .limit(s.maxReviewsPerDay)
          .findAll();

      // Cuántas de esas vencidas pertenecen al primer paso (para no contarlas también en verde)
      int firstStepDueNow = 0;
      for (final c in dueNonNew) {
        if (c.state == CardState.learning && c.learningStep == 0) {
          firstStepDueNow++;
        }
      }

      final reviewDue = dueNonNew.length - firstStepDueNow;

      summaries.add(
        DeckSummary(
          packName: s.packName,
          newCardsDue: newCount,
          firstStepDue: firstStepTotal, // <- naranja (total)
          reviewCardsDue: reviewDue, // <- verde (due sin primer paso)
        ),
      );
    }

    return summaries;
  }

  // Emitir una primera vez
  yield await compute();

  // Watchers sin StreamGroup
  final controller = StreamController<void>(sync: true);

  final sub1 = isar.flashcards.watchLazy().listen((_) {
    if (!controller.isClosed) controller.add(null);
  });
  final sub2 = isar.deckSettings.watchLazy().listen((_) {
    if (!controller.isClosed) controller.add(null);
  });

  ref.onDispose(() async {
    await sub1.cancel();
    await sub2.cancel();
    await controller.close();
  });

  await for (final _ in controller.stream) {
    yield await compute();
  }
}

@Riverpod(keepAlive: true)
Future<void> deleteDeck(DeleteDeckRef ref, String packName) async {
  final isar = await ref.watch(isarDbProvider.future);

  await isar.writeTxn(() async {
    await isar.flashcards.filter().packNameEqualTo(packName).deleteAll();
    await isar.reviewLogs.filter().packNameEqualTo(packName).deleteAll();
    await isar.deckSettings.filter().packNameEqualTo(packName).deleteAll();
    await isar.studySessions.filter().packNameEqualTo(packName).deleteAll();
  });
}