import 'package:flutter/material.dart';
import 'package:flashcards_app/features/importer/importer_service.dart';
import 'package:flashcards_app/theme/app_ui_colors.dart';

class ImportSummaryPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen de importacion')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isUpdate ? Icons.system_update_alt : Icons.library_add,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isUpdate
                              ? 'Actualizacion de mazo'
                              : 'Importacion de mazo nuevo',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _kv('Archivo', zipFileName),
                  _kv('Mazo importado', importedPackName),
                  _kv('Mazo guardado', finalPackName),
                  _kv('Idioma', isoCode),
                  _kv(
                    'Modo',
                    isUpdate ? 'Actualizar existente' : 'Crear nuevo',
                  ),
                  if (targetDeckExistedBeforeImport == true)
                    _kv('Mazo previo', 'Si'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tarjetas',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _metricChip(
                        context,
                        label: 'Procesadas',
                        value: cardsProcessed.toString(),
                        color: Colors.blueGrey,
                      ),
                      _metricChip(
                        context,
                        label: 'Creadas',
                        value: cardsCreated.toString(),
                        color: AppUiColors.info(context),
                      ),
                      _metricChip(
                        context,
                        label: 'Actualizadas',
                        value: cardsUpdated.toString(),
                        color: AppUiColors.warning(context),
                      ),
                      _metricChip(
                        context,
                        label: 'Sin cambios',
                        value: cardsUnchanged.toString(),
                        color: AppUiColors.success(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (sqliteRowsRead != null)
                    _kv('Registros SQLite leidos', '$sqliteRowsRead'),
                  if (duplicateLogicalCardsInImport != null)
                    _kv(
                      'Duplicadas dentro del archivo (logicas)',
                      '$duplicateLogicalCardsInImport',
                    ),
                  if (existingCardsNotPresentInImport != null)
                    _kv(
                      'Tarjetas existentes no presentes en el archivo',
                      '$existingCardsNotPresentInImport (no eliminadas)',
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuracion del mazo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _kv('DeckSettings creado', deckSettingsCreated ? 'Si' : 'No'),
                  _kv(
                    'DeckSettings actualizado',
                    deckSettingsUpdated ? 'Si' : 'No',
                  ),
                  _kv(
                    'DeckSettings preservado',
                    deckSettingsPreserved ? 'Si' : 'No',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Multimedia y extraccion',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (zipEntriesTotal != null)
                    _kv('Entradas ZIP totales', '$zipEntriesTotal'),
                  if (zipRealFileEntries != null)
                    _kv('Archivos reales en ZIP', '$zipRealFileEntries'),
                  if (extractedFilesWritten != null)
                    _kv('Archivos extraidos', '$extractedFilesWritten'),
                  if (extractedDirsCreated != null)
                    _kv('Carpetas creadas', '$extractedDirsCreated'),
                  if (extractedCollisions != null)
                    _kv('Colisiones renombradas', '$extractedCollisions'),
                  if (extractedSkipped != null)
                    _kv('Omitidos en extraccion', '$extractedSkipped'),
                  if (extractedErrors != null)
                    _kv('Errores de extraccion', '$extractedErrors'),
                  const Divider(height: 20),
                  if (mediaFilesCopied != null)
                    _kv('Media copiada', '$mediaFilesCopied'),
                  if (mediaFilesSkipped != null)
                    _kv('Media omitida', '$mediaFilesSkipped'),
                  if (mediaDuplicateKeys != null)
                    _kv('Claves media duplicadas', '$mediaDuplicateKeys'),
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
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diagnostico de media en tarjetas',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (missingWordAudio != null)
                    _kv('Audio de palabra faltante', '$missingWordAudio'),
                  if (missingSentenceAudio != null)
                    _kv('Audio de oracion faltante', '$missingSentenceAudio'),
                  if (missingImages != null)
                    _kv('Imagenes faltantes', '$missingImages'),
                  if (missingWordAudio == null &&
                      missingSentenceAudio == null &&
                      missingImages == null)
                    Text('--', style: TextStyle(color: mutedTextColor)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
