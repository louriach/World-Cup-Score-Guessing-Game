import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/fixture.dart';
import '../../../shared/models/guess.dart';
import '../data/scores_repository.dart';

part 'scores_providers.g.dart';

@riverpod
ScoresRepository scoresRepository(Ref ref) => ScoresRepository();

@riverpod
Future<List<Fixture>> fixtures(Ref ref) {
  return ref.read(scoresRepositoryProvider).fetchFixtures();
}

@riverpod
Future<Map<String, Guess>> myGuesses(Ref ref) {
  return ref.read(scoresRepositoryProvider).fetchMyGuesses();
}

@riverpod
Future<Guess?> fixtureGuess(Ref ref, String fixtureId) {
  return ref.read(scoresRepositoryProvider).fetchGuess(fixtureId);
}

/// Groups fixtures by matchday for display in the scores list.
@riverpod
Future<Map<int, List<Fixture>>> fixturesByMatchday(Ref ref) async {
  final fixtures = await ref.watch(fixturesProvider.future);
  final map = <int, List<Fixture>>{};
  for (final f in fixtures) {
    map.putIfAbsent(f.matchday, () => []).add(f);
  }
  return map;
}

/// Notifier that handles guess submission with loading/success/error state.
@riverpod
class GuessNotifier extends _$GuessNotifier {
  @override
  AsyncValue<Guess?> build(String fixtureId) {
    // Seed with already-fetched guess if available
    ref.watch(fixtureGuessProvider(fixtureId));
    return const AsyncData(null);
  }

  Future<void> save({
    required int homeScore,
    required int awayScore,
    required bool predictsPenalties,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final guess = await ref.read(scoresRepositoryProvider).saveGuess(
            fixtureId: fixtureId,
            homeScore: homeScore,
            awayScore: awayScore,
            predictsPenalties: predictsPenalties,
          );
      // Invalidate so the list and detail views both refresh
      ref.invalidate(myGuessesProvider);
      ref.invalidate(fixtureGuessProvider(fixtureId));
      return guess;
    });
  }
}
