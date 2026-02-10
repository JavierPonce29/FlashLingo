import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/features/importer/importer_service.dart';

part 'importer_provider.g.dart';

@riverpod
ImporterService importerService(ImporterServiceRef ref) {
  // ✅ NO usar .requireValue aquí: puede crashear si alguien intenta importar
  // mientras la DB aún está cargando.
  //
  // Tomamos Isar desde el AsyncValue si ya está listo; si no, intentamos
  // recuperar la instancia global. Si aún no existe, lanzamos un error claro.
  final asyncIsar = ref.watch(isarDbProvider);
  final isar = asyncIsar.valueOrNull ?? Isar.getInstance();

  if (isar == null) {
    throw StateError(
      'Isar DB aún no está inicializada. Espera a que termine de cargar antes de importar.',
    );
  }

  return ImporterService(isar);
}
