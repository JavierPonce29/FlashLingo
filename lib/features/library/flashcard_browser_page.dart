import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/models/review_log.dart';
import 'package:flashcards_app/features/library/flashcard_browser_logic.dart';
import 'package:flashcards_app/features/library/review_history_sheet.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';
import 'package:flashcards_app/theme/app_ui_colors.dart';

class _BrowserData {
  final List<Flashcard> cards;
  final Map<String, List<ReviewLog>> logsByCardKey;

  const _BrowserData({required this.cards, required this.logsByCardKey});
}

class FlashcardBrowserPage extends ConsumerStatefulWidget {
  final String packName;
  final int? initialCardId;
  final String initialQuery;

  const FlashcardBrowserPage({
    super.key,
    required this.packName,
    this.initialCardId,
    this.initialQuery = '',
  });

  @override
  ConsumerState<FlashcardBrowserPage> createState() =>
      _FlashcardBrowserPageState();
}

class _FlashcardBrowserPageState extends ConsumerState<FlashcardBrowserPage> {
  String _query = '';
  late final TextEditingController _queryController;
  bool _showRecog = true;
  bool _showProd = true;
  CardState? _stateFilter;
  FlashcardBrowserSortMode _sortMode = FlashcardBrowserSortMode.original;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _queryController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

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

  String _sortLabel(AppLocalizations l10n, FlashcardBrowserSortMode mode) {
    switch (mode) {
      case FlashcardBrowserSortMode.original:
        return l10n.tr('browser_sort_original');
      case FlashcardBrowserSortMode.hardest:
        return l10n.tr('browser_sort_hardest');
      case FlashcardBrowserSortMode.overdue:
        return l10n.tr('browser_sort_overdue');
      case FlashcardBrowserSortMode.nextReview:
        return l10n.tr('browser_sort_next_review');
      case FlashcardBrowserSortMode.lastReview:
        return l10n.tr('browser_sort_last_review');
    }
  }

