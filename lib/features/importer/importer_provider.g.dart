// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'importer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$importerServiceHash() => r'0917c4438b7ed7635eceaa9b2b8d2e517c7d8424';

/// See also [importerService].
@ProviderFor(importerService)
final importerServiceProvider = AutoDisposeProvider<ImporterService>.internal(
  importerService,
  name: r'importerServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$importerServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ImporterServiceRef = AutoDisposeProviderRef<ImporterService>;
String _$importerControllerHash() =>
    r'f74f75c12fd6142919d59b0a16f1dafc066ee498';

/// Controlador de importación para UI:
/// - expone loading/error
/// - permite preview + import (legacy wrapper) + import avanzado
///
/// Copied from [ImporterController].
@ProviderFor(ImporterController)
final importerControllerProvider =
    AutoDisposeNotifierProvider<ImporterController, AsyncValue<void>>.internal(
  ImporterController.new,
  name: r'importerControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$importerControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ImporterController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
