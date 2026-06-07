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

/// Sign-in flow state — tracks loading and error for the sign-in button.
@riverpod
class SignInNotifier extends _$SignInNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithApple(),
    );
    if (state is AsyncError) {
      final err = (state as AsyncError).error;
      print('SIGN IN ERROR: $err');
    }
  }
}

/// Magic link sign-in state.
@riverpod
class MagicLinkNotifier extends _$MagicLinkNotifier {
  @override
  AsyncValue<bool> build() => const AsyncData(false); // false = not sent yet

  Future<void> sendMagicLink(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).sendMagicLink(email);
      return true; // sent successfully
    });
  }
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
