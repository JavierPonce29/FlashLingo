import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/features/importer/import_summary_page.dart';
import 'package:flashcards_app/features/importer/importer_provider.dart';
import 'package:flashcards_app/features/importer/importer_service.dart';
import 'package:flashcards_app/l10n/app_localizations.dart';

class HomeImportHelper {
  const HomeImportHelper._();

  static Future<void> pickAndImportFile(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = context.l10n;
    bool loaderOpen = false;
    ValueNotifier<ImportProgressUpdate>? progressNotifier;

    void closeLoaderIfOpen() {
      if (!context.mounted) return;
      if (loaderOpen && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      loaderOpen = false;
    }

    void disposeProgressNotifier() {
      progressNotifier?.dispose();
      progressNotifier = null;
    }

    void showProgressDialog(String title) {
      if (!context.mounted || progressNotifier == null) return;
      loaderOpen = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (_) => PopScope(
          canPop: false,
          child: _ImportProgressDialog(
            title: title,
            progressListenable: progressNotifier!,
          ),
        ),
      );
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'flashjp'],
      );
      if (result == null || result.files.single.path == null) return;

      final filePath = result.files.single.path!;
      final importerCtrl = ref.read(importerControllerProvider.notifier);

      if (!context.mounted) return;
      progressNotifier = ValueNotifier<ImportProgressUpdate>(
        const ImportProgressUpdate(
          phase: ImportProgressPhase.preparingPackage,
          overallProgress: 0,
        ),
      );
      showProgressDialog(l10n.tr('import_analyzing'));
      final preview = await importerCtrl.previewFlashcardPackage(
        filePath,
        onProgress: (update) {
          progressNotifier?.value = update;
        },
      );
      closeLoaderIfOpen();
      disposeProgressNotifier();

      if (!context.mounted) return;
      final options = await _resolveImportOptionsFromPreview(
        context,
        ref,
        preview,
      );
      if (options == null) {
        importerCtrl.resetState();
        return;
      }

      if (!context.mounted) return;
      progressNotifier = ValueNotifier<ImportProgressUpdate>(
        const ImportProgressUpdate(
          phase: ImportProgressPhase.preparingPackage,
          overallProgress: 0,
        ),
      );
      showProgressDialog(l10n.tr('import_importing'));
      final summary = await importerCtrl.importFlashcardPackageAdvanced(
        filePath,
        options: options,
        onProgress: (update) {
          progressNotifier?.value = update;
        },
      );
      closeLoaderIfOpen();
      disposeProgressNotifier();
      importerCtrl.resetState();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tr('import_completed')),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ImportSummaryPage(summary: summary)),
      );
    } on ImportConflictException catch (e) {
      closeLoaderIfOpen();
      disposeProgressNotifier();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.tr(
              'import_conflict_detected',
              params: <String, Object?>{'name': e.preview.importedPackName},
            ),
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (_) {
      closeLoaderIfOpen();
      disposeProgressNotifier();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tr('import_error')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<ImportExecutionOptions?> _resolveImportOptionsFromPreview(
    BuildContext context,
    WidgetRef ref,
    ImportPreviewResult preview,
  ) async {
    if (!preview.deckNameExists) {
      return const ImportExecutionOptions.createNew();
    }

    final decision = await _showImportConflictDialog(context, preview);
    if (decision == null) return null;
    if (!context.mounted) return null;

    switch (decision) {
      case _ImportConflictDecision.updateExisting:
        return const ImportExecutionOptions.updateExisting(
          updateDeckSettingsFromManifest: false,
        );
      case _ImportConflictDecision.createNewWithAnotherName:
        final customName = await _promptNewDeckName(
          context,
          ref,
          suggestedBaseName: preview.importedPackName,
        );
        if (customName == null) return null;
        return ImportExecutionOptions.createNew(customPackName: customName);
    }
  }

  static Future<_ImportConflictDecision?> _showImportConflictDialog(
    BuildContext context,
    ImportPreviewResult preview,
  ) async {
    final l10n = context.l10n;
    return showDialog<_ImportConflictDecision>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.tr('import_conflict_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.tr('import_conflict_line1')}\n"${preview.importedPackName}"',
            ),
            const SizedBox(height: 12),
            Text(
              '${l10n.tr('import_file_label')}: ${preview.zipFileName}\n'
              '${l10n.tr('import_rows_label')}: ${preview.sqliteRows}\n'
              '${l10n.tr('import_estimated_label')}: ${preview.estimatedCardsToImport}',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.tr('import_conflict_question'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.tr('common_cancel')),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.edit_note),
            label: Text(l10n.tr('import_update_action')),
            onPressed: () =>
                Navigator.pop(ctx, _ImportConflictDecision.updateExisting),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: Text(l10n.tr('import_create_other_action')),
            onPressed: () => Navigator.pop(
              ctx,
              _ImportConflictDecision.createNewWithAnotherName,
            ),
          ),
        ],
      ),
    );
  }

  static Future<String?> _promptNewDeckName(
    BuildContext context,
    WidgetRef ref, {
    required String suggestedBaseName,
  }) async {
    final l10n = context.l10n;
    final initialSuggestion = await _buildUniqueDeckNameSuggestion(
      context,
      ref,
      baseName: suggestedBaseName,
    );

    if (!context.mounted) return null;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final controller = TextEditingController(text: initialSuggestion);
        String? errorText;
        bool saving = false;

        Future<void> submit(StateSetter setState) async {
          final raw = controller.text.trim();
          if (raw.isEmpty) {
            setState(() => errorText = l10n.tr('import_name_empty'));
            return;
          }
          setState(() {
            saving = true;
            errorText = null;
          });

          final exists = await _deckNameExists(ref, raw);
          if (!ctx.mounted) return;
          if (exists) {
            setState(() {
              saving = false;
              errorText = l10n.tr('import_name_exists');
            });
            return;
          }
          Navigator.pop(ctx, raw);
        }

        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: Text(l10n.tr('import_new_name_title')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.tr('import_new_name_description')),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  enabled: !saving,
                  decoration: InputDecoration(
                    labelText: l10n.tr('import_deck_name_label'),
                    errorText: errorText,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => submit(setState),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(ctx),
                child: Text(l10n.tr('common_cancel')),
              ),
              ElevatedButton(
                onPressed: saving ? null : () => submit(setState),
                child: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.tr('common_save')),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<String> _buildUniqueDeckNameSuggestion(
    BuildContext context,
    WidgetRef ref, {
    required String baseName,
  }) async {
    final l10n = context.l10n;
    final base = baseName.trim().isEmpty
        ? l10n.tr('import_default_deck_name')
        : baseName.trim();
    if (!await _deckNameExists(ref, base)) return base;

    final suffixes = <String>[
      l10n.tr('import_copy_suffix'),
      l10n.tr('import_new_suffix'),
      ' (2)',
    ];
    for (final suffix in suffixes) {
      final candidate = '$base$suffix';
      if (!await _deckNameExists(ref, candidate)) return candidate;
    }

    int i = 2;
    while (true) {
      final candidate = '$base ($i)';
      if (!await _deckNameExists(ref, candidate)) return candidate;
      i++;
    }
  }

  static Future<bool> _deckNameExists(WidgetRef ref, String packName) async {
    final normalized = packName.trim();
    if (normalized.isEmpty) return false;

    final isar = await ref.read(isarDbProvider.future);
    final dsCount = await isar.deckSettings
        .filter()
        .packNameEqualTo(normalized)
        .count();
    if (dsCount > 0) return true;

    final fcCount = await isar.flashcards
        .filter()
        .packNameEqualTo(normalized)
        .count();
    return fcCount > 0;
  }
}

