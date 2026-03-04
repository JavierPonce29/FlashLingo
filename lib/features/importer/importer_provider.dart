import 'dart:async';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/features/importer/importer_service.dart';
part 'importer_provider.g.dart';

@riverpod
ImporterService importerService(ImporterServiceRef ref) {
  final asyncIsar = ref.watch(isarDbProvider);
  final isar = asyncIsar.valueOrNull ?? Isar.getInstance();
  if (isar == null) {
    throw StateError('Isar DB aún no está inicializada. Espera a que termine de cargar antes de importar.');
  }
  return ImporterService(isar);
}
@riverpod
class ImporterController extends _$ImporterController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }
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

  Future<void> importFlashcardPackage(String zipFilePath) async {
    final service = ref.read(importerServiceProvider);
    state = const AsyncLoading();
    try {
      final dyn = service as dynamic;
      try {
        await dyn.importFlashcardPackage(zipFilePath);
      } on NoSuchMethodError {
        // Fallback a la API actual
        await service.importFlashcardPackageAdvanced(
          zipFilePath,
          options: const ImportExecutionOptions.createNew(),
        );
      }
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

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
  void resetState() {
    state = const AsyncData(null);
  }
}