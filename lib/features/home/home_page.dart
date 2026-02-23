import 'dart:io';

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
                  const SizedBox(height: 10),
                  const Text(
                    "No hay mazos aún.\nImporta uno para empezar.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Importar Mazo"),
                    onPressed: () =>
                        HomeImportHelper.pickAndImportFile(context, ref),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: decks.length,
            separatorBuilder: (_, __) => const Divider(height: 2),
            itemBuilder: (context, index) {
              final deck = decks[index];
              final firstStepDue = deck.firstStepDue;

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  leading: _DeckIcon(iconUri: deck.iconUri),
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
                      } else if (value == 'rename') {
                        _showRenameDeckDialog(context, ref, deck.name);
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
                          title: Text('Explorar'),
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
                      PopupMenuItem<String>(
                        value: 'rename',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Renombrar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Borrar', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context,
      WidgetRef ref,
      String packName,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar mazo"),
        content: Text("¿Seguro que quieres eliminar el mazo '$packName'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ref.read(deleteDeckProvider(packName).future);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mazo eliminado")),
    );
  }

  Future<void> _showRenameDeckDialog(
      BuildContext context,
      WidgetRef ref,
      String oldName,
      ) async {
    final controller = TextEditingController(text: oldName);

    final newName = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Renombrar mazo'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nuevo nombre',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final v = controller.text.trim();
                Navigator.pop(ctx, v);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    final trimmed = newName?.trim() ?? '';
    if (trimmed.isEmpty || trimmed == oldName) return;

    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(renameDeckProvider(oldName, trimmed).future);
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mazo renombrado a '$trimmed'")),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo renombrar: $e")),
      );
    }
  }

  void _showTimeMachineDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Máquina del Tiempo"),
        content: const Text(
          "Esto mueve todas las tarjetas 1 día hacia atrás (para que queden vencidas).",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
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

class _DeckIcon extends StatelessWidget {
  final String? iconUri;
  final double size;

  const _DeckIcon({
    required this.iconUri,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'lib/assets/images/deck_default.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );

    final uriStr = iconUri?.trim();
    if (uriStr == null || uriStr.isEmpty) return fallback;

    try {
      final uri = Uri.parse(uriStr);
      final file = uri.scheme == 'file' ? File.fromUri(uri) : File(uriStr);

      if (!file.existsSync()) return fallback;

      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback,
        ),
      );
    } catch (_) {
      return fallback;
    }
  }
}