// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nextMatchdayHash() => r'f71a3d3bd33c585641daed507b9782e0830b8988';

/// The next matchday that has at least one upcoming (unlocked, unplayed) fixture.
///
/// Copied from [nextMatchday].
@ProviderFor(nextMatchday)
final nextMatchdayProvider = AutoDisposeFutureProvider<
    ({int matchday, List<Fixture> fixtures})?>.internal(
  nextMatchday,
  name: r'nextMatchdayProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$nextMatchdayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NextMatchdayRef
    = AutoDisposeFutureProviderRef<({int matchday, List<Fixture> fixtures})?>;
String _$leagueSnapshotsHash() => r'12e1b985da0e805df677d5721ca3a0e42f6ceb93';

/// Top-4 snapshot for each league the current user belongs to.
///
/// Copied from [leagueSnapshots].
@ProviderFor(leagueSnapshots)
final leagueSnapshotsProvider =
    AutoDisposeFutureProvider<List<LeagueSnapshot>>.internal(
  leagueSnapshots,
  name: r'leagueSnapshotsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$leagueSnapshotsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LeagueSnapshotsRef = AutoDisposeFutureProviderRef<List<LeagueSnapshot>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
