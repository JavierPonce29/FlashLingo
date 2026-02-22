import 'package:flutter/material.dart';

import 'package:flashcards_app/features/importer/importer_service.dart';

class ImportSummaryPage extends StatelessWidget {
  final ImportSummary summary;

  const ImportSummaryPage({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isUpdate = summary.action == ImportDeckConflictAction.updateExistingDeck;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de importación'),
      ),
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
                          isUpdate ? 'Actualización de mazo' : 'Importación de mazo nuevo',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _kv('Archivo', summary.zipFileName),
                  _kv('Mazo importado', summary.importedPackName),
                  _kv('Mazo guardado', summary.finalPackName),
                  _kv('Idioma', summary.isoCode),
                  _kv('Modo', isUpdate ? 'Actualizar existente' : 'Crear nuevo'),
                  if (summary.targetDeckExistedBeforeImport) _kv('Mazo previo', 'Sí'),
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
                        value: summary.cardsProcessed.toString(),
                        color: Colors.blueGrey,
                      ),
                      _metricChip(
                        context,
                        label: 'Creadas',
                        value: summary.cardsCreated.toString(),
                        color: Colors.blue,
                      ),
                      _metricChip(
                        context,
                        label: 'Actualizadas',
                        value: summary.cardsUpdated.toString(),
                        color: Colors.orange,
                      ),
                      _metricChip(
                        context,
                        label: 'Sin cambios',
                        value: summary.cardsUnchanged.toString(),
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _kv('Registros SQLite leídos', '${summary.sqliteRowsRead}'),
                  _kv(
                    'Duplicadas dentro del archivo (lógicas)',
                    '${summary.duplicateLogicalCardsInImport}',
                  ),
                  _kv(
                    'Tarjetas existentes no presentes en el archivo',
                    '${summary.existingCardsNotPresentInImport} (no eliminadas)',
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
                    'Configuración del mazo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _kv('DeckSettings creado', summary.deckSettingsCreated ? 'Sí' : 'No'),
                  _kv('DeckSettings actualizado', summary.deckSettingsUpdated ? 'Sí' : 'No'),
                  _kv('DeckSettings preservado', summary.deckSettingsPreserved ? 'Sí' : 'No'),
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
                    'Multimedia y extracción',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _kv('Entradas ZIP totales', '${summary.zipEntriesTotal}'),
                  _kv('Archivos reales en ZIP', '${summary.zipRealFileEntries}'),
                  _kv('Archivos extraídos', '${summary.extractedFilesWritten}'),
                  _kv('Carpetas creadas', '${summary.extractedDirsCreated}'),
                  _kv('Colisiones renombradas', '${summary.extractedCollisions}'),
                  _kv('Omitidos en extracción', '${summary.extractedSkipped}'),
                  _kv('Errores de extracción', '${summary.extractedErrors}'),
                  const Divider(height: 20),
                  _kv('Media copiada', '${summary.mediaFilesCopied}'),
                  _kv('Media omitida', '${summary.mediaFilesSkipped}'),
                  _kv('Claves media duplicadas', '${summary.mediaDuplicateKeys}'),
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
                    'Diagnóstico de media en tarjetas',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _kv('Audio de palabra faltante', '${summary.missingWordAudio}'),
                  _kv('Audio de oración faltante', '${summary.missingSentenceAudio}'),
                  _kv('Imágenes faltantes', '${summary.missingImages}'),
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