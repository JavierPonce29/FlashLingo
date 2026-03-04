import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';
import 'package:flashcards_app/data/models/flashcard.dart';
import 'package:flashcards_app/features/importer/import_summary_page.dart';
import 'package:flashcards_app/features/importer/importer_provider.dart';
import 'package:flashcards_app/features/importer/importer_service.dart';

class HomeImportHelper {
  const HomeImportHelper._();
  static Future<void> pickAndImportFile(BuildContext context, WidgetRef ref) async {
    bool loaderOpen = false;
    void showLoader([String message = 'Procesando...']) {
      if (!context.mounted) return;
      loaderOpen = true;
      showDialog(
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
      if (!context.mounted) return;
      if (loaderOpen && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      loaderOpen = false;
    }
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'flashjp'],
      );
      if (result == null || result.files.single.path == null) return;
      final filePath = result.files.single.path!;
      final importerCtrl = ref.read(importerControllerProvider.notifier);

      // 1) PREVIEW
      if (!context.mounted) return;
      showLoader('Analizando paquete...');
      final preview = await importerCtrl.previewFlashcardPackage(filePath);
      closeLoaderIfOpen();
      // 2) Resolver conflicto (si existe)
      final options = await _resolveImportOptionsFromPreview(context, ref, preview);
      if (options == null) {
        importerCtrl.resetState();
        return; // usuario canceló
      }
      // 3) IMPORTAR
      if (!context.mounted) return;
      showLoader('Importando mazo...');
      final summary = await importerCtrl.importFlashcardPackageAdvanced(
        filePath,
        options: options,
      );
      closeLoaderIfOpen();
      importerCtrl.resetState();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Importación completada!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImportSummaryPage(summary: summary),
        ),
      );
    } on ImportConflictException catch (e) {
      closeLoaderIfOpen();
      if (!context.mounted) return;

      // Poco probable porque ya hacemos preview, pero lo manejamos por seguridad.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Conflicto de nombre detectado: "${e.preview.importedPackName}". '
                'Intenta de nuevo y elige actualizar o renombrar.',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      closeLoaderIfOpen();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al importar: $e"),
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
    // Si no existe conflicto, importar como mazo nuevo con el nombre original.
    if (!preview.deckNameExists) {
      return const ImportExecutionOptions.createNew();
    }

    final decision = await _showImportConflictDialog(context, preview);
    if (decision == null) return null;

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
    return showDialog<_ImportConflictDecision>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mazo ya existente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ya existe un mazo con el nombre:\n'
                  '"${preview.importedPackName}"',
            ),
            const SizedBox(height: 12),
            Text(
              'Archivo: ${preview.zipFileName}\n'
                  'Registros detectados: ${preview.sqliteRows}\n'
                  'Tarjetas estimadas: ${preview.estimatedCardsToImport}',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            const Text(
              '¿Qué deseas hacer?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.edit_note),
            label: const Text('Actualizar mazo'),
            onPressed: () =>
                Navigator.pop(ctx, _ImportConflictDecision.updateExisting),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Crear otro mazo'),
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
    final initialSuggestion = await _buildUniqueDeckNameSuggestion(
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
            setState(() => errorText = 'El nombre no puede estar vacío.');
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
              errorText = 'Ya existe un mazo con ese nombre.';
            });
            return;
          }
          Navigator.pop(ctx, raw);
        }

        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: const Text('Nombre del nuevo mazo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ingresa un nombre diferente para guardar este mazo.',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  enabled: !saving,
                  decoration: InputDecoration(
                    labelText: 'Nombre del mazo',
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
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: saving ? null : () => submit(setState),
                child: saving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Guardar'),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<String> _buildUniqueDeckNameSuggestion(
      WidgetRef ref, {
        required String baseName,
      }) async {
    final base = baseName.trim().isEmpty ? 'Mazo importado' : baseName.trim();
    if (!await _deckNameExists(ref, base)) return base;
    const suffixes = [' (copia)', ' (nuevo)', ' (2)'];
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
    final dsCount =
    await isar.deckSettings.filter().packNameEqualTo(normalized).count();
    if (dsCount > 0) return true;
    final fcCount =
    await isar.flashcards.filter().packNameEqualTo(normalized).count();
    return fcCount > 0;
  }
}

enum _ImportConflictDecision {
  updateExisting,
  createNewWithAnotherName,
}