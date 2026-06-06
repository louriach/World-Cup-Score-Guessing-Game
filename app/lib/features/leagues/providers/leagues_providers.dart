import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/league.dart';
import '../data/leagues_repository.dart';

part 'leagues_providers.g.dart';

@riverpod
LeaguesRepository leaguesRepository(Ref ref) => LeaguesRepository();

@riverpod
Future<List<League>> myLeagues(Ref ref) =>
    ref.read(leaguesRepositoryProvider).fetchMyLeagues();

@riverpod
Future<List<LeagueMember>> leaderboard(Ref ref, String leagueId) =>
    ref.read(leaguesRepositoryProvider).fetchLeaderboard(leagueId);

@riverpod
class CreateLeagueNotifier extends _$CreateLeagueNotifier {
  @override
  AsyncValue<League?> build() => const AsyncData(null);

  Future<void> create({
    required String name,
    required String phrase,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final league = await ref
          .read(leaguesRepositoryProvider)
          .createLeague(name: name, joinPhrase: phrase);
      ref.invalidate(myLeaguesProvider);
      return league;
    });
  }
}

@riverpod
class JoinLeagueNotifier extends _$JoinLeagueNotifier {
  @override
  AsyncValue<League?> build() => const AsyncData(null);

  Future<void> join({required String code, required String phrase}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final league = await ref
          .read(leaguesRepositoryProvider)
          .joinLeague(code: code, phrase: phrase);
      ref.invalidate(myLeaguesProvider);
      return league;
    });
  }
}

@riverpod
class RemoveMemberNotifier extends _$RemoveMemberNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> remove({
    required String leagueId,
    required String userId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(leaguesRepositoryProvider)
          .removeMember(leagueId: leagueId, userId: userId);
      ref.invalidate(leaderboardProvider(leagueId));
    });
  }
}
