import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/features/importer/importer_provider.dart';
import 'package:flashcards_app/features/library/deck_overview_page.dart';
import 'package:flashcards_app/features/library/deck_provider.dart';
import 'package:flashcards_app/features/library/deck_settings_page.dart';
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
          // BOTÓN DE MÁQUINA DEL TIEMPO (Solo para desarrollo/debug)
          IconButton(
            icon: const Icon(Icons.history_toggle_off),
            tooltip: "Simular paso del tiempo (+1 día)",
            onPressed: () => _showTimeMachineDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Importar Mazo",
            onPressed: () => _pickAndImportFile(context, ref),
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
                    onPressed: () => _pickAndImportFile(context, ref),
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

            if (deck.firstStepDue > 0)
              Text(
                "Paso 1: ${deck.firstStepDue}  ",
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
                deck.firstStepDue == 0 &&
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

  Future<void> _pickAndImportFile(BuildContext context, WidgetRef ref) async {
    bool dialogShown = false;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'flashjp'],
      );

      if (result == null || result.files.single.path == null) return;

      final filePath = result.files.single.path!;

      if (!context.mounted) return;

      dialogShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      await ref.read(importerServiceProvider).importFlashcardPackage(filePath);

      if (!context.mounted) return;
      if (dialogShown && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop(); // cerrar loading
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Importación exitosa!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      // Solo cerramos el diálogo si realmente lo abrimos
      if (dialogShown && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al importar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
  Future<void> _showTimeMachineDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
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

/// =============================================================
/// Explorador simple de cartas por mazo (implementado aquí para
/// que el menú "Explorar Cartas" funcione sin depender de otro file).
/// =============================================================
class FlashcardBrowserPage extends ConsumerStatefulWidget {
  final String packName;

  const FlashcardBrowserPage({super.key, required this.packName});

  @override
  ConsumerState<FlashcardBrowserPage> createState() =>
      _FlashcardBrowserPageState();
}

class _FlashcardBrowserPageState extends ConsumerState<FlashcardBrowserPage> {
  String _query = '';
  bool _showRecog = true;
  bool _showProd = true;
  CardState? _stateFilter; // null = todos

  String _stateLabel(CardState s) {
    switch (s) {
      case CardState.newCard:
        return 'Nueva';
      case CardState.learning:
        return 'Learning';
      case CardState.review:
        return 'Review';
      case CardState.relearning:
        return 'Relearning';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isarAsync = ref.watch(isarDbProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Explorar: ${widget.packName}")),
      body: isarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error DB: $e")),
        data: (isar) {
          // Rebuild cuando cambien cartas
          final watchStream = isar.flashcards
              .filter()
              .packNameEqualTo(widget.packName)
              .watchLazy(fireImmediately: true);

          return StreamBuilder<void>(
            stream: watchStream,
            builder: (context, _) {
              return FutureBuilder<List<Flashcard>>(
                future: isar.flashcards
                    .filter()
                    .packNameEqualTo(widget.packName)
                    .sortByOriginalId()
                    .findAll(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final all = snap.data!;

                  final q = _query.trim().toLowerCase();
                  final filtered = all.where((c) {
                    if (!_showRecog && c.cardType.endsWith('recog'))
                      return false;
                    if (!_showProd && c.cardType.endsWith('prod')) return false;
                    if (_stateFilter != null && c.state != _stateFilter)
                      return false;

                    if (q.isEmpty) return true;
                    final a = (c.question).toLowerCase();
                    final b = (c.answer).toLowerCase();
                    final s = (c.sentence ?? '').toLowerCase();
                    final t = (c.translation ?? '').toLowerCase();
                    return a.contains(q) ||
                        b.contains(q) ||
                        s.contains(q) ||
                        t.contains(q);
                  }).toList();

                  return Column(
                    children: [
                      _buildFilters(context),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(child: Text("No hay resultados."))
                            : ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, i) {
                                  final c = filtered[i];
                                  return _FlashcardTile(
                                    card: c,
                                    stateLabel: _stateLabel(c.state),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Buscar (pregunta, respuesta, oración...)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              FilterChip(
                label: const Text("Recog"),
                selected: _showRecog,
                onSelected: (v) => setState(() => _showRecog = v),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text("Prod"),
                selected: _showProd,
                onSelected: (v) => setState(() => _showProd = v),
              ),
              const Spacer(),
              DropdownButton<CardState?>(
                value: _stateFilter,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem<CardState?>(
                    value: null,
                    child: Text("Todos"),
                  ),
                  DropdownMenuItem<CardState?>(
                    value: CardState.newCard,
                    child: Text("Nuevas"),
                  ),
                  DropdownMenuItem<CardState?>(
                    value: CardState.learning,
                    child: Text("Learning"),
                  ),
                  DropdownMenuItem<CardState?>(
                    value: CardState.review,
                    child: Text("Review"),
                  ),
                  DropdownMenuItem<CardState?>(
                    value: CardState.relearning,
                    child: Text("Relearning"),
                  ),
                ],
                onChanged: (v) => setState(() => _stateFilter = v),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlashcardTile extends StatefulWidget {
  final Flashcard card;
  final String stateLabel;

  const _FlashcardTile({required this.card, required this.stateLabel});

  @override
  State<_FlashcardTile> createState() => _FlashcardTileState();
}

class _FlashcardTileState extends State<_FlashcardTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.card;

    final type = c.cardType.endsWith('recog')
        ? 'Recog'
        : (c.cardType.endsWith('prod') ? 'Prod' : c.cardType);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(label: Text(type), visualDensity: VisualDensity.compact),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(widget.stateLabel),
                    visualDensity: VisualDensity.compact,
                  ),
                  const Spacer(),
                  if ((c.audioPath ?? '').isNotEmpty)
                    const Icon(Icons.volume_up, size: 18),
                  if ((c.imagePath ?? '').isNotEmpty) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.image, size: 18),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                c.question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                Text(c.answer, style: const TextStyle(fontSize: 15)),
                if ((c.sentence ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Oración: ${c.sentence}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
                if ((c.translation ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    "Traducción: ${c.translation}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  "Next review: ${c.nextReview}",
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
              if (!_expanded)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.expand_more),
                )
              else
                const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.expand_less),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
