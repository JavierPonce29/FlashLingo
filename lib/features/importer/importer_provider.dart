import 'dart:async';

import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/features/importer/importer_service.dart';

part 'importer_provider.g.dart';

@riverpod
ImporterService importerService(ImporterServiceRef ref) {
  // ✅ No usar requireValue aquí para evitar crash si la DB aún está cargando.
  // Intentamos primero el provider async y, si no está listo, la instancia global.
  final asyncIsar = ref.watch(isarDbProvider);
  final isar = asyncIsar.valueOrNull ?? Isar.getInstance();

  if (isar == null) {
    throw StateError(
      'Isar DB aún no está inicializada. Espera a que termine de cargar antes de importar.',
    );
  }

  return ImporterService(isar);
}

/// Controlador de importación para UI:
/// - expone loading/error
/// - permite preview + import normal + import avanzado
@riverpod
class ImporterController extends _$ImporterController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  /// Preview del paquete para detectar conflicto de nombre antes de importar.
  Future<ImportPreviewResult> previewFlashcardPackage(String zipFilePath) async {
    final service = ref.read(importerServiceProvider);

    state = const AsyncLoading();
    try {
      final preview = await service.previewFlashcardPackage(zipFilePath);
      state = const AsyncData(null);
      return preview;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Importación "legacy" (compatibilidad): si hay conflicto, el service lanza
  /// [ImportConflictException] y la UI decide qué hacer.
  Future<void> importFlashcardPackage(String zipFilePath) async {
    final service = ref.read(importerServiceProvider);

    state = const AsyncLoading();
    try {
      await service.importFlashcardPackage(zipFilePath);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Importación avanzada con resolución de conflicto explícita.
  Future<ImportSummary> importFlashcardPackageAdvanced(
      String zipFilePath, {
        required ImportExecutionOptions options,
      }) async {
    final service = ref.read(importerServiceProvider);

    state = const AsyncLoading();
    try {
      final summary = await service.importFlashcardPackageAdvanced(
        zipFilePath,
        options: options,
      );
      state = const AsyncData(null);
      return summary;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Limpia estado de error/loading para dejar el controlador "neutral".
  void resetState() {
    state = const AsyncData(null);
  }
}