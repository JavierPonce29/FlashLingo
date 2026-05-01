import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:url_launcher/link.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/data/models/study_session.dart';
import 'package:flashcards_app/features/home/home_import_helper.dart';
import 'package:flashcards_app/features/importer/import_summary_page.dart';
import 'package:flashcards_app/features/importer/importer_provider.dart';
import 'package:flashcards_app/features/importer/importer_service.dart';
import 'package:flashcards_app/features/library/deck_overview_page.dart';
import 'package:flashcards_app/features/library/deck_provider.dart';
import 'package:flashcards_app/features/library/deck_settings_page.dart';
import 'package:flashcards_app/features/library/flashcard_browser_page.dart';
import 'package:flashcards_app/features/onboarding/guided_tour_controller.dart';
import 'package:flashcards_app/features/onboarding/starter_deck_service.dart';
import 'package:flashcards_app/features/onboarding/tour_widgets.dart';
import 'package:flashcards_app/features/settings/general_settings_page.dart';
import 'package:flashcards_app/features/stats/stats_page.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';
import 'package:flashcards_app/theme/app_ui_colors.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _welcomeDialogQueued = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final info = AppUiColors.info(context);
    final warning = AppUiColors.warning(context);
    final success = AppUiColors.success(context);
    final muted = AppUiColors.mutedText(context);
    final overdue = AppUiColors.overdue(context);
    final danger = AppUiColors.danger(context);
    final guidedTourState = ref.watch(guidedTourProvider);

    _maybeShowWelcomeDialog(guidedTourState);

    final decksAsync = ref.watch(decksStreamProvider);
    final step = guidedTourState.step;
    final guidedDeckName = guidedTourState.guidedDeckName?.trim();
    final blockHomeBody =
        step == GuidedTourStep.homeIntro ||
        step == GuidedTourStep.homeOpenSettings ||
        step == GuidedTourStep.homeImportStarter;
    final canOpenSettings =
        !guidedTourState.isTourActive ||
        step == GuidedTourStep.homeOpenSettings;
    final canUseImport =
        !guidedTourState.isTourActive ||
        step == GuidedTourStep.homeImportStarter;

    final page = Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        centerTitle: false,
        titleSpacing: 20,
        title: const _HomeBrandTitle(),
        actions: [
          _HighlightedActionButton(
            highlighted: step == GuidedTourStep.homeOpenSettings,
            tooltip: l10n.tr('home_tooltip_settings'),
            icon: Icons.settings,
            onPressed: canOpenSettings
                ? () async {
                    final tourController = ref.read(
                      guidedTourProvider.notifier,
                    );
                    if (step == GuidedTourStep.homeOpenSettings) {
                      tourController.onGeneralSettingsOpened();
                    }
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GeneralSettingsPage(),
                      ),
                    );
                    tourController.onGeneralSettingsClosed();
                  }
                : null,
          ),
          _HighlightedActionButton(
            highlighted: step == GuidedTourStep.homeImportStarter,
            tooltip: l10n.tr('home_tooltip_import'),
            icon: Icons.add,
            filled: true,
            onPressed: canUseImport
                ? () {
                    if (step == GuidedTourStep.homeImportStarter) {
                      _runGuidedStarterImport();
                      return;
                    }
                    HomeImportHelper.pickAndImportFile(context, ref);
                  }
                : null,
          ),
        ],
      ),
      bottomNavigationBar: _buildDownloadFooter(l10n),
      body: IgnorePointer(
        ignoring: blockHomeBody,
        child: decksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text(l10n.tr('home_load_error'))),
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
                final learningDueToday = deck.learningDueToday;
                final isGuidedDeck =
                    guidedDeckName != null && deck.name == guidedDeckName;
                final highlightDeck =
                    isGuidedDeck &&
                    (step == GuidedTourStep.homeDeckHighlight ||
                        step == GuidedTourStep.homeDeckStudyPrompt);
                final highlightMenu =
                    isGuidedDeck &&
                    (step == GuidedTourStep.homeDeckMenuOpen ||
                        step == GuidedTourStep.homeOpenStats ||
                        step == GuidedTourStep.homeDeleteDeck ||
                        step == GuidedTourStep.homeDeleteConfirm);

                return TourHighlight(
                  highlighted: highlightDeck,
                  child: Card(
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
                                params: <String, Object?>{
                                  'count': deck.newCardsDue,
                                },
                              ),
                              style: TextStyle(
                                color: info,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (learningDueToday > 0)
                            Text(
                              l10n.tr(
                                'home_learning_due',
                                params: <String, Object?>{
                                  'count': learningDueToday,
                                },
                              ),
                              style: TextStyle(
                                color: warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (deck.reviewCardsDueToday > 0)
                            Text(
                              l10n.tr(
                                'home_review',
                                params: <String, Object?>{
                                  'count': deck.reviewCardsDueToday,
                                },
                              ),
                              style: TextStyle(
                                color: success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (deck.overdueCards > 0)
                            Text(
                              l10n.tr(
                                'home_overdue',
                                params: <String, Object?>{
                                  'count': deck.overdueCards,
                                },
                              ),
                              style: TextStyle(
                                color: overdue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (deck.reviewCount7d > 0)
                            Text(
                              l10n.tr(
                                'home_accuracy_7d',
                                params: <String, Object?>{
                                  'percent': (deck.accuracy7d * 100).round(),
                                },
                              ),
                              style: TextStyle(
                                color: muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (deck.newCardsDue == 0 &&
                              learningDueToday == 0 &&
                              deck.reviewCardsDueToday == 0 &&
                              deck.overdueCards == 0)
                            Text(
                              l10n.tr('home_all_caught_up'),
                              style: TextStyle(color: muted),
                            ),
                        ],
                      ),
                      onTap: () async {
                        final canTapDeck =
                            !guidedTourState.isTourActive ||
                            (isGuidedDeck &&
                                step == GuidedTourStep.homeDeckStudyPrompt);
                        if (!canTapDeck) return;
                        if (step == GuidedTourStep.homeDeckStudyPrompt) {
                          ref
                              .read(guidedTourProvider.notifier)
                              .onDeckOverviewOpenedForStudy();
                        }
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DeckOverviewPage(packName: deck.name),
                          ),
                        );
                      },
                      trailing: guidedTourState.isTourActive
                          ? (highlightMenu
                                ? _HighlightedActionButton(
                                    highlighted: true,
                                    icon: Icons.more_vert,
                                    tooltip: l10n.tr('home_menu_settings'),
                                    onPressed: () =>
                                        _handleGuidedDeckMenuAction(deck.name),
                                  )
                                : const IconButton(
                                    icon: Icon(Icons.more_vert),
                                    onPressed: null,
                                  ))
                          : PopupMenuButton<String>(
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
                                      builder: (_) => FlashcardBrowserPage(
                                        packName: deck.name,
                                      ),
                                    ),
                                  );
                                } else if (value == 'stats') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          StatsPage(packName: deck.name),
                                    ),
                                  );
                                } else if (value == 'advance') {
                                  _promptBringReviewsToToday(
                                    context,
                                    ref,
                                    deck.name,
                                  );
                                } else if (value == 'rename') {
                                  _showRenameDeckDialog(
                                    context,
                                    ref,
                                    deck.name,
                                  );
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
                  ),
                );
              },
            );
          },
        ),
      ),
    );

    if (!step.isHomeStep) return page;

    final overlay = _buildHomeTourOverlay(l10n, guidedTourState);
    if (overlay == null) return page;

    return Stack(
      children: [
        page,
        Positioned.fill(
          child: IgnorePointer(
            child: Container(color: AppUiColors.scrim(context)),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: overlay.showAtTop
              ? MediaQuery.of(context).padding.top + kToolbarHeight + 8
              : null,
          bottom: overlay.showAtTop ? null : 24,
          child: TourMessageCard(
            message: overlay.message,
            actionLabel: overlay.actionLabel,
            onActionPressed: overlay.onActionPressed,
          ),
        ),
      ],
    );
  }

  _HomeOverlayData? _buildHomeTourOverlay(
    AppLocalizations l10n,
    GuidedTourState guidedTourState,
  ) {
    final step = guidedTourState.step;
    final controller = ref.read(guidedTourProvider.notifier);

    switch (step) {
      case GuidedTourStep.homeIntro:
        return _HomeOverlayData(
          message: l10n.tr('onboarding_tour_home_intro'),
          actionLabel: l10n.tr('onboarding_tour_next'),
          onActionPressed: controller.nextFromHomeIntro,
        );
      case GuidedTourStep.homeOpenSettings:
        return _HomeOverlayData(
          message: l10n.tr('onboarding_tour_open_settings'),
          showAtTop: true,
        );
      case GuidedTourStep.homeImportStarter:
        return _HomeOverlayData(
          message: l10n.tr('onboarding_tour_home_import'),
          showAtTop: true,
        );
      case GuidedTourStep.homeDeckHighlight:
        return _HomeOverlayData(
          message: l10n.tr('onboarding_tour_home_deck_highlight'),
          actionLabel: l10n.tr('onboarding_tour_next'),
          onActionPressed: controller.nextFromHomeDeckHighlight,
        );
      case GuidedTourStep.homeDeckMenuOpen:
        return _HomeOverlayData(
          message: l10n.tr('onboarding_tour_home_menu_open'),
          showAtTop: true,
        );
      case GuidedTourStep.homeDeckStudyPrompt:
        return _HomeOverlayData(
          message: l10n.tr('onboarding_tour_home_open_deck'),
        );
      case GuidedTourStep.homeOpenStats:
        return _HomeOverlayData(
          message: l10n.tr('onboarding_tour_home_open_stats'),
          showAtTop: true,
        );
      case GuidedTourStep.homeDeleteDeck:
      case GuidedTourStep.homeDeleteConfirm:
        return _HomeOverlayData(
          message: l10n.tr('onboarding_tour_home_delete_deck'),
          showAtTop: true,
        );
      case GuidedTourStep.finalMessage:
        return _HomeOverlayData(
          message: l10n.tr(
            'onboarding_tour_final_message',
            params: <String, Object?>{
              'link': l10n.tr('onboarding_download_link_url'),
            },
          ),
          actionLabel: l10n.tr('onboarding_tour_finish'),
          onActionPressed: () => controller.completeTour(),
        );
      default:
        return null;
    }
  }

  Future<void> _runGuidedStarterImport() async {
    final l10n = context.l10n;
    bool loaderOpen = false;

    void showLoader(String message) {
      if (!mounted) return;
      loaderOpen = true;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (_) => PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                const SizedBox(width: 14),
                Expanded(child: Text(message)),
              ],
            ),
          ),
        ),
      );
    }

    void closeLoaderIfOpen() {
      if (!mounted) return;
      if (loaderOpen && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      loaderOpen = false;
    }

    try {
      final starterPath = await StarterDeckService.ensureStarterPackagePath();
      final importerCtrl = ref.read(importerControllerProvider.notifier);
      final guidedName = StarterDeckService.guidedDeckName;

      final deleteStarterFuture = ref.refresh(
        deleteDeckProvider(guidedName).future,
      );
      await deleteStarterFuture;

      showLoader(l10n.tr('import_importing'));
      final summary = await importerCtrl.importFlashcardPackageAdvanced(
        starterPath,
        options: const ImportExecutionOptions.createNew(
          customPackName: StarterDeckService.guidedDeckName,
        ),
      );
      closeLoaderIfOpen();
      importerCtrl.resetState();

      if (!mounted) return;
      ref
          .read(guidedTourProvider.notifier)
          .onStarterImportCompleted(summary.targetPackName);

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ImportSummaryPage(summary: summary)),
      );

      ref.read(guidedTourProvider.notifier).onImportSummaryClosed();
    } catch (_) {
      closeLoaderIfOpen();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tr('import_error')),
          backgroundColor: AppUiColors.danger(context),
        ),
      );
    }
  }

  Future<void> _handleGuidedDeckMenuAction(String packName) async {
    final step = ref.read(guidedTourProvider).step;
    final controller = ref.read(guidedTourProvider.notifier);

    if (step == GuidedTourStep.homeDeckMenuOpen) {
      final continueToSettings = await _showDeckMenuTourDialog();
      if (continueToSettings != true || !mounted) return;
      controller.onDeckMenuTutorialCompleted();
      controller.onDeckSettingsOpened();
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DeckSettingsPage(packName: packName)),
      );
      return;
    }

    if (step == GuidedTourStep.homeOpenStats) {
      controller.onStatsOpened();
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StatsPage(packName: packName)),
      );
      controller.onStatsClosed();
      return;
    }

    if (step == GuidedTourStep.homeDeleteDeck ||
        step == GuidedTourStep.homeDeleteConfirm) {
      controller.onDeletePromptOpened();
      await _confirmDelete(context, ref, packName, forceGuidedDelete: true);
    }
  }

  Future<bool?> _showDeckMenuTourDialog() async {
    final l10n = context.l10n;
    final messages = <String>[
      l10n.tr('onboarding_tour_menu_settings'),
      l10n.tr('onboarding_tour_menu_browse'),
      l10n.tr('onboarding_tour_menu_stats'),
      l10n.tr('onboarding_tour_menu_advance'),
      l10n.tr('onboarding_tour_menu_rename'),
      l10n.tr('onboarding_tour_menu_delete'),
    ];

    int page = 0;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.tr('onboarding_tour_menu_title')),
          content: Text(messages[page]),
          actions: [
            if (page < messages.length - 1)
              FilledButton(
                onPressed: () => setState(() => page++),
                child: Text(l10n.tr('onboarding_tour_next')),
              )
            else
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.tr('onboarding_tour_open_deck_settings')),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadFooter(AppLocalizations l10n) {
    final uri = Uri.tryParse(l10n.tr('onboarding_download_link_url'));
    final label = l10n.tr('onboarding_download_link_label');
    if (uri == null) return const SizedBox.shrink();

    final style = Theme.of(context).textTheme.bodySmall;
    final linkStyle = style?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 48,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Link(
              uri: uri,
              target: LinkTarget.blank,
              builder: (context, openLink) => InkWell(
                onTap: openLink,
                child: Text(
                  label,
                  style: linkStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _maybeShowWelcomeDialog(GuidedTourState guidedTourState) {
    if (_welcomeDialogQueued) return;
    if (!guidedTourState.isInitialized || guidedTourState.welcomeSeen) return;

    _welcomeDialogQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showWelcomeDialog();
    });
  }

  Future<void> _showWelcomeDialog() async {
    final l10n = context.l10n;
    final wantsTour = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.tr('onboarding_welcome_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.tr('onboarding_welcome_body')),
            const SizedBox(height: 12),
            Text(l10n.tr('onboarding_welcome_question')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.tr('onboarding_welcome_yes')),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.tr('onboarding_welcome_no')),
              ),
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;
    final tourController = ref.read(guidedTourProvider.notifier);
    await tourController.markWelcomeSeen();
    if (!mounted) return;

    if (wantsTour == true) {
      tourController.startTour();
      return;
    }
    await _showTourAvailableAlert();
  }

  Future<void> _showTourAvailableAlert() async {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.tr('onboarding_later_title')),
        content: Text(l10n.tr('onboarding_later_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.tr('onboarding_later_action')),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String packName, {
    bool forceGuidedDelete = false,
  }) async {
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
          if (!forceGuidedDelete)
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

    final deleteDeckFuture = ref.refresh(deleteDeckProvider(packName).future);
    await deleteDeckFuture;
    if (!context.mounted) return;
    if (forceGuidedDelete) {
      ref.read(guidedTourProvider.notifier).onGuidedDeckDeleted();
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('home_no_future_reviews'))),
      );
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

