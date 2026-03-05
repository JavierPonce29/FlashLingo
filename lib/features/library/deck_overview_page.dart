import 'package:isar/isar.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/models/study_session.dart';
import 'package:flashcards_app/data/utils/study_day.dart';
import 'package:flashcards_app/features/study_session/study_page.dart';

class DeckOverviewPage extends ConsumerWidget {
  final String packName;
  const DeckOverviewPage({super.key, required this.packName});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(packName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              packName,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              "Preparado para estudiar",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _startSession(context, ref),
              child: const Text(
                "EMPEZAR A ESTUDIAR",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startSession(BuildContext context, WidgetRef ref) async {
    final isar = await ref.read(isarDbProvider.future);
    final now = DateTime.now();
    // 1) Cargar configuracion
    DeckSettings? settings = await isar.deckSettings
        .filter()
        .packNameEqualTo(packName)
        .findFirst();
    if (settings == null) {
      settings = DeckSettings()..packName = packName;
      await isar.writeTxn(() async {
        await isar.deckSettings.put(settings!);
      });
    }
    // --- GESTION DE LIMITE DIARIO ---
    final currentLabel = StudyDay.label(now, settings);
    final last = settings.lastNewCardStudyDate;
    final lastLabel = last == null ? null : StudyDay.label(last, settings);
    final bool isSameStudyDay = lastLabel != null &&
        lastLabel.year == currentLabel.year &&
        lastLabel.month == currentLabel.month &&
        lastLabel.day == currentLabel.day;

    if (!isSameStudyDay) {
      settings.newCardsSeenToday = 0;
      // Guardamos timestamp real; luego se etiqueta con StudyDay.label().
      settings.lastNewCardStudyDate = now;

      await isar.writeTxn(() async {
        await isar.deckSettings.put(settings!);
      });
    }
    // 2) Si existe una sesion guardada DEL MISMO DIA (de estudio), reanudarla.
    final existingSession =
    await isar.studySessions.filter().packNameEqualTo(packName).findFirst();

    if (existingSession != null) {
      if (_isSameDay(existingSession.sessionDay, currentLabel)) {
        final resumedCards =
        await _loadCardsFromSession(isar, existingSession.queueCardIds);
        // Si la sesion queda vacia/corrupta, la eliminamos y continuamos con una nueva.
        if (resumedCards.isNotEmpty) {
          final savedIndex = existingSession.currentIndex;
          final canResume = savedIndex >= 0 && savedIndex < resumedCards.length;
          if (canResume) {
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudyPage(
                  packName: packName,
                  cards: resumedCards,
                  initialIndex: savedIndex,
                ),
              ),
            );
            return;
          }
        }
        // Session finished or corrupted: remove and build a fresh one.
        await isar.writeTxn(() async {
          await isar.studySessions.delete(existingSession.id);
        });
      } else {
        // Sesion vieja: eliminar para evitar mezclar dias de estudio.
        await isar.writeTxn(() async {
          await isar.studySessions.delete(existingSession.id);
        });
      }
    }
    // 3) Calcular CUPO RESTANTE de nuevas
    final int remainingQuota =
    max(0, settings.newCardsPerDay - settings.newCardsSeenToday);
    // 4) Obtener REPASOS (Limitados) (inclusivo)
    final reviews = await isar.flashcards
        .filter()
        .packNameEqualTo(packName)
        .not()
        .stateEqualTo(CardState.newCard)
        .and()
        .nextReviewLessThan(now.add(const Duration(seconds: 1)))
        .limit(settings.maxReviewsPerDay)
        .findAll();
    reviews.shuffle();
    // 5) Obtener NUEVAS (Solo si queda cupo)
    List<Flashcard> newCardsOrdered = [];
    if (remainingQuota > 0) {
      final newCardsRaw = await isar.flashcards
          .filter()
          .packNameEqualTo(packName)
          .stateEqualTo(CardState.newCard)
          .sortByOriginalId()
          .limit(remainingQuota)
          .findAll();
      // Ordenar Recog -> Prod
      final newRecog =
      newCardsRaw.where((c) => c.cardType.endsWith('recog')).toList();
      final newProd =
      newCardsRaw.where((c) => c.cardType.endsWith('prod')).toList();
      newCardsOrdered = [...newRecog, ...newProd];
    }
    // 6) Unir sesion segun configuracion de mezcla
    final sessionCards = _buildSessionCards(
      settings: settings,
      reviews: reviews,
      newCards: newCardsOrdered,
    );
    if (!context.mounted) return;
    if (sessionCards.isEmpty) {
      String message = "Todo al dia! No hay cartas pendientes.";
      if (remainingQuota == 0 && settings.newCardsPerDay > 0) {
        message = "Limite diario de nuevas alcanzado!";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      return;
    }
    // 7) Crear StudySession persistida
    final session = StudySession()
      ..packName = packName
      ..queueCardIds = sessionCards.map((c) => c.id).toList()
      ..currentIndex = 0
      ..sessionDay = currentLabel
      ..lastUpdated = now;
    await isar.writeTxn(() async {
      await isar.studySessions.put(session);
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudyPage(
          packName: packName,
          cards: sessionCards,
          initialIndex: 0,
        ),
      ),
    );
  }
  List<Flashcard> _buildSessionCards({
    required DeckSettings settings,
    required List<Flashcard> reviews,
    required List<Flashcard> newCards,
  }) {
    final mode = DeckStudyMixMode.values.contains(settings.studyMixMode)
        ? settings.studyMixMode
        : DeckStudyMixMode.reviewsFirst;

    switch (mode) {
      case DeckStudyMixMode.newFirst:
        return [...newCards, ...reviews];

      case DeckStudyMixMode.reviewsFirst:
        return [...reviews, ...newCards];

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
        return [...reviews, ...newCards];
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
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<List<Flashcard>> _loadCardsFromSession(
      Isar isar,
      List<int> queueIds,
      ) async {
    if (queueIds.isEmpty) return [];
    final uniqueIds = <int>{...queueIds}.toList();
    final cards = await isar.flashcards.getAll(uniqueIds);
    final map = <int, Flashcard>{};
    for (final c in cards) {
      if (c != null) map[c.id] = c;
    }
    // Reconstruir en el orden original (permitiendo duplicados)
    final ordered = <Flashcard>[];
    for (final id in queueIds) {
      final c = map[id];
      if (c != null) ordered.add(c);
    }
    return ordered;
  }
}

