import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/fixture.dart';
import '../../../shared/models/guess.dart';

class UserProfile {
  final String id;
  final String username;
  final String? avatarUrl;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        username: json['username'] as String,
        avatarUrl: json['avatar_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class PredictionRecord {
  final Guess guess;
  final Fixture fixture;

  const PredictionRecord({required this.guess, required this.fixture});
}

class ProfileRepository {
  final _client = Supabase.instance.client;

  String get _currentUserId => _client.auth.currentUser!.id;

  Future<UserProfile> fetchProfile(String userId) async {
    final data = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    return UserProfile.fromJson(data);
  }

  /// All guesses for a user, joined with fixture data, newest first.
  Future<List<PredictionRecord>> fetchPredictions(String userId) async {
    final data = await _client
        .from('guesses')
        .select('*, fixtures(*)')
        .eq('user_id', userId)
        .order('submitted_at', ascending: false);

    return (data as List).map((j) {
      final guess = Guess.fromJson(j);
      final fixture = Fixture.fromJson(j['fixtures'] as Map<String, dynamic>);
      return PredictionRecord(guess: guess, fixture: fixture);
    }).toList();
  }

  /// Update username and/or avatar for the current user.
  Future<void> updateProfile({
    String? username,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username.trim().toLowerCase();
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (updates.isEmpty) return;

    await _client
        .from('users')
        .update(updates)
        .eq('id', _currentUserId);
  }

  Future<String> uploadAvatar(Uint8List imageBytes) async {
    final path = '$_currentUserId/avatar.jpg';
    await _client.storage.from('avatars').uploadBinary(
          path,
          imageBytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );
    return _client.storage.from('avatars').getPublicUrl(path);
  }

  Future<void> updateNotificationPreferences({
    required bool reminder24h,
    required bool reminder1h,
    required bool resultNotification,
  }) async {
    await _client.from('notification_preferences').upsert({
      'user_id': _currentUserId,
      'reminder_24h': reminder24h,
      'reminder_1h': reminder1h,
      'result_notification': resultNotification,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }

  Future<Map<String, bool>> fetchNotificationPreferences() async {
    final data = await _client
        .from('notification_preferences')
        .select()
        .eq('user_id', _currentUserId)
        .maybeSingle();

    return {
      'reminder_24h': (data?['reminder_24h'] as bool?) ?? true,
      'reminder_1h': (data?['reminder_1h'] as bool?) ?? true,
      'result_notification': (data?['result_notification'] as bool?) ?? true,
    };
  }
}
