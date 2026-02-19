import 'dart:async';
import 'dart:math';

import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/models/review_log.dart';
import 'package:flashcards_app/data/models/study_session.dart';

part 'deck_provider.g.dart';

class DeckSummary {
  final String name;
  final int totalCards;
  final int newCardsDue;
  final int reviewCardsDue;

  DeckSummary({
    required this.name,
    required this.totalCards,
    required this.newCardsDue,
    required this.reviewCardsDue,
  });
}

@riverpod
Stream<List<DeckSummary>> decksStream(DecksStreamRef ref) async* {
  final isar = await ref.watch(isarDbProvider.future);

  // Escuchar cambios en Cartas y Configuración a la vez
  final controller = StreamController<void>();

  final subCards = isar.flashcards.watchLazy(fireImmediately: true).listen((_) {
    if (!controller.isClosed) controller.add(null);
  });

  final subSettings = isar.deckSettings.watchLazy(fireImmediately: true).listen(
        (_) {
      if (!controller.isClosed) controller.add(null);
    },
  );

  ref.onDispose(() async {
    await subCards.cancel();
    await subSettings.cancel();
    await controller.close();
  });

  await for (final _ in controller.stream) {
    final now = DateTime.now();

    // Cargar todo (simple y fiable). Si luego quieres optimizar, lo hacemos.
    final cards = await isar.flashcards.where().findAll();
    final settingsList = await isar.deckSettings.where().findAll();

    final settingsMap = <String, DeckSettings>{
      for (final s in settingsList) s.packName: s,
    };

    // Agrupar por packName
    final Map<String, List<Flashcard>> grouped = {};
    for (final card in cards) {
      final name = card.packName;
      if (name.trim().isEmpty) continue;
      grouped.putIfAbsent(name, () => <Flashcard>[]);
      grouped[name]!.add(card);
    }

    // Incluir decks que tengan settings pero 0 cartas (por si existieran)
    for (final s in settingsList) {
      final name = s.packName;
      if (name.trim().isEmpty) continue;
      grouped.putIfAbsent(name, () => <Flashcard>[]);
    }

    final List<DeckSummary> summaries = grouped.entries.map((entry) {
      final name = entry.key;
      final deckCards = entry.value;

      // Settings por deck (si no existe, usamos defaults, pero con packName correcto)
      final settings = settingsMap[name] ?? (DeckSettings()..packName = name);

      // --- LÓGICA DE NUEVAS (verde) ---
      final availableNewInDb =
          deckCards.where((c) => c.state == CardState.newCard).length;

      final last = settings.lastNewCardStudyDate;
      final isSameDay = last != null &&
          last.year == now.year &&
          last.month == now.month &&
          last.day == now.day;

      final seenToday = isSameDay ? settings.newCardsSeenToday : 0;
      final remainingLimit = max(0, settings.newCardsPerDay - seenToday);

      final finalNewCount = min(availableNewInDb, remainingLimit);
      // --------------------------------

      // --- LÓGICA DE REPASOS (azul) ---
      // Incluye nextReview == now como "due"
      final reviewCount = deckCards
          .where((c) => c.state != CardState.newCard && !c.nextReview.isAfter(now))
          .length;

      final limitedReviewCount = min(reviewCount, settings.maxReviewsPerDay);
      // --------------------------------

      return DeckSummary(
        name: name,
        totalCards: deckCards.length,
        newCardsDue: finalNewCount,
        reviewCardsDue: limitedReviewCount,
      );
    }).toList();

    summaries.sort((a, b) => a.name.compareTo(b.name));
    yield summaries;
  }
}

@riverpod
Future<void> deleteDeck(DeleteDeckRef ref, String packName) async {
  final isar = await ref.watch(isarDbProvider.future);

  await isar.writeTxn(() async {
    await isar.flashcards.filter().packNameEqualTo(packName).deleteAll();
    await isar.reviewLogs.filter().packNameEqualTo(packName).deleteAll();
    await isar.deckSettings.filter().packNameEqualTo(packName).deleteAll();
    // ✅ MUY IMPORTANTE: limpiar sesión persistida del mazo
    await isar.studySessions.filter().packNameEqualTo(packName).deleteAll();
  });
}
