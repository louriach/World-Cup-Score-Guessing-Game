import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/fixture.dart';
import '../../../shared/models/guess.dart';

class ScoresRepository {
  final _client = Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  /// All fixtures ordered by kickoff, with the current user's guess joined.
  Future<List<Fixture>> fetchFixtures() async {
    final data = await _client
        .from('fixtures')
        .select()
        .order('kickoff_time', ascending: true);

    return (data as List).map((j) => Fixture.fromJson(j)).toList();
  }

  /// Fetch all guesses for the current user, keyed by fixture_id.
  Future<Map<String, Guess>> fetchMyGuesses() async {
    final data = await _client
        .from('guesses')
        .select()
        .eq('user_id', _userId);

    return {
      for (final j in data as List)
        (j['fixture_id'] as String): Guess.fromJson(j)
    };
  }

  /// Fetch a single guess for a fixture, or null if not yet guessed.
  Future<Guess?> fetchGuess(String fixtureId) async {
    final data = await _client
        .from('guesses')
        .select()
        .eq('user_id', _userId)
        .eq('fixture_id', fixtureId)
        .maybeSingle();

    return data == null ? null : Guess.fromJson(data);
  }

  /// Submit or update a guess. Enforced server-side: fails if past lock time.
  Future<Guess> saveGuess({
    required String fixtureId,
    required int homeScore,
    required int awayScore,
    required bool predictsPenalties,
  }) async {
    final payload = {
      'user_id': _userId,
      'fixture_id': fixtureId,
      'home_score_guess': homeScore,
      'away_score_guess': awayScore,
      'predicts_penalties': predictsPenalties,
    };

    final data = await _client
        .from('guesses')
        .upsert(payload, onConflict: 'user_id,fixture_id')
        .select()
        .single();

    return Guess.fromJson(data);
  }
}