class _ImportProgressDialog extends StatelessWidget {
  const _ImportProgressDialog({
    required this.title,
    required this.progressListenable,
  });

  final String title;
  final ValueListenable<ImportProgressUpdate> progressListenable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(title),
      content: ValueListenableBuilder<ImportProgressUpdate>(
        valueListenable: progressListenable,
        builder: (context, progress, _) {
          final percent = (progress.overallProgress * 100).round().clamp(
            0,
            100,
          );
          final totalItems = progress.totalItems ?? 0;
          final processedItems = progress.processedItems ?? 0;
          final remainingItems = totalItems > 0
              ? (totalItems - processedItems).clamp(0, totalItems)
              : 0;
          return SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tr(
                    'import_progress_phase',
                    params: <String, Object?>{
                      'phase': _phaseLabel(context, progress.phase),
                    },
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.overallProgress.clamp(0.0, 1.0),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.tr(
                    'import_progress_percent',
                    params: <String, Object?>{'percent': percent},
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (progress.hasKnownItemCount) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.tr(
                      'import_progress_items',
                      params: <String, Object?>{
                        'current': processedItems,
                        'total': totalItems,
                      },
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.tr(
                      'import_progress_remaining',
                      params: <String, Object?>{'count': remainingItems},
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _phaseLabel(BuildContext context, ImportProgressPhase phase) {
    final l10n = context.l10n;
    switch (phase) {
      case ImportProgressPhase.preparingPackage:
        return l10n.tr('import_progress_phase_preparing');
      case ImportProgressPhase.extractingArchive:
        return l10n.tr('import_progress_phase_extracting');
      case ImportProgressPhase.scanningPackage:
        return l10n.tr('import_progress_phase_scanning');
      case ImportProgressPhase.copyingMedia:
        return l10n.tr('import_progress_phase_media');
      case ImportProgressPhase.readingDatabase:
        return l10n.tr('import_progress_phase_database');
      case ImportProgressPhase.importingCards:
        return l10n.tr('import_progress_phase_cards');
      case ImportProgressPhase.cleaningUp:
        return l10n.tr('import_progress_phase_cleanup');
      case ImportProgressPhase.finalizing:
        return l10n.tr('import_progress_phase_finalizing');
    }
  }
}

enum _ImportConflictDecision { updateExisting, createNewWithAnotherName }
