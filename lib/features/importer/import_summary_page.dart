import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flashcards_app/features/importer/importer_service.dart';
import 'package:flashcards_app/features/onboarding/guided_tour_controller.dart';
import 'package:flashcards_app/features/onboarding/tour_widgets.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';
import 'package:flashcards_app/theme/app_ui_colors.dart';

class ImportSummaryPage extends ConsumerWidget {
  final ImportSummary summary;

  const ImportSummaryPage({super.key, required this.summary});

  T? _try<T>(T Function(dynamic value) getter) {
    try {
      return getter(summary as dynamic);
    } catch (_) {
      return null;
    }
  }

  String _safeText(String? value, {String fallback = '--'}) {
    final text = value?.trim();
    return (text == null || text.isEmpty) ? fallback : text;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final guidedTourState = ref.watch(guidedTourProvider);
    final tourStep = guidedTourState.step;
    final isTourInSummary = tourStep.isImportSummaryStep;
    final canPop =
        !isTourInSummary || tourStep == GuidedTourStep.importSummaryExit;

    final action = _try<ImportDeckConflictAction?>((s) => s.action);
    final zipFileName = _safeText(_try<String?>((s) => s.zipFileName));
    final importedPackName = _safeText(
      _try<String?>((s) => s.importedPackName),
    );
    final finalPackName = _safeText(
      _try<String?>((s) => s.finalPackName) ??
          _try<String?>((s) => s.targetPackName),
    );
    final isoCode = _safeText(_try<String?>((s) => s.isoCode));

    final deckSettingsCreated =
        _try<bool?>((s) => s.deckSettingsCreated) ?? false;
    final deckSettingsUpdated =
        _try<bool?>((s) => s.deckSettingsUpdated) ?? false;
    final deckSettingsPreserved =
        _try<bool?>((s) => s.deckSettingsPreserved) ?? false;
    final targetDeckExistedBeforeImport = _try<bool?>(
      (s) => s.targetDeckExistedBeforeImport,
    );

    final isUpdate =
        action == ImportDeckConflictAction.updateExistingDeck ||
        (action == null && (deckSettingsUpdated || deckSettingsPreserved));

    final cardsCreated = _try<int?>((s) => s.cardsCreated) ?? 0;
    final cardsUpdated = _try<int?>((s) => s.cardsUpdated) ?? 0;
    final cardsUnchanged = _try<int?>((s) => s.cardsUnchanged) ?? 0;
    final cardsProcessed =
        _try<int?>((s) => s.cardsProcessed) ??
        (cardsCreated + cardsUpdated + cardsUnchanged);

    final sqliteRowsRead =
        _try<int?>((s) => s.sqliteRowsRead) ?? _try<int?>((s) => s.sqliteRows);
    final duplicateLogicalCardsInImport = _try<int?>(
      (s) => s.duplicateLogicalCardsInImport,
    );
    final existingCardsNotPresentInImport = _try<int?>(
      (s) => s.existingCardsNotPresentInImport,
    );

    final zipEntriesTotal =
        _try<int?>((s) => s.zipEntriesTotal) ??
        _try<int?>((s) => s.archiveEntriesTotal);
    final zipRealFileEntries =
        _try<int?>((s) => s.zipRealFileEntries) ??
        _try<int?>((s) => s.archiveRealFileEntries);
    final extractedFilesWritten = _try<int?>((s) => s.extractedFilesWritten);
    final extractedDirsCreated = _try<int?>((s) => s.extractedDirsCreated);
    final extractedCollisions = _try<int?>((s) => s.extractedCollisions);
    final extractedSkipped = _try<int?>((s) => s.extractedSkipped);
    final extractedErrors = _try<int?>((s) => s.extractedErrors);

    final mediaFilesCopied = _try<int?>((s) => s.mediaFilesCopied);
    final mediaFilesSkipped = _try<int?>((s) => s.mediaFilesSkipped);
    final mediaDuplicateKeys =
        _try<int?>((s) => s.mediaDuplicateKeys) ??
        _try<int?>((s) => s.mediaKeyCollisions);

    final missingWordAudio = _try<int?>((s) => s.missingWordAudio);
    final missingSentenceAudio = _try<int?>((s) => s.missingSentenceAudio);
    final missingImages = _try<int?>((s) => s.missingImages);

    final mutedTextColor = AppUiColors.mutedText(context);

    final page = Scaffold(
      appBar: AppBar(title: Text(l10n.tr('import_summary_title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TourHighlight(
            highlighted: tourStep == GuidedTourStep.importSummaryIntro,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isUpdate
                              ? Icons.system_update_alt
                              : Icons.library_add,
                          color: AppUiColors.primary(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isUpdate
                                ? l10n.tr('import_summary_update_title')
                                : l10n.tr('import_summary_new_title'),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppUiColors.primary(context),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _kv(l10n.tr('import_summary_file'), zipFileName),
                    _kv(
                      l10n.tr('import_summary_imported_deck'),
                      importedPackName,
                    ),
                    _kv(l10n.tr('import_summary_saved_deck'), finalPackName),
                    _kv(l10n.tr('import_summary_language'), isoCode),
                    _kv(
                      l10n.tr('import_summary_mode'),
                      isUpdate
                          ? l10n.tr('import_summary_mode_update')
                          : l10n.tr('import_summary_mode_create'),
                    ),
                    if (targetDeckExistedBeforeImport == true)
                      _kv(
                        l10n.tr('import_summary_previous_deck'),
                        l10n.tr('common_yes'),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TourHighlight(
            highlighted: tourStep == GuidedTourStep.importSummaryCards,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                      context,
                      icon: Icons.copy_all_outlined,
                      title: l10n.tr('import_summary_cards_section'),
                      color: AppUiColors.primary(context),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _metricChip(
                          context,
                          label: l10n.tr('import_summary_processed'),
                          value: cardsProcessed.toString(),
                          color: AppUiColors.primary(context),
                        ),
                        _metricChip(
                          context,
                          label: l10n.tr('import_summary_created'),
                          value: cardsCreated.toString(),
                          color: AppUiColors.secondary(context),
                        ),
                        _metricChip(
                          context,
                          label: l10n.tr('import_summary_updated'),
                          value: cardsUpdated.toString(),
                          color: AppUiColors.warning(context),
                        ),
                        _metricChip(
                          context,
                          label: l10n.tr('import_summary_unchanged'),
                          value: cardsUnchanged.toString(),
                          color: AppUiColors.success(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (sqliteRowsRead != null)
                      _kv(
                        l10n.tr('import_summary_sqlite_rows'),
                        '$sqliteRowsRead',
                      ),
                    if (duplicateLogicalCardsInImport != null)
                      _kv(
                        l10n.tr('import_summary_duplicates'),
                        '$duplicateLogicalCardsInImport',
                      ),
                    if (existingCardsNotPresentInImport != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text(
                          l10n.tr(
                            'import_summary_existing_missing',
                            params: <String, Object?>{
                              'count': existingCardsNotPresentInImport,
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TourHighlight(
            highlighted: tourStep == GuidedTourStep.importSummarySettings,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                      context,
                      icon: Icons.settings_suggest_outlined,
                      title: l10n.tr('import_summary_settings_section'),
                      color: AppUiColors.primary(context),
                    ),
                    const SizedBox(height: 12),
                    _kv(
                      l10n.tr('import_summary_settings_created'),
                      deckSettingsCreated
                          ? l10n.tr('common_yes')
                          : l10n.tr('common_no'),
                    ),
                    _kv(
                      l10n.tr('import_summary_settings_updated'),
                      deckSettingsUpdated
                          ? l10n.tr('common_yes')
                          : l10n.tr('common_no'),
                    ),
                    _kv(
                      l10n.tr('import_summary_settings_preserved'),
                      deckSettingsPreserved
                          ? l10n.tr('common_yes')
                          : l10n.tr('common_no'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TourHighlight(
            highlighted: tourStep == GuidedTourStep.importSummaryMedia,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                      context,
                      icon: Icons.perm_media_outlined,
                      title: l10n.tr('import_summary_media_section'),
                      color: AppUiColors.primary(context),
                    ),
                    const SizedBox(height: 12),
                    if (zipEntriesTotal != null)
                      _kv(
                        l10n.tr('import_summary_zip_entries'),
                        '$zipEntriesTotal',
                      ),
                    if (zipRealFileEntries != null)
                      _kv(
                        l10n.tr('import_summary_zip_files'),
                        '$zipRealFileEntries',
                      ),
                    if (extractedFilesWritten != null)
                      _kv(
                        l10n.tr('import_summary_extracted_files'),
                        '$extractedFilesWritten',
                      ),
                    if (extractedDirsCreated != null)
                      _kv(
                        l10n.tr('import_summary_created_dirs'),
                        '$extractedDirsCreated',
                      ),
                    if (extractedCollisions != null)
                      _kv(
                        l10n.tr('import_summary_collisions'),
                        '$extractedCollisions',
                      ),
                    if (extractedSkipped != null)
                      _kv(
                        l10n.tr('import_summary_extracted_skipped'),
                        '$extractedSkipped',
                      ),
                    if (extractedErrors != null)
                      _kv(
                        l10n.tr('import_summary_extracted_errors'),
                        '$extractedErrors',
                      ),
                    const Divider(height: 20),
                    if (mediaFilesCopied != null)
                      _kv(
                        l10n.tr('import_summary_media_copied'),
                        '$mediaFilesCopied',
                      ),
                    if (mediaFilesSkipped != null)
                      _kv(
                        l10n.tr('import_summary_media_skipped'),
                        '$mediaFilesSkipped',
                      ),
                    if (mediaDuplicateKeys != null)
                      _kv(
                        l10n.tr('import_summary_media_duplicate_keys'),
                        '$mediaDuplicateKeys',
                      ),
                    if (zipEntriesTotal == null &&
                        zipRealFileEntries == null &&
                        extractedFilesWritten == null &&
                        mediaFilesCopied == null &&
                        mediaDuplicateKeys == null)
                      Text('--', style: TextStyle(color: mutedTextColor)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TourHighlight(
            highlighted: tourStep == GuidedTourStep.importSummaryDiagnostics,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                      context,
                      icon: Icons.fact_check_outlined,
                      title: l10n.tr('import_summary_media_diag_section'),
                      color: AppUiColors.primary(context),
                    ),
                    const SizedBox(height: 12),
                    if (missingWordAudio != null)
                      _kv(
                        l10n.tr('import_summary_missing_word_audio'),
                        '$missingWordAudio',
                      ),
                    if (missingSentenceAudio != null)
                      _kv(
                        l10n.tr('import_summary_missing_sentence_audio'),
                        '$missingSentenceAudio',
                      ),
                    if (missingImages != null)
                      _kv(
                        l10n.tr('import_summary_missing_images'),
                        '$missingImages',
                      ),
                    if (missingWordAudio == null &&
                        missingSentenceAudio == null &&
                        missingImages == null)
                      Text('--', style: TextStyle(color: mutedTextColor)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.tr('common_back')),
                  onPressed: () {
                    if (!isTourInSummary || canPop) {
                      if (isTourInSummary) {
                        ref
                            .read(guidedTourProvider.notifier)
                            .onImportSummaryClosed();
                      }
                      Navigator.pop(context);
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.tr('onboarding_tour_import_summary_blocked'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (!isTourInSummary) return page;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(guidedTourProvider.notifier).onImportSummaryClosed();
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.tr('onboarding_tour_import_summary_blocked')),
          ),
        );
      },
      child: Stack(
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
            bottom: 24,
            child: TourMessageCard(
              message: _tourSummaryMessage(l10n, tourStep),
              actionLabel: tourStep == GuidedTourStep.importSummaryExit
                  ? null
                  : l10n.tr('onboarding_tour_next'),
              onActionPressed: tourStep == GuidedTourStep.importSummaryExit
                  ? null
                  : () => ref
                        .read(guidedTourProvider.notifier)
                        .nextInImportSummary(),
            ),
          ),
        ],
      ),
    );
  }

  String _tourSummaryMessage(AppLocalizations l10n, GuidedTourStep step) {
    switch (step) {
      case GuidedTourStep.importSummaryIntro:
        return l10n.tr('onboarding_tour_import_intro');
      case GuidedTourStep.importSummaryCards:
        return l10n.tr('onboarding_tour_import_cards');
      case GuidedTourStep.importSummarySettings:
        return l10n.tr('onboarding_tour_import_settings');
      case GuidedTourStep.importSummaryMedia:
        return l10n.tr('onboarding_tour_import_media');
      case GuidedTourStep.importSummaryDiagnostics:
        return l10n.tr('onboarding_tour_import_diagnostics');
      case GuidedTourStep.importSummaryExit:
        return l10n.tr('onboarding_tour_import_exit');
      default:
        return '';
    }
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 210,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _metricChip(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = AppUiColors.isDark(context);
    final fillAlpha = isDark ? 0.20 : 0.12;
    final borderAlpha = isDark ? 0.45 : 0.35;
    final textAlpha = isDark ? 1.0 : 0.95;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: fillAlpha),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: borderAlpha)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: textAlpha),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: color.withValues(alpha: textAlpha),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
