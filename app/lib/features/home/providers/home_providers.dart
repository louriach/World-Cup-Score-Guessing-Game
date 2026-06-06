import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/fixture.dart';
import '../../../shared/models/league.dart';
import '../../leagues/providers/leagues_providers.dart';
import '../../scores/providers/scores_providers.dart';

part 'home_providers.g.dart';

/// The next matchday that has at least one upcoming (unlocked, unplayed) fixture.
@riverpod
Future<({int matchday, List<Fixture> fixtures})?> nextMatchday(Ref ref) async {
  final byMatchday = await ref.watch(fixturesByMatchdayProvider.future);

  for (final entry in byMatchday.entries) {
    final upcoming = entry.value.where((f) => f.isUpcoming).toList();
    if (upcoming.isNotEmpty) {
      return (matchday: entry.key, fixtures: upcoming);
    }
  }
  return null; // Tournament complete
}

/// Top-4 snapshot for each league the current user belongs to.
@riverpod
Future<List<LeagueSnapshot>> leagueSnapshots(Ref ref) async {
  final leagues = await ref.watch(myLeaguesProvider.future);
  final snapshots = <LeagueSnapshot>[];

  for (final league in leagues) {
    final members = await ref.read(leaderboardProvider(league.id).future);
    snapshots.add(LeagueSnapshot(
      league: league,
      topMembers: members.take(4).toList(),
      totalMembers: members.length,
    ));
  }

  return snapshots;
}

class LeagueSnapshot {
  final League league;
  final List<LeagueMember> topMembers;
  final int totalMembers;

  const LeagueSnapshot({
    required this.league,
    required this.topMembers,
    required this.totalMembers,
  });
}
