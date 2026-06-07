import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final _client = Supabase.instance.client;

  /// Sign in with Apple.
  /// Returns the Supabase [Session] on success.
  /// Throws [AuthException] or [SignInWithAppleException] on failure.
  Future<Session> signInWithApple() async {
    // Generate a secure nonce to prevent replay attacks.
    final rawNonce = _generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = appleCredential.identityToken;
    if (idToken == null) {
      throw const AuthException('Apple did not return an identity token.');
    }

    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );

    if (response.session == null) {
      throw const AuthException('Supabase sign-in returned no session.');
    }

    return response.session!;
  }

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

  /// Send a magic link to the given email address.
  Future<void> sendMagicLink(String email) async {
    await _client.auth.signInWithOtp(
      email: email.trim(),
      emailRedirectTo: 'https://louriach.github.io/World-Cup-Score-Guessing-Game/app/',
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Generates a cryptographically secure random nonce string.
  String _generateNonce([int length = 32]) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }
}
