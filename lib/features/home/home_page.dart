import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/models/study_session.dart';
import 'package:flashcards_app/features/home/home_import_helper.dart';
import 'package:flashcards_app/features/library/deck_overview_page.dart';
import 'package:flashcards_app/features/library/deck_provider.dart';
import 'package:flashcards_app/features/library/deck_settings_page.dart';
import 'package:flashcards_app/features/library/flashcard_browser_page.dart';
import 'package:flashcards_app/features/settings/general_settings_page.dart';
import 'package:flashcards_app/features/stats/stats_page.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';
import 'package:flashcards_app/theme/app_ui_colors.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final info = AppUiColors.info(context);
    final warning = AppUiColors.warning(context);
    final success = AppUiColors.success(context);
    final muted = AppUiColors.mutedText(context);
    final danger = Theme.of(context).colorScheme.error;

    final decksAsync = ref.watch(decksStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('home_title')),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.tr('home_tooltip_settings'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GeneralSettingsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.tr('home_tooltip_import'),
            onPressed: () => HomeImportHelper.pickAndImportFile(context, ref),
          ),
        ],
      ),
      body: decksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            l10n.tr('common_error_with_detail', params: <String, Object?>{
              'error': err,
            }),
          ),
        ),
        data: (decks) {
          if (decks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books, size: 64, color: muted),
                  const SizedBox(height: 10),
                  Text(
                    l10n.tr('home_empty_decks'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: muted),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(l10n.tr('home_import_deck')),
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
            separatorBuilder: (_, index) => const Divider(height: 2),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (deck.newCardsDue > 0)
                        Text(
                          l10n.tr(
                            'home_new',
                            params: <String, Object?>{'count': deck.newCardsDue},
                          ),
                          style: TextStyle(
                            color: info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (firstStepDue > 0)
                        Text(
                          l10n.tr(
                            'home_step1',
                            params: <String, Object?>{'count': firstStepDue},
                          ),
                          style: TextStyle(
                            color: warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (deck.reviewCardsDue > 0)
                        Text(
                          l10n.tr(
                            'home_review',
                            params: <String, Object?>{
                              'count': deck.reviewCardsDue,
                            },
                          ),
                          style: TextStyle(
                            color: success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (deck.newCardsDue == 0 &&
                          firstStepDue == 0 &&
                          deck.reviewCardsDue == 0)
                        Text(
                          l10n.tr('home_all_caught_up'),
                          style: TextStyle(color: muted),
                        ),
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
                            builder: (_) =>
                                DeckSettingsPage(packName: deck.name),
                          ),
                        );
                      } else if (value == 'browse') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FlashcardBrowserPage(packName: deck.name),
                          ),
                        );
                      } else if (value == 'stats') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StatsPage(packName: deck.name),
                          ),
                        );
                      } else if (value == 'advance') {
                        _promptBringReviewsToToday(context, ref, deck.name);
                      } else if (value == 'rename') {
                        _showRenameDeckDialog(context, ref, deck.name);
                      } else if (value == 'delete') {
                        _confirmDelete(context, ref, deck.name);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'settings',
                        child: ListTile(
                          leading: const Icon(Icons.tune),
                          title: Text(l10n.tr('home_menu_settings')),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'browse',
                        child: ListTile(
                          leading: const Icon(Icons.list),
                          title: Text(l10n.tr('home_menu_browse')),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'stats',
                        child: ListTile(
                          leading: const Icon(Icons.bar_chart),
                          title: Text(l10n.tr('home_menu_stats')),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'advance',
                        child: ListTile(
                          leading: const Icon(Icons.today),
                          title: Text(l10n.tr('home_menu_advance')),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'rename',
                        child: ListTile(
                          leading: const Icon(Icons.edit),
                          title: Text(l10n.tr('home_menu_rename')),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: danger),
                          title: Text(
                            l10n.tr('home_menu_delete'),
                            style: TextStyle(color: danger),
                          ),
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
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.tr('home_delete_title')),
        content: Text(
          l10n.tr(
            'home_delete_confirm',
            params: <String, Object?>{'packName': packName},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.tr('common_cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.tr('common_delete')),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await ref.read(deleteDeckProvider(packName).future);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.tr('home_delete_success'))));
  }

  Future<void> _promptBringReviewsToToday(
    BuildContext context,
    WidgetRef ref,
    String packName,
  ) async {
    final l10n = context.l10n;
    final available = await _countFutureReviews(ref, packName);
    if (!context.mounted) return;
    if (available <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.tr('home_no_future_reviews'))));
      return;
    }

    String inputCount = (available > 20 ? 20 : available).toString();
    final rawCount = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.tr('home_advance_title')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.tr(
                  'home_future_available',
                  params: <String, Object?>{'count': available},
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: inputCount,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => inputCount = value,
                decoration: InputDecoration(
                  labelText: l10n.tr('home_advance_amount_label'),
                  hintText: l10n.tr(
                    'home_advance_amount_hint',
                    params: <String, Object?>{'count': available},
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.tr('common_cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, inputCount),
            child: Text(l10n.tr('home_advance_action')),
          ),
        ],
      ),
    );
    if (rawCount == null) return;
    if (!context.mounted) return;

    final requested = int.tryParse(rawCount.trim());
    if (requested == null || requested <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.tr('home_advance_invalid'))));
      return;
    }

    final moved = await _bringDeckReviewsToToday(ref, packName, requested);
    if (!context.mounted) return;
    final message = moved > 0
        ? l10n.tr(
            'home_advanced_result',
            params: <String, Object?>{'count': moved},
          )
        : l10n.tr('home_advanced_none');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<int> _countFutureReviews(WidgetRef ref, String packName) async {
    final normalizedPackName = packName.trim();
    if (normalizedPackName.isEmpty) return 0;

    final isar = await ref.read(isarDbProvider.future);
    final now = DateTime.now();
    return isar.flashcards
        .filter()
        .packNameEqualTo(normalizedPackName)
        .not()
        .stateEqualTo(CardState.newCard)
        .and()
        .nextReviewGreaterThan(now)
        .count();
  }

  Future<int> _bringDeckReviewsToToday(
    WidgetRef ref,
    String packName,
    int maxToAdvance,
  ) async {
    final normalizedPackName = packName.trim();
    if (normalizedPackName.isEmpty || maxToAdvance <= 0) return 0;

    final isar = await ref.read(isarDbProvider.future);
    final now = DateTime.now();

    final cardsToAdvance = await isar.flashcards
        .filter()
        .packNameEqualTo(normalizedPackName)
        .not()
        .stateEqualTo(CardState.newCard)
        .and()
        .nextReviewGreaterThan(now)
        .sortByNextReview()
        .limit(maxToAdvance)
        .findAll();

    if (cardsToAdvance.isEmpty) return 0;

    await isar.writeTxn(() async {
      for (final card in cardsToAdvance) {
        card.nextReview = now;
      }
      await isar.flashcards.putAll(cardsToAdvance);
      await isar.studySessions
          .filter()
          .packNameEqualTo(normalizedPackName)
          .deleteAll();
    });

    return cardsToAdvance.length;
  }

  Future<void> _showRenameDeckDialog(
    BuildContext context,
    WidgetRef ref,
    String oldName,
  ) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: oldName);
    final newName = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.tr('home_rename_title')),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.tr('home_new_name_label'),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: Text(l10n.tr('common_cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();
                Navigator.pop(ctx, value);
              },
              child: Text(l10n.tr('common_save')),
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
        SnackBar(
          content: Text(
            l10n.tr(
              'home_rename_success',
              params: <String, Object?>{'name': trimmed},
            ),
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.tr('home_rename_error'))));
    }
  }
}

class _DeckIcon extends StatelessWidget {
  final String? iconUri;

  const _DeckIcon({required this.iconUri});

  @override
  Widget build(BuildContext context) {
    final fallback = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'lib/assets/images/deck_default.png',
        width: 52,
        height: 52,
        fit: BoxFit.cover,
      ),
    );

    final uriStr = iconUri?.trim();
    if (uriStr == null || uriStr.isEmpty) return fallback;
    try {
      final uri = Uri.parse(uriStr);
      final file = uri.scheme == 'file' ? File.fromUri(uri) : File(uriStr);
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          file,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback,
        ),
      );
    } catch (_) {
      return fallback;
    }
  }
}
