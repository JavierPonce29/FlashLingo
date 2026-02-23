// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$decksStreamHash() => r'8b23ea1bedd44d3b6de9913fa6348d43e6e08b8a';

/// See also [decksStream].
@ProviderFor(decksStream)
final decksStreamProvider = StreamProvider<List<DeckSummary>>.internal(
  decksStream,
  name: r'decksStreamProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$decksStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DecksStreamRef = StreamProviderRef<List<DeckSummary>>;
String _$deleteDeckHash() => r'3388e1f02063f9346f35b70eae0e395eed770590';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [deleteDeck].
@ProviderFor(deleteDeck)
const deleteDeckProvider = DeleteDeckFamily();

/// See also [deleteDeck].
class DeleteDeckFamily extends Family<AsyncValue<void>> {
  /// See also [deleteDeck].
  const DeleteDeckFamily();

  /// See also [deleteDeck].
  DeleteDeckProvider call(
    String packName,
  ) {
    return DeleteDeckProvider(
      packName,
    );
  }

  @override
  DeleteDeckProvider getProviderOverride(
    covariant DeleteDeckProvider provider,
  ) {
    return call(
      provider.packName,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deleteDeckProvider';
}

/// See also [deleteDeck].
class DeleteDeckProvider extends FutureProvider<void> {
  /// See also [deleteDeck].
  DeleteDeckProvider(
    String packName,
  ) : this._internal(
          (ref) => deleteDeck(
            ref as DeleteDeckRef,
            packName,
          ),
          from: deleteDeckProvider,
          name: r'deleteDeckProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deleteDeckHash,
          dependencies: DeleteDeckFamily._dependencies,
          allTransitiveDependencies:
              DeleteDeckFamily._allTransitiveDependencies,
          packName: packName,
        );

  DeleteDeckProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.packName,
  }) : super.internal();

  final String packName;

  @override
  Override overrideWith(
    FutureOr<void> Function(DeleteDeckRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeleteDeckProvider._internal(
        (ref) => create(ref as DeleteDeckRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        packName: packName,
      ),
    );
  }

  @override
  FutureProviderElement<void> createElement() {
    return _DeleteDeckProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteDeckProvider && other.packName == packName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, packName.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DeleteDeckRef on FutureProviderRef<void> {
  /// The parameter `packName` of this provider.
  String get packName;
}

class _DeleteDeckProviderElement extends FutureProviderElement<void>
    with DeleteDeckRef {
  _DeleteDeckProviderElement(super.provider);

  @override
  String get packName => (origin as DeleteDeckProvider).packName;
}

String _$renameDeckHash() => r'87656b014d883703c5f235cec9dfe731d8205fdd';

/// See also [renameDeck].
@ProviderFor(renameDeck)
const renameDeckProvider = RenameDeckFamily();

/// See also [renameDeck].
class RenameDeckFamily extends Family<AsyncValue<void>> {
  /// See also [renameDeck].
  const RenameDeckFamily();

  /// See also [renameDeck].
  RenameDeckProvider call(
    String oldPackName,
    String newPackName,
  ) {
    return RenameDeckProvider(
      oldPackName,
      newPackName,
    );
  }

  @override
  RenameDeckProvider getProviderOverride(
    covariant RenameDeckProvider provider,
  ) {
    return call(
      provider.oldPackName,
      provider.newPackName,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'renameDeckProvider';
}

/// See also [renameDeck].
class RenameDeckProvider extends FutureProvider<void> {
  /// See also [renameDeck].
  RenameDeckProvider(
    String oldPackName,
    String newPackName,
  ) : this._internal(
          (ref) => renameDeck(
            ref as RenameDeckRef,
            oldPackName,
            newPackName,
          ),
          from: renameDeckProvider,
          name: r'renameDeckProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$renameDeckHash,
          dependencies: RenameDeckFamily._dependencies,
          allTransitiveDependencies:
              RenameDeckFamily._allTransitiveDependencies,
          oldPackName: oldPackName,
          newPackName: newPackName,
        );

  RenameDeckProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.oldPackName,
    required this.newPackName,
  }) : super.internal();

  final String oldPackName;
  final String newPackName;

  @override
  Override overrideWith(
    FutureOr<void> Function(RenameDeckRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RenameDeckProvider._internal(
        (ref) => create(ref as RenameDeckRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        oldPackName: oldPackName,
        newPackName: newPackName,
      ),
    );
  }

  @override
  FutureProviderElement<void> createElement() {
    return _RenameDeckProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RenameDeckProvider &&
        other.oldPackName == oldPackName &&
        other.newPackName == newPackName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, oldPackName.hashCode);
    hash = _SystemHash.combine(hash, newPackName.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RenameDeckRef on FutureProviderRef<void> {
  /// The parameter `oldPackName` of this provider.
  String get oldPackName;

  /// The parameter `newPackName` of this provider.
  String get newPackName;
}

class _RenameDeckProviderElement extends FutureProviderElement<void>
    with RenameDeckRef {
  _RenameDeckProviderElement(super.provider);

  @override
  String get oldPackName => (origin as RenameDeckProvider).oldPackName;
  @override
  String get newPackName => (origin as RenameDeckProvider).newPackName;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
