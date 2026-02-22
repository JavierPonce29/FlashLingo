import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/features/home/home_import_helper.dart';
import 'package:flashcards_app/features/library/deck_overview_page.dart';
import 'package:flashcards_app/features/library/deck_provider.dart';
import 'package:flashcards_app/features/library/deck_settings_page.dart';
import 'package:flashcards_app/features/library/flashcard_browser_page.dart';
import 'package:flashcards_app/features/stats/stats_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(decksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Anki Flutter"),
        elevation: 2,
        actions: [
          // BOTÓN DEBUG: máquina del tiempo
          IconButton(
            icon: const Icon(Icons.history_toggle_off),
            tooltip: "Simular paso del tiempo (+1 día)",
            onPressed: () => _showTimeMachineDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Importar Mazo",
            onPressed: () => HomeImportHelper.pickAndImportFile(context, ref),
          ),
        ],
      ),
      body: decksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (decks) {
          if (decks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.library_books, size: 64, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    "No tienes mazos aún.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => HomeImportHelper.pickAndImportFile(context, ref),
                    icon: const Icon(Icons.file_upload),
                    label: const Text("Importar .flashjp / .zip"),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return _buildDeckItem(context, ref, deck);
            },
          );
        },
      ),
    );
  }

  Widget _buildDeckItem(BuildContext context, WidgetRef ref, DeckSummary deck) {
    // Compatibilidad: si tu DeckSummary aún no tiene firstStepDue en algún punto,
    // este acceso dinámico evita romper la UI.
    int firstStepDue = 0;
    try {
      final dynamic d = deck;
      final dynamic v = d.firstStepDue;
      if (v is int) firstStepDue = v;
    } catch (_) {
      firstStepDue = 0;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        title: Text(
          deck.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Row(
          children: [
            if (deck.newCardsDue > 0)
              Text(
                "Nuevas: ${deck.newCardsDue}  ",
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (firstStepDue > 0)
              Text(
                "Paso 1: $firstStepDue  ",
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (deck.reviewCardsDue > 0)
              Text(
                "Repaso: ${deck.reviewCardsDue}",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (deck.newCardsDue == 0 &&
                firstStepDue == 0 &&
                deck.reviewCardsDue == 0)
              const Text("¡Al día!", style: TextStyle(color: Colors.grey)),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DeckOverviewPage(packName: deck.name),
            ),
          );
        },
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'settings') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DeckSettingsPage(packName: deck.name),
                ),
              );
            } else if (value == 'browse') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FlashcardBrowserPage(packName: deck.name),
                ),
              );
            } else if (value == 'stats') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StatsPage(packName: deck.name),
                ),
              );
            } else if (value == 'delete') {
              _confirmDelete(context, ref, deck.name);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.tune),
                title: Text('Configuración'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem<String>(
              value: 'browse',
              child: ListTile(
                leading: Icon(Icons.list),
                title: Text('Explorar Cartas'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem<String>(
              value: 'stats',
              child: ListTile(
                leading: Icon(Icons.bar_chart),
                title: Text('Estadísticas'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Eliminar Mazo',
                  style: TextStyle(color: Colors.red),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String packName) {
    showDialog(
      context: context,
      builder: (ctx) {
        bool deleting = false;

        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: Text("Eliminar $packName"),
            content: const Text(
              "¿Estás seguro? Se borrarán todas las tarjetas y su progreso.",
            ),
            actions: [
              TextButton(
                onPressed: deleting ? null : () => Navigator.pop(ctx),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: deleting
                    ? null
                    : () async {
                  setState(() => deleting = true);
                  try {
                    await ref.read(deleteDeckProvider(packName).future);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Mazo eliminado."),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error al eliminar: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: deleting
                    ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text(
                  "Eliminar",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- MÁQUINA DEL TIEMPO (DEBUG) ---
  Future<void> _showTimeMachineDialog(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Máquina del Tiempo 🕒"),
        content: const Text(
          "Esto adelantará TODAS las fechas de repaso en 1 día para simular que pasó el tiempo. ¿Continuar?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _applyTimeTravel(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("¡Viajaste 1 día al futuro!")),
                );
              }
            },
            child: const Text("Viajar +1 Día"),
          ),
        ],
      ),
    );
  }

  Future<void> _applyTimeTravel(WidgetRef ref) async {
    final isar = await ref.read(isarDbProvider.future);

    final allCards = await isar.flashcards.where().findAll();

    await isar.writeTxn(() async {
      for (final card in allCards) {
        card.nextReview = card.nextReview.subtract(const Duration(days: 1));
        await isar.flashcards.put(card);
      }

      final allSettings = await isar.deckSettings.where().findAll();
      for (final s in allSettings) {
        s.newCardsSeenToday = 0;
        await isar.deckSettings.put(s);
      }
    });
  }
}