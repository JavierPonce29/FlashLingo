import 'dart:async';

import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/models/review_log.dart';
import 'package:flashcards_app/data/models/study_session.dart';
import 'package:flashcards_app/data/utils/study_day.dart';
part 'deck_provider.g.dart';

class DeckSummary {
  final String packName;
  final String? iconUri;
  final int newCardsDue;
  final int firstStepDue;
  final int reviewCardsDue;
  DeckSummary({
    required this.packName,
    required this.iconUri,
    required this.newCardsDue,
    required this.firstStepDue,
    required this.reviewCardsDue,
  });
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
      // Reset diario newCardsSeenToday (basado en cutoff configurable)
      final currentLabel = StudyDay.label(now, s);
      final last = s.lastNewCardStudyDate;
      final lastLabel = last == null ? null : StudyDay.label(last, s);
      final bool sameStudyDay = lastLabel != null &&
          lastLabel.year == currentLabel.year &&
          lastLabel.month == currentLabel.month &&
          lastLabel.day == currentLabel.day;
      if (!sameStudyDay) {
        s.newCardsSeenToday = 0;
        // Guardamos timestamp real; luego se etiqueta con StudyDay.label().
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

      // ========== NARANJA (primer paso TOTAL, aunque no esta vencido) ==========
      final firstStepTotal = await isar.flashcards
          .filter()
          .packNameEqualTo(s.packName)
          .stateEqualTo(CardState.learning)
          .and()
          .learningStepEqualTo(0)
          .count();

      // ========== VERDE (repasos vencidos, excluyendo primer paso vencido) ==========
      final dueNonNew = await isar.flashcards
          .filter()
          .packNameEqualTo(s.packName)
          .not()
          .stateEqualTo(CardState.newCard)
          .and()
          .nextReviewLessThan(now.add(const Duration(seconds: 1))) // inclusivo
          .limit(s.maxReviewsPerDay)
          .findAll();

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
          iconUri: s.deckIconUri,
          newCardsDue: newCount,
          firstStepDue: firstStepTotal,
          reviewCardsDue: reviewDue,
        ),
      );
    }
    return summaries;
  }

  yield await compute();
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

@Riverpod(keepAlive: true)
Future<void> renameDeck(
    RenameDeckRef ref,
    String oldPackName,
    String newPackName,
    ) async {
  final isar = await ref.watch(isarDbProvider.future);

  final oldName = oldPackName.trim();
  final newName = newPackName.trim();

  if (oldName.isEmpty) {
    throw ArgumentError('El nombre actual del mazo es invalido.');
  }
  if (newName.isEmpty) {
    throw ArgumentError('El nuevo nombre no puede estar vacio.');
  }
  if (oldName == newName) return;

  // Evitar colisiones
  final existingSettings =
  await isar.deckSettings.filter().packNameEqualTo(newName).findFirst();
  if (existingSettings != null) {
    throw StateError("Ya existe un mazo con el nombre '$newName'.");
  }

  final existingGhost = await isar.flashcards
      .filter()
      .packNameEqualTo(newName)
      .limit(1)
      .count();
  if (existingGhost > 0) {
    throw StateError(
      "Ya existen tarjetas con el packName '$newName'. "
          "Elige otro nombre o elimina ese mazo primero.",
    );
  }

  await isar.writeTxn(() async {
    final settings = await isar.deckSettings
        .filter()
        .packNameEqualTo(oldName)
        .findFirst();

    if (settings == null) {
      throw StateError("No se encontro el mazo '$oldName'.");
    }

    // 1) DeckSettings
    settings.packName = newName;
    await isar.deckSettings.put(settings);

    // 2) Flashcards
    final cards =
    await isar.flashcards.filter().packNameEqualTo(oldName).findAll();
    for (final c in cards) {
      c.packName = newName;
    }
    if (cards.isNotEmpty) {
      await isar.flashcards.putAll(cards);
    }

    // 3) ReviewLogs
    final logs =
    await isar.reviewLogs.filter().packNameEqualTo(oldName).findAll();
    for (final l in logs) {
      l.packName = newName;
    }
    if (logs.isNotEmpty) {
      await isar.reviewLogs.putAll(logs);
    }

    // 4) StudySession
    final session =
    await isar.studySessions.filter().packNameEqualTo(oldName).findFirst();
    if (session != null) {
      session.packName = newName;
      await isar.studySessions.put(session);
    }
  });
}

