// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leagues_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$leaguesRepositoryHash() => r'e82ad83dbadb48d6d7833190243e005cd6e273ad';

/// See also [leaguesRepository].
@ProviderFor(leaguesRepository)
final leaguesRepositoryProvider =
    AutoDisposeProvider<LeaguesRepository>.internal(
  leaguesRepository,
  name: r'leaguesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$leaguesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LeaguesRepositoryRef = AutoDisposeProviderRef<LeaguesRepository>;
String _$myLeaguesHash() => r'18dce4b5fcb7530af7400de23e3536a50444ee82';

/// See also [myLeagues].
@ProviderFor(myLeagues)
final myLeaguesProvider = AutoDisposeFutureProvider<List<League>>.internal(
  myLeagues,
  name: r'myLeaguesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myLeaguesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyLeaguesRef = AutoDisposeFutureProviderRef<List<League>>;
String _$leaderboardHash() => r'e3acb0ea9d05d4f8a3d8e4ed86b3eb3a68bbae47';

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

/// See also [leaderboard].
@ProviderFor(leaderboard)
const leaderboardProvider = LeaderboardFamily();

/// See also [leaderboard].
class LeaderboardFamily extends Family<AsyncValue<List<LeagueMember>>> {
  /// See also [leaderboard].
  const LeaderboardFamily();

  /// See also [leaderboard].
  LeaderboardProvider call(
    String leagueId,
  ) {
    return LeaderboardProvider(
      leagueId,
    );
  }

  @override
  LeaderboardProvider getProviderOverride(
    covariant LeaderboardProvider provider,
  ) {
    return call(
      provider.leagueId,
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
  String? get name => r'leaderboardProvider';
}

/// See also [leaderboard].
class LeaderboardProvider
    extends AutoDisposeFutureProvider<List<LeagueMember>> {
  /// See also [leaderboard].
  LeaderboardProvider(
    String leagueId,
  ) : this._internal(
          (ref) => leaderboard(
            ref as LeaderboardRef,
            leagueId,
          ),
          from: leaderboardProvider,
          name: r'leaderboardProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$leaderboardHash,
          dependencies: LeaderboardFamily._dependencies,
          allTransitiveDependencies:
              LeaderboardFamily._allTransitiveDependencies,
          leagueId: leagueId,
        );

  LeaderboardProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.leagueId,
  }) : super.internal();

  final String leagueId;

  @override
  Override overrideWith(
    FutureOr<List<LeagueMember>> Function(LeaderboardRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LeaderboardProvider._internal(
        (ref) => create(ref as LeaderboardRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        leagueId: leagueId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<LeagueMember>> createElement() {
    return _LeaderboardProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LeaderboardProvider && other.leagueId == leagueId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, leagueId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin LeaderboardRef on AutoDisposeFutureProviderRef<List<LeagueMember>> {
  /// The parameter `leagueId` of this provider.
  String get leagueId;
}

class _LeaderboardProviderElement
    extends AutoDisposeFutureProviderElement<List<LeagueMember>>
    with LeaderboardRef {
  _LeaderboardProviderElement(super.provider);

  @override
  String get leagueId => (origin as LeaderboardProvider).leagueId;
}

String _$createLeagueNotifierHash() =>
    r'10281256f3637800e70cd88cae6ab29c81cd3dc1';

/// See also [CreateLeagueNotifier].
@ProviderFor(CreateLeagueNotifier)
final createLeagueNotifierProvider = AutoDisposeNotifierProvider<
    CreateLeagueNotifier, AsyncValue<League?>>.internal(
  CreateLeagueNotifier.new,
  name: r'createLeagueNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createLeagueNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CreateLeagueNotifier = AutoDisposeNotifier<AsyncValue<League?>>;
String _$joinLeagueNotifierHash() =>
    r'8bee85540c6bede9604011eccbc401e93cf8e1e2';

/// See also [JoinLeagueNotifier].
@ProviderFor(JoinLeagueNotifier)
final joinLeagueNotifierProvider = AutoDisposeNotifierProvider<
    JoinLeagueNotifier, AsyncValue<League?>>.internal(
  JoinLeagueNotifier.new,
  name: r'joinLeagueNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$joinLeagueNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$JoinLeagueNotifier = AutoDisposeNotifier<AsyncValue<League?>>;
String _$removeMemberNotifierHash() =>
    r'7b78fc94053a11bd6bb04ad23c0019afab54ec14';

/// See also [RemoveMemberNotifier].
@ProviderFor(RemoveMemberNotifier)
final removeMemberNotifierProvider = AutoDisposeNotifierProvider<
    RemoveMemberNotifier, AsyncValue<void>>.internal(
  RemoveMemberNotifier.new,
  name: r'removeMemberNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$removeMemberNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RemoveMemberNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
