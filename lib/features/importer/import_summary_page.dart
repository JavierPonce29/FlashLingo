import 'package:flutter/material.dart';
import 'package:flashcards_app/features/importer/importer_service.dart';

class ImportSummaryPage extends StatelessWidget {
  final ImportSummary summary;
  const ImportSummaryPage({super.key, required this.summary});
  T? _try<T>(T Function(dynamic s) getter) {
    try {
      return getter(summary as dynamic);
    } catch (_) {
      return null;
    }
  }
  String _s(String? v, {String fallback = '—'}) {
    final t = v?.trim();
    return (t == null || t.isEmpty) ? fallback : t;
  }
  @override
  Widget build(BuildContext context) {
    // -------- Compat: campos básicos --------
    final action = _try<ImportDeckConflictAction?>((s) => s.action);
    final zipFileName = _s(_try<String?>((s) => s.zipFileName));
    final importedPackName = _s(_try<String?>((s) => s.importedPackName));
    final finalPackName = _s(
      _try<String?>((s) => s.finalPackName) ?? _try<String?>((s) => s.targetPackName),
    );
    final isoCode = _s(_try<String?>((s) => s.isoCode));
    // -------- Compat: settings flags --------
    final deckSettingsCreated = _try<bool?>((s) => s.deckSettingsCreated) ?? false;
    final deckSettingsUpdated = _try<bool?>((s) => s.deckSettingsUpdated) ?? false;
    final deckSettingsPreserved = _try<bool?>((s) => s.deckSettingsPreserved) ?? false;
    // -------- Compat: info “update/new” --------
    final targetDeckExistedBeforeImport =
    _try<bool?>((s) => s.targetDeckExistedBeforeImport);
    final bool isUpdate = action == ImportDeckConflictAction.updateExistingDeck ||
        (action == null && (deckSettingsUpdated || deckSettingsPreserved));
    // -------- Compat: tarjetas --------
    final cardsCreated = _try<int?>((s) => s.cardsCreated) ?? 0;
    final cardsUpdated = _try<int?>((s) => s.cardsUpdated) ?? 0;
    final cardsUnchanged = _try<int?>((s) => s.cardsUnchanged) ?? 0;
    final cardsProcessed = _try<int?>((s) => s.cardsProcessed) ??
        (cardsCreated + cardsUpdated + cardsUnchanged);
    final sqliteRowsRead =
        _try<int?>((s) => s.sqliteRowsRead) ?? _try<int?>((s) => s.sqliteRows);
    final duplicateLogicalCardsInImport =
    _try<int?>((s) => s.duplicateLogicalCardsInImport);
    final existingCardsNotPresentInImport =
    _try<int?>((s) => s.existingCardsNotPresentInImport);
    // -------- Compat: extracción/zip --------
    final zipEntriesTotal =
        _try<int?>((s) => s.zipEntriesTotal) ?? _try<int?>((s) => s.archiveEntriesTotal);
    final zipRealFileEntries =
        _try<int?>((s) => s.zipRealFileEntries) ?? _try<int?>((s) => s.archiveRealFileEntries);
    final extractedFilesWritten = _try<int?>((s) => s.extractedFilesWritten);
    final extractedDirsCreated = _try<int?>((s) => s.extractedDirsCreated);
    final extractedCollisions = _try<int?>((s) => s.extractedCollisions);
    final extractedSkipped = _try<int?>((s) => s.extractedSkipped);
    final extractedErrors = _try<int?>((s) => s.extractedErrors);
    // -------- Compat: media copiada --------
    final mediaFilesCopied = _try<int?>((s) => s.mediaFilesCopied);
    final mediaFilesSkipped = _try<int?>((s) => s.mediaFilesSkipped);
    final mediaDuplicateKeys =
        _try<int?>((s) => s.mediaDuplicateKeys) ?? _try<int?>((s) => s.mediaKeyCollisions);
    // -------- Compat: diagnóstico de media en tarjetas --------
    final missingWordAudio = _try<int?>((s) => s.missingWordAudio);
    final missingSentenceAudio = _try<int?>((s) => s.missingSentenceAudio);
    final missingImages = _try<int?>((s) => s.missingImages);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de importación'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // =============================
          // Card 1: info general
          // =============================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(isUpdate ? Icons.system_update_alt : Icons.library_add),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isUpdate ? 'Actualización de mazo' : 'Importación de mazo nuevo',
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
                  _kv('Modo', isUpdate ? 'Actualizar existente' : 'Crear nuevo'),
                  if (targetDeckExistedBeforeImport == true) _kv('Mazo previo', 'Sí'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // =============================
          // Card 2: Tarjetas
          // =============================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tarjetas', style: Theme.of(context).textTheme.titleMedium),
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
                        color: Colors.blue,
                      ),
                      _metricChip(
                        context,
                        label: 'Actualizadas',
                        value: cardsUpdated.toString(),
                        color: Colors.orange,
                      ),
                      _metricChip(
                        context,
                        label: 'Sin cambios',
                        value: cardsUnchanged.toString(),
                        color: Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  if (sqliteRowsRead != null) _kv('Registros SQLite leídos', '$sqliteRowsRead'),
                  if (duplicateLogicalCardsInImport != null)
                    _kv(
                      'Duplicadas dentro del archivo (lógicas)',
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

          // =============================
          // Card 3: Configuración del mazo
          // =============================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Configuración del mazo', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _kv('DeckSettings creado', deckSettingsCreated ? 'Sí' : 'No'),
                  _kv('DeckSettings actualizado', deckSettingsUpdated ? 'Sí' : 'No'),
                  _kv('DeckSettings preservado', deckSettingsPreserved ? 'Sí' : 'No'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // =============================
          // Card 4: Multimedia y extracción
          // =============================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Multimedia y extracción', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (zipEntriesTotal != null) _kv('Entradas ZIP totales', '$zipEntriesTotal'),
                  if (zipRealFileEntries != null) _kv('Archivos reales en ZIP', '$zipRealFileEntries'),
                  // Estos campos existen en la versión “larga” (antigua). Si no existen, simplemente no se muestran.
                  if (extractedFilesWritten != null) _kv('Archivos extraídos', '$extractedFilesWritten'),
                  if (extractedDirsCreated != null) _kv('Carpetas creadas', '$extractedDirsCreated'),
                  if (extractedCollisions != null) _kv('Colisiones renombradas', '$extractedCollisions'),
                  if (extractedSkipped != null) _kv('Omitidos en extracción', '$extractedSkipped'),
                  if (extractedErrors != null) _kv('Errores de extracción', '$extractedErrors'),
                  const Divider(height: 20),
                  if (mediaFilesCopied != null) _kv('Media copiada', '$mediaFilesCopied'),
                  if (mediaFilesSkipped != null) _kv('Media omitida', '$mediaFilesSkipped'),
                  if (mediaDuplicateKeys != null) _kv('Claves media duplicadas', '$mediaDuplicateKeys'),
                  if (zipEntriesTotal == null &&
                      zipRealFileEntries == null &&
                      extractedFilesWritten == null &&
                      mediaFilesCopied == null &&
                      mediaDuplicateKeys == null)
                    const Text('—', style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // =============================
          // Card 5: Diagnóstico de media en tarjetas
          // =============================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Diagnóstico de media en tarjetas', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (missingWordAudio != null) _kv('Audio de palabra faltante', '$missingWordAudio'),
                  if (missingSentenceAudio != null) _kv('Audio de oración faltante', '$missingSentenceAudio'),
                  if (missingImages != null) _kv('Imágenes faltantes', '$missingImages'),
                  if (missingWordAudio == null && missingSentenceAudio == null && missingImages == null)
                    const Text('—', style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // =============================
          // Botón Volver
          // =============================
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.95),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: color.withValues(alpha: 0.95),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}