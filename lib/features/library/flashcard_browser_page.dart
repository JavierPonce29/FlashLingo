import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';
import 'package:flashcards_app/theme/app_ui_colors.dart';

class FlashcardBrowserPage extends ConsumerStatefulWidget {
  final String packName;

  const FlashcardBrowserPage({super.key, required this.packName});

  @override
  ConsumerState<FlashcardBrowserPage> createState() => _FlashcardBrowserPageState();
}

class _FlashcardBrowserPageState extends ConsumerState<FlashcardBrowserPage> {
  String _query = '';
  bool _showRecog = true;
  bool _showProd = true;
  CardState? _stateFilter;

  String _stateLabel(AppLocalizations l10n, CardState state) {
    switch (state) {
      case CardState.newCard:
        return l10n.tr('state_new');
      case CardState.learning:
        return l10n.tr('state_learning');
      case CardState.review:
        return l10n.tr('state_review');
      case CardState.relearning:
        return l10n.tr('state_relearning');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isarAsync = ref.watch(isarDbProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.tr('browser_title', params: <String, Object?>{'packName': widget.packName}),
        ),
      ),
      body: isarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            l10n.tr('browser_db_error', params: <String, Object?>{'error': error}),
          ),
        ),
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

                  final filtered = all.where((card) {
                    if (!_showRecog && card.cardType.endsWith('recog')) return false;
                    if (!_showProd && card.cardType.endsWith('prod')) return false;
                    if (_stateFilter != null && card.state != _stateFilter) return false;

                    if (q.isEmpty) return true;
                    final question = card.question.toLowerCase();
                    final answer = card.answer.toLowerCase();
                    final sentence = (card.sentence ?? '').toLowerCase();
                    final translation = (card.translation ?? '').toLowerCase();
                    return question.contains(q) ||
                        answer.contains(q) ||
                        sentence.contains(q) ||
                        translation.contains(q);
                  }).toList();

                  return Column(
                    children: [
                      _buildFilters(context),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(child: Text(l10n.tr('browser_no_results')))
                            : ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final card = filtered[index];
                                  return _FlashcardTile(
                                    card: card,
                                    stateLabel: _stateLabel(l10n, card.state),
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
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.tr('browser_search_hint'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              FilterChip(
                label: Text(l10n.tr('browser_filter_recog')),
                selected: _showRecog,
                onSelected: (value) => setState(() => _showRecog = value),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(l10n.tr('browser_filter_prod')),
                selected: _showProd,
                onSelected: (value) => setState(() => _showProd = value),
              ),
              const Spacer(),
              DropdownButton<CardState?>(
                value: _stateFilter,
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem<CardState?>(
                    value: null,
                    child: Text(l10n.tr('common_all')),
                  ),
                  DropdownMenuItem<CardState?>(
                    value: CardState.newCard,
                    child: Text(l10n.tr('state_new')),
                  ),
                  DropdownMenuItem<CardState?>(
                    value: CardState.learning,
                    child: Text(l10n.tr('state_learning')),
                  ),
                  DropdownMenuItem<CardState?>(
                    value: CardState.review,
                    child: Text(l10n.tr('state_review')),
                  ),
                  DropdownMenuItem<CardState?>(
                    value: CardState.relearning,
                    child: Text(l10n.tr('state_relearning')),
                  ),
                ],
                onChanged: (value) => setState(() => _stateFilter = value),
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
    final l10n = context.l10n;
    final muted = AppUiColors.mutedText(context);
    final card = widget.card;

    final type = card.cardType.endsWith('recog')
        ? l10n.tr('browser_filter_recog')
        : (card.cardType.endsWith('prod')
            ? l10n.tr('browser_filter_prod')
            : card.cardType);

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
                  if ((card.audioPath ?? '').isNotEmpty)
                    const Icon(Icons.volume_up, size: 18),
                  if ((card.imagePath ?? '').isNotEmpty) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.image, size: 18),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                card.question,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                Text(card.answer, style: const TextStyle(fontSize: 15)),
                if ((card.sentence ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.tr(
                      'browser_sentence',
                      params: <String, Object?>{'value': card.sentence},
                    ),
                    style: TextStyle(color: muted),
                  ),
                ],
                if ((card.translation ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.tr(
                      'browser_translation',
                      params: <String, Object?>{'value': card.translation},
                    ),
                    style: TextStyle(color: muted),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  l10n.tr(
                    'browser_next_review',
                    params: <String, Object?>{'value': card.nextReview},
                  ),
                  style: TextStyle(fontSize: 12, color: muted),
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
