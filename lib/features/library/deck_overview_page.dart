import 'package:isar/isar.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
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

    // 1) Cargar configuración (si no existe, crearla correctamente con packName)
    DeckSettings? settings = await isar.deckSettings
        .filter()
        .packNameEqualTo(packName)
        .findFirst();

    if (settings == null) {
      settings = DeckSettings()..packName = packName;

      // Guardar inmediatamente para evitar settings "fantasma" sin packName
      await isar.writeTxn(() async {
        await isar.deckSettings.put(settings!);
      });
    }

    // --- GESTIÓN DE LÍMITE DIARIO ---
    // Verificar si es un nuevo día para resetear el contador en la DB
    final last = settings.lastNewCardStudyDate;
    final bool isSameDay =
        last != null &&
        last.year == now.year &&
        last.month == now.month &&
        last.day == now.day;

    if (!isSameDay) {
      settings.newCardsSeenToday = 0;
      settings.lastNewCardStudyDate = now;

      await isar.writeTxn(() async {
        await isar.deckSettings.put(settings!);
      });
    }

    // 2) Calcular CUPO RESTANTE
    // Si límite es 20 y ya vi 5, me quedan 15. Si ya vi 20, me quedan 0.
    final int remainingQuota = max(
      0,
      settings.newCardsPerDay - settings.newCardsSeenToday,
    );
    // --------------------------------

    // 3) Obtener REPASOS (Limitados)
    final reviews = await isar.flashcards
        .filter()
        .packNameEqualTo(packName)
        .not()
        .stateEqualTo(CardState.newCard)
        .and()
        .nextReviewLessThan(now)
        .limit(settings.maxReviewsPerDay)
        .findAll();

    reviews.shuffle();

    // 4) Obtener NUEVAS (Solo si queda cupo)
    List<Flashcard> newCardsOrdered = [];

    if (remainingQuota > 0) {
      final newCardsRaw = await isar.flashcards
          .filter()
          .packNameEqualTo(packName)
          .stateEqualTo(CardState.newCard)
          .sortByOriginalId()
          .limit(
            remainingQuota,
          ) // Pedimos solo las que faltan para llegar al límite
          .findAll();

      // Ordenar Recog -> Prod
      final newRecog = newCardsRaw
          .where((c) => c.cardType.endsWith('recog'))
          .toList();
      final newProd = newCardsRaw
          .where((c) => c.cardType.endsWith('prod'))
          .toList();
      newCardsOrdered = [...newRecog, ...newProd];
    }

    // 5) Unir sesión
    final sessionCards = [...reviews, ...newCardsOrdered];

    if (!context.mounted) return;

    if (sessionCards.isEmpty) {
      // Mensaje específico si es por límite diario
      String message = "¡Todo al día! No hay cartas pendientes.";

      if (remainingQuota == 0 && settings.newCardsPerDay > 0) {
        message = "¡Límite diario de nuevas alcanzado!";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StudyPage(cards: sessionCards)),
    );
  }
}
