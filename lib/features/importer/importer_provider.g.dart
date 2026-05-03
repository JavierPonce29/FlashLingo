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
    r'ac7a379c792f66a78fdcb612874ea88b641e213a';

/// See also [ImporterController].
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