  Future<_BrowserData> _loadBrowserData(Isar isar) async {
    final cardsFuture = isar.flashcards
        .filter()
        .packNameEqualTo(widget.packName)
        .sortByOriginalId()
        .findAll();
    final logsFuture = isar.reviewLogs
        .filter()
        .packNameEqualTo(widget.packName)
        .findAll();

    final results = await Future.wait<dynamic>([cardsFuture, logsFuture]);
    final cards = List<Flashcard>.from(results[0] as List<Flashcard>);
    final logs = List<ReviewLog>.from(results[1] as List<ReviewLog>);
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final logsByCardKey = <String, List<ReviewLog>>{};
    for (final log in logs) {
      logsByCardKey
          .putIfAbsent(log.cardOriginalId, () => <ReviewLog>[])
          .add(log);
    }

    return _BrowserData(cards: cards, logsByCardKey: logsByCardKey);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isarAsync = ref.watch(isarDbProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.tr(
            'browser_title',
            params: <String, Object?>{'packName': widget.packName},
          ),
        ),
      ),
      body: isarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, stackTrace) =>
            Center(child: Text(l10n.tr('browser_load_error'))),
        data: (isar) {
          final cardWatchStream = isar.flashcards
              .filter()
              .packNameEqualTo(widget.packName)
              .watchLazy(fireImmediately: true);
          final reviewWatchStream = isar.reviewLogs
              .filter()
              .packNameEqualTo(widget.packName)
              .watchLazy(fireImmediately: true);

          return StreamBuilder<void>(
            stream: cardWatchStream,
            builder: (context, _) {
              return StreamBuilder<void>(
                stream: reviewWatchStream,
                builder: (context, _) {
                  return FutureBuilder<_BrowserData>(
                    future: _loadBrowserData(isar),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data = snap.data!;
                      final filtered = buildVisibleFlashcards(
                        data.cards,
                        filters: FlashcardBrowserFilters(
                          query: _query,
                          showRecog: _showRecog,
                          showProd: _showProd,
                          stateFilter: _stateFilter,
                          sortMode: _sortMode,
                          highlightedId: widget.initialCardId,
                        ),
                      );

                      return Column(
                        children: [
                          _buildFilters(context),
                          Expanded(
                            child: filtered.isEmpty
                                ? Center(
                                    child: Text(l10n.tr('browser_no_results')),
                                  )
                                : ListView.builder(
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      final card = filtered[index];
                                      final cardKey =
                                          '${card.originalId}::${card.cardType}';
                                      return _FlashcardTile(
                                        card: card,
                                        stateLabel: _stateLabel(
                                          l10n,
                                          card.state,
                                        ),
                                        highlighted:
                                            widget.initialCardId == card.id,
                                        reviewLogs:
                                            data.logsByCardKey[cardKey] ??
                                            const [],
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
            controller: _queryController,
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
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                l10n.tr('browser_sort_label'),
                style: TextStyle(color: AppUiColors.mutedText(context)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButton<FlashcardBrowserSortMode>(
                  value: _sortMode,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: FlashcardBrowserSortMode.values
                      .map(
                        (mode) => DropdownMenuItem<FlashcardBrowserSortMode>(
                          value: mode,
                          child: Text(_sortLabel(l10n, mode)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _sortMode = value);
                  },
                ),
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
  final bool highlighted;
  final List<ReviewLog> reviewLogs;

  const _FlashcardTile({
    required this.card,
    required this.stateLabel,
    required this.highlighted,
    required this.reviewLogs,
  });

  @override
  State<_FlashcardTile> createState() => _FlashcardTileState();
}

class _FlashcardTileState extends State<_FlashcardTile> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.highlighted;
  }

  String _formatDuration(int totalMs) {
    if (totalMs <= 0) return '0s';
    final totalSeconds = Duration(milliseconds: totalMs).inSeconds;
    if (totalSeconds < 60) return '${totalSeconds}s';
    final totalMinutes = Duration(milliseconds: totalMs).inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours <= 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  String _formatAccuracy(Flashcard card) {
    if (card.lifetimeReviewCount == 0) return '0%';
    final accuracy =
        (card.lifetimeCorrectCount / card.lifetimeReviewCount) * 100;
    return '${accuracy.round()}%';
  }

  String _formatDate(DateTime value) {
    if (value.millisecondsSinceEpoch == 0) return '-';
    return value.toString();
  }

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: widget.highlighted
            ? BorderSide(color: AppUiColors.info(context), width: 1.5)
            : BorderSide.none,
      ),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
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
                const SizedBox(height: 4),
                Text(
                  l10n.tr(
                    'browser_last_review',
                    params: <String, Object?>{
                      'value': _formatDate(card.lastReview),
                    },
                  ),
                  style: TextStyle(fontSize: 12, color: muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _StatPill(
                      label: l10n.tr('browser_lifetime_reviews'),
                      value: '${card.lifetimeReviewCount}',
                    ),
                    _StatPill(
                      label: l10n.tr('browser_correct_total'),
                      value: '${card.lifetimeCorrectCount}',
                    ),
                    _StatPill(
                      label: l10n.tr('browser_wrong_total'),
                      value: '${card.lifetimeWrongCount}',
                    ),
                    _StatPill(
                      label: l10n.tr('browser_accuracy'),
                      value: _formatAccuracy(card),
                    ),
                    _StatPill(
                      label: l10n.tr('browser_total_study_time'),
                      value: _formatDuration(card.totalStudyTimeMs),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (widget.reviewLogs.isEmpty)
                  Text(
                    l10n.tr('browser_history_empty'),
                    style: TextStyle(color: muted),
                  )
                else
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () =>
                          showReviewHistorySheet(context, widget.reviewLogs),
                      icon: const Icon(Icons.history),
                      label: Text(
                        l10n.tr(
                          'browser_history_button',
                          params: <String, Object?>{
                            'count': widget.reviewLogs.length,
                          },
                        ),
                      ),
                    ),
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

class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600),
      ),
    );
  }
}
