import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

// Demo credentials for App Store review only.
const _demoEmail = 'review@goldengoals.app';
const _demoCode = 'Rk7mXq2w';

class AuthRepository {
  final _client = Supabase.instance.client;

  /// Returns true if the current user has completed onboarding
  /// (i.e. a row exists in public.users with a username).
  Future<bool> hasCompletedOnboarding() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    final result = await _client
        .from('users')
        .select('id')
        .eq('id', userId)
        .maybeSingle();

    return result != null;
  }

  /// Check if a username is already taken.
  Future<bool> isUsernameTaken(String username) async {
    final result = await _client
        .from('users')
        .select('id')
        .eq('username', username.trim().toLowerCase())
        .maybeSingle();

    return result != null;
  }

  /// Upload avatar image bytes to Supabase Storage.
  /// Returns the public URL of the uploaded avatar.
  Future<String> uploadAvatar(String userId, Uint8List imageBytes) async {
    final path = '$userId/avatar.jpg';

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

  /// Create the public user profile after onboarding.
  Future<void> createProfile({
    required String userId,
    required String username,
    String? avatarUrl,
  }) async {
    await _client.from('users').insert({
      'id': userId,
      'username': username.trim().toLowerCase(),
      'avatar_url': avatarUrl,
    });
  }

  /// Send a one-time password (OTP) code to the given email address.
  /// The user enters the 6-digit code in the app — no link-clicking needed,
  /// which avoids the iOS PWA / Safari session-isolation problem.
  Future<void> sendOtp(String email) async {
    await _client.auth.signInWithOtp(
      email: email.trim(),
      // No emailRedirectTo — tells Supabase to send a 6-digit code, not a link.
    );
  }

  /// Verify the OTP code the user received by email.
  /// New users get a signup token; existing users get an email token.
  /// Try both types so either works transparently.
  Future<Session> verifyOtp(String email, String token) async {
    // Demo account bypass for App Store review.
    if (email.trim().toLowerCase() == _demoEmail &&
        token.trim() == _demoCode) {
      final response = await _client.auth.signInWithPassword(
        email: _demoEmail,
        password: _demoCode,
      );
      if (response.session != null) return response.session!;
    }

    for (final type in [OtpType.email, OtpType.signup]) {
      try {
        final response = await _client.auth.verifyOTP(
          email: email.trim(),
          token: token.trim(),
          type: type,
        );
        if (response.session != null) return response.session!;
      } catch (_) {
        // Try next type
      }
    }
    throw const AuthException('Invalid or expired code. Please request a new one.');
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Permanently delete the current user's account and all their data.
  /// Calls a Supabase SQL function that runs with elevated privileges
  /// to remove the auth.users record (and cascades to public data).
  Future<void> deleteAccount() async {
    await _client.rpc('delete_user');
    await _client.auth.signOut();
  }
}
