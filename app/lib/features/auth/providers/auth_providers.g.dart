// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRepositoryHash() => r'50a1d563eb512e3d26c62f7d6917fbcc58928eef';

/// See also [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$authStateHash() => r'a3f25f5dd7d362320c01f6303e630f2fec07613a';

/// Watches the Supabase auth state stream.
/// Widgets that depend on this rebuild whenever the user signs in or out.
///
/// Copied from [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<AuthState>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthStateRef = AutoDisposeStreamProviderRef<AuthState>;
String _$currentUserHash() => r'06a94a346f4db9f4da4f1a3d1c58e63a7c7110d9';

/// Convenience provider — returns the current user or null.
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentUserRef = AutoDisposeProviderRef<User?>;
String _$signInNotifierHash() => r'8ea1f67c6b995993c5d20b203a212d4592db0ce1';

/// Sign-in flow state — tracks loading and error for the sign-in button.
///
/// Copied from [SignInNotifier].
@ProviderFor(SignInNotifier)
final signInNotifierProvider =
    AutoDisposeNotifierProvider<SignInNotifier, AsyncValue<void>>.internal(
  SignInNotifier.new,
  name: r'signInNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$signInNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SignInNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$onboardingNotifierHash() =>
    r'6b341e646c8be837d15a2d53ec099bda209843a6';

/// Onboarding flow state.
///
/// Copied from [OnboardingNotifier].
@ProviderFor(OnboardingNotifier)
final onboardingNotifierProvider =
    AutoDisposeNotifierProvider<OnboardingNotifier, AsyncValue<void>>.internal(
  OnboardingNotifier.new,
  name: r'onboardingNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OnboardingNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