class _HighlightedActionButton extends StatelessWidget {
  final bool highlighted;
  final String tooltip;
  final IconData icon;
  final bool filled;
  final VoidCallback? onPressed;

  const _HighlightedActionButton({
    required this.highlighted,
    required this.tooltip,
    required this.icon,
    this.filled = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final radius = filled ? 999.0 : 12.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.all(2),
      decoration: highlighted
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: primary, width: 2.4),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.45),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            )
          : null,
      child: IconButton(
        style: IconButton.styleFrom(
          backgroundColor: filled ? primary : Colors.transparent,
          foregroundColor: filled ? onPrimary : primary,
          minimumSize: filled ? const Size(44, 44) : null,
          fixedSize: filled ? const Size(44, 44) : null,
          padding: EdgeInsets.zero,
          shape: filled ? const CircleBorder() : null,
        ),
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}

class _HomeOverlayData {
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final bool showAtTop;

  const _HomeOverlayData({
    required this.message,
    this.actionLabel,
    this.onActionPressed,
    this.showAtTop = false,
  });
}

class _DeckIcon extends StatelessWidget {
  final String? iconUri;

  const _DeckIcon({required this.iconUri});

  @override
  Widget build(BuildContext context) {
    final fallback = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'lib/assets/images/deck_default_2.png',
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

class _HomeBrandTitle extends StatelessWidget {
  const _HomeBrandTitle();

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        Theme.of(context).appBarTheme.titleTextStyle ??
        Theme.of(context).textTheme.titleLarge;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'lib/assets/images/ICO_2.png',
          width: 42,
          height: 42,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
        ),
        if (baseStyle != null) ...[
          const SizedBox(width: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Flash',
                  style: baseStyle.copyWith(
                    color: AppUiColors.primary(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: 'Lingo',
                  style: baseStyle.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
