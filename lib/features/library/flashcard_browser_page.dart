import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/flashcard.dart';

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
                    if (!_showRecog && c.cardType.endsWith('recog')) {
                      return false;
                    }
                    if (!_showProd && c.cardType.endsWith('prod')) return false;
                    if (_stateFilter != null && c.state != _stateFilter) {
                      return false;
                    }

                    if (q.isEmpty) return true;

                    final a = c.question.toLowerCase();
                    final b = c.answer.toLowerCase();
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
              Align(
                alignment: Alignment.centerRight,
                child: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              ),
            ],
          ),
        ),
      ),
    );
  }
}