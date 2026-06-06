// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scores_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scoresRepositoryHash() => r'5294aef5cebb0d047efc099accc0c276d9d6e8e9';

/// See also [scoresRepository].
@ProviderFor(scoresRepository)
final scoresRepositoryProvider = AutoDisposeProvider<ScoresRepository>.internal(
  scoresRepository,
  name: r'scoresRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scoresRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ScoresRepositoryRef = AutoDisposeProviderRef<ScoresRepository>;
String _$fixturesHash() => r'4c975473ff24e1ae92a3564d96e95bafc6151844';

/// See also [fixtures].
@ProviderFor(fixtures)
final fixturesProvider = AutoDisposeFutureProvider<List<Fixture>>.internal(
  fixtures,
  name: r'fixturesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$fixturesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FixturesRef = AutoDisposeFutureProviderRef<List<Fixture>>;
String _$myGuessesHash() => r'92633de42a44d195cf7d9b5f1f9c2d5f50ffb4b5';

/// See also [myGuesses].
@ProviderFor(myGuesses)
final myGuessesProvider =
    AutoDisposeFutureProvider<Map<String, Guess>>.internal(
  myGuesses,
  name: r'myGuessesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myGuessesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyGuessesRef = AutoDisposeFutureProviderRef<Map<String, Guess>>;
String _$fixtureGuessHash() => r'7a688e709ce9e4ccca18631cec558e8100aefd0a';

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

/// See also [fixtureGuess].
@ProviderFor(fixtureGuess)
const fixtureGuessProvider = FixtureGuessFamily();

/// See also [fixtureGuess].
class FixtureGuessFamily extends Family<AsyncValue<Guess?>> {
  /// See also [fixtureGuess].
  const FixtureGuessFamily();

  /// See also [fixtureGuess].
  FixtureGuessProvider call(
    String fixtureId,
  ) {
    return FixtureGuessProvider(
      fixtureId,
    );
  }

  @override
  FixtureGuessProvider getProviderOverride(
    covariant FixtureGuessProvider provider,
  ) {
    return call(
      provider.fixtureId,
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
  String? get name => r'fixtureGuessProvider';
}

/// See also [fixtureGuess].
class FixtureGuessProvider extends AutoDisposeFutureProvider<Guess?> {
  /// See also [fixtureGuess].
  FixtureGuessProvider(
    String fixtureId,
  ) : this._internal(
          (ref) => fixtureGuess(
            ref as FixtureGuessRef,
            fixtureId,
          ),
          from: fixtureGuessProvider,
          name: r'fixtureGuessProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fixtureGuessHash,
          dependencies: FixtureGuessFamily._dependencies,
          allTransitiveDependencies:
              FixtureGuessFamily._allTransitiveDependencies,
          fixtureId: fixtureId,
        );

  FixtureGuessProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.fixtureId,
  }) : super.internal();

  final String fixtureId;

  @override
  Override overrideWith(
    FutureOr<Guess?> Function(FixtureGuessRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FixtureGuessProvider._internal(
        (ref) => create(ref as FixtureGuessRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        fixtureId: fixtureId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Guess?> createElement() {
    return _FixtureGuessProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FixtureGuessProvider && other.fixtureId == fixtureId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, fixtureId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FixtureGuessRef on AutoDisposeFutureProviderRef<Guess?> {
  /// The parameter `fixtureId` of this provider.
  String get fixtureId;
}

class _FixtureGuessProviderElement
    extends AutoDisposeFutureProviderElement<Guess?> with FixtureGuessRef {
  _FixtureGuessProviderElement(super.provider);

  @override
  String get fixtureId => (origin as FixtureGuessProvider).fixtureId;
}

String _$fixturesByMatchdayHash() =>
    r'201e04e2b6d6015eb2bbac3d05e4019fbb577f36';

/// Groups fixtures by matchday for display in the scores list.
///
/// Copied from [fixturesByMatchday].
@ProviderFor(fixturesByMatchday)
final fixturesByMatchdayProvider =
    AutoDisposeFutureProvider<Map<int, List<Fixture>>>.internal(
  fixturesByMatchday,
  name: r'fixturesByMatchdayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fixturesByMatchdayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FixturesByMatchdayRef
    = AutoDisposeFutureProviderRef<Map<int, List<Fixture>>>;
String _$guessNotifierHash() => r'5cf4db142417ffd3614dc80f794027ef6e0a2e0d';

abstract class _$GuessNotifier
    extends BuildlessAutoDisposeNotifier<AsyncValue<Guess?>> {
  late final String fixtureId;

  AsyncValue<Guess?> build(
    String fixtureId,
  );
}

/// Notifier that handles guess submission with loading/success/error state.
///
/// Copied from [GuessNotifier].
@ProviderFor(GuessNotifier)
const guessNotifierProvider = GuessNotifierFamily();

/// Notifier that handles guess submission with loading/success/error state.
///
/// Copied from [GuessNotifier].
class GuessNotifierFamily extends Family<AsyncValue<Guess?>> {
  /// Notifier that handles guess submission with loading/success/error state.
  ///
  /// Copied from [GuessNotifier].
  const GuessNotifierFamily();

  /// Notifier that handles guess submission with loading/success/error state.
  ///
  /// Copied from [GuessNotifier].
  GuessNotifierProvider call(
    String fixtureId,
  ) {
    return GuessNotifierProvider(
      fixtureId,
    );
  }

  @override
  GuessNotifierProvider getProviderOverride(
    covariant GuessNotifierProvider provider,
  ) {
    return call(
      provider.fixtureId,
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
  String? get name => r'guessNotifierProvider';
}

/// Notifier that handles guess submission with loading/success/error state.
///
/// Copied from [GuessNotifier].
class GuessNotifierProvider
    extends AutoDisposeNotifierProviderImpl<GuessNotifier, AsyncValue<Guess?>> {
  /// Notifier that handles guess submission with loading/success/error state.
  ///
  /// Copied from [GuessNotifier].
  GuessNotifierProvider(
    String fixtureId,
  ) : this._internal(
          () => GuessNotifier()..fixtureId = fixtureId,
          from: guessNotifierProvider,
          name: r'guessNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$guessNotifierHash,
          dependencies: GuessNotifierFamily._dependencies,
          allTransitiveDependencies:
              GuessNotifierFamily._allTransitiveDependencies,
          fixtureId: fixtureId,
        );

  GuessNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.fixtureId,
  }) : super.internal();

  final String fixtureId;

  @override
  AsyncValue<Guess?> runNotifierBuild(
    covariant GuessNotifier notifier,
  ) {
    return notifier.build(
      fixtureId,
    );
  }

  @override
  Override overrideWith(GuessNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: GuessNotifierProvider._internal(
        () => create()..fixtureId = fixtureId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        fixtureId: fixtureId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<GuessNotifier, AsyncValue<Guess?>>
      createElement() {
    return _GuessNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GuessNotifierProvider && other.fixtureId == fixtureId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, fixtureId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GuessNotifierRef on AutoDisposeNotifierProviderRef<AsyncValue<Guess?>> {
  /// The parameter `fixtureId` of this provider.
  String get fixtureId;
}

class _GuessNotifierProviderElement extends AutoDisposeNotifierProviderElement<
    GuessNotifier, AsyncValue<Guess?>> with GuessNotifierRef {
  _GuessNotifierProviderElement(super.provider);

  @override
  String get fixtureId => (origin as GuessNotifierProvider).fixtureId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
