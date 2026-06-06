import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/league.dart';

class LeaguesRepository {
  final _client = Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  /// All leagues the current user belongs to.
  Future<List<League>> fetchMyLeagues() async {
    final data = await _client
        .from('leagues')
        .select()
        .order('created_at', ascending: false);

    return (data as List).map((j) => League.fromJson(j)).toList();
  }

  /// Leaderboard for a league — members ordered by points descending.
  Future<List<LeagueMember>> fetchLeaderboard(String leagueId) async {
    final data = await _client
        .from('league_members')
        .select('*, users(username, avatar_url)')
        .eq('league_id', leagueId)
        .order('total_points', ascending: false);

    return (data as List).map((j) => LeagueMember.fromJson(j)).toList();
  }

  /// Create a new league. Admin is always the current user.
  Future<League> createLeague({
    required String name,
    required String joinPhrase,
  }) async {
    final code = _generateCode();

    final data = await _client
        .from('leagues')
        .insert({
          'name': name.trim(),
          'join_code': code,
          'join_phrase': _normalisePhrase(joinPhrase),
          'admin_user_id': _userId,
        })
        .select()
        .single();

    final league = League.fromJson(data);

    // Auto-join the creator
    await _client.from('league_members').insert({
      'league_id': league.id,
      'user_id': _userId,
    });

    return league;
  }

  /// Join a league by code + phrase.
  /// Throws if the code/phrase combination is not found.
  Future<League> joinLeague({
    required String code,
    required String phrase,
  }) async {
    final data = await _client
        .from('leagues')
        .select()
        .eq('join_code', code.trim())
        .eq('join_phrase', _normalisePhrase(phrase))
        .maybeSingle();

    if (data == null) {
      throw const LeagueJoinException('Incorrect code or phrase.');
    }

    final league = League.fromJson(data);

    // Check not already a member
    final existing = await _client
        .from('league_members')
        .select('id')
        .eq('league_id', league.id)
        .eq('user_id', _userId)
        .maybeSingle();

    if (existing != null) {
      throw const LeagueJoinException('You are already in this league.');
    }

    await _client.from('league_members').insert({
      'league_id': league.id,
      'user_id': _userId,
    });

    return league;
  }

  /// Remove a member from a league. Only the league admin can do this.
  Future<void> removeMember({
    required String leagueId,
    required String userId,
  }) async {
    await _client
        .from('league_members')
        .delete()
        .eq('league_id', leagueId)
        .eq('user_id', userId);
  }

  /// Generates a random 8-digit numeric code, zero-padded.
  String _generateCode() {
    final n = Random.secure().nextInt(99999999);
    return n.toString().padLeft(8, '0');
  }

  /// Lowercase and hyphenate a phrase for consistent storage.
  String _normalisePhrase(String phrase) =>
      phrase.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
}

class LeagueJoinException implements Exception {
  final String message;
  const LeagueJoinException(this.message);
}
