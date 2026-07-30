import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';

part 'auth_providers.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) => AuthRepository();

/// Watches the Supabase auth state stream.
/// Widgets that depend on this rebuild whenever the user signs in or out.
@riverpod
Stream<AuthState> authState(Ref ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
}

/// Convenience provider — returns the current user or null.
@riverpod
User? currentUser(Ref ref) {
  return Supabase.instance.client.auth.currentUser;
}

/// OTP sign-in state.
/// State is the email address once the code has been sent, null before.
@riverpod
class OtpNotifier extends _$OtpNotifier {
  @override
  AsyncValue<String?> build() => const AsyncData(null);

  /// Step 1 — send the 6-digit code to [email].
  Future<void> sendOtp(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).sendOtp(email);
      return email; // non-null = code sent, show code entry screen
    });
  }

  /// Step 2 — verify the code the user typed.
  Future<void> verifyOtp(String email, String token) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).verifyOtp(email, token);
      return email;
    });
  }

  void reset() => state = const AsyncData(null);
}

/// Onboarding flow state.
@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> completeOnboarding({
    required String username,
    Uint8List? avatarBytes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final userId = Supabase.instance.client.auth.currentUser!.id;

      String? avatarUrl;
      if (avatarBytes != null) {
        avatarUrl = await repo.uploadAvatar(userId, avatarBytes);
      }

      await repo.createProfile(
        userId: userId,
        username: username,
        avatarUrl: avatarUrl,
      );
    });
  }
}
