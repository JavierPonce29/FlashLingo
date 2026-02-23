// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$decksStreamHash() => r'2e95a5bb6460fdc74ffd2ffb4936f3b89d05987d';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
