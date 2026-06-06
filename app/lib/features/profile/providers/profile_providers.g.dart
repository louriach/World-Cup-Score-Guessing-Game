// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileRepositoryHash() => r'dbf1adbf76b68a77f1975222bd72c33c8400ae3b';

/// See also [profileRepository].
@ProviderFor(profileRepository)
final profileRepositoryProvider =
    AutoDisposeProvider<ProfileRepository>.internal(
  profileRepository,
  name: r'profileRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ProfileRepositoryRef = AutoDisposeProviderRef<ProfileRepository>;
String _$userProfileHash() => r'bd1eaedbbf3f90a812ced8dbdedd748e18996d52';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [userProfile].
@ProviderFor(userProfile)
const userProfileProvider = UserProfileFamily();

/// See also [userProfile].
class UserProfileFamily extends Family<AsyncValue<UserProfile>> {
  /// See also [userProfile].
  const UserProfileFamily();

  /// See also [userProfile].
  UserProfileProvider call(
    String userId,
  ) {
    return UserProfileProvider(
      userId,
    );
  }

  @override
  UserProfileProvider getProviderOverride(
    covariant UserProfileProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userProfileProvider';
}

/// See also [userProfile].
class UserProfileProvider extends AutoDisposeFutureProvider<UserProfile> {
  /// See also [userProfile].
  UserProfileProvider(
    String userId,
  ) : this._internal(
          (ref) => userProfile(
            ref as UserProfileRef,
            userId,
          ),
          from: userProfileProvider,
          name: r'userProfileProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userProfileHash,
          dependencies: UserProfileFamily._dependencies,
          allTransitiveDependencies:
              UserProfileFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<UserProfile> Function(UserProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserProfileProvider._internal(
        (ref) => create(ref as UserProfileRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<UserProfile> createElement() {
    return _UserProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UserProfileRef on AutoDisposeFutureProviderRef<UserProfile> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserProfileProviderElement
    extends AutoDisposeFutureProviderElement<UserProfile> with UserProfileRef {
  _UserProfileProviderElement(super.provider);

  @override
  String get userId => (origin as UserProfileProvider).userId;
}

String _$userPredictionsHash() => r'f4e7d1a912f40e0a7c4a6b7f7d0aa3431035b501';

/// See also [userPredictions].
@ProviderFor(userPredictions)
const userPredictionsProvider = UserPredictionsFamily();

/// See also [userPredictions].
class UserPredictionsFamily extends Family<AsyncValue<List<PredictionRecord>>> {
  /// See also [userPredictions].
  const UserPredictionsFamily();

  /// See also [userPredictions].
  UserPredictionsProvider call(
    String userId,
  ) {
    return UserPredictionsProvider(
      userId,
    );
  }

  @override
  UserPredictionsProvider getProviderOverride(
    covariant UserPredictionsProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userPredictionsProvider';
}

/// See also [userPredictions].
class UserPredictionsProvider
    extends AutoDisposeFutureProvider<List<PredictionRecord>> {
  /// See also [userPredictions].
  UserPredictionsProvider(
    String userId,
  ) : this._internal(
          (ref) => userPredictions(
            ref as UserPredictionsRef,
            userId,
          ),
          from: userPredictionsProvider,
          name: r'userPredictionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userPredictionsHash,
          dependencies: UserPredictionsFamily._dependencies,
          allTransitiveDependencies:
              UserPredictionsFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserPredictionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<List<PredictionRecord>> Function(UserPredictionsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserPredictionsProvider._internal(
        (ref) => create(ref as UserPredictionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PredictionRecord>> createElement() {
    return _UserPredictionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserPredictionsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UserPredictionsRef
    on AutoDisposeFutureProviderRef<List<PredictionRecord>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserPredictionsProviderElement
    extends AutoDisposeFutureProviderElement<List<PredictionRecord>>
    with UserPredictionsRef {
  _UserPredictionsProviderElement(super.provider);

  @override
  String get userId => (origin as UserPredictionsProvider).userId;
}

String _$notificationPreferencesHash() =>
    r'f7d5153a7c2761b4c96e2998146bd3df255cd824';

/// See also [notificationPreferences].
@ProviderFor(notificationPreferences)
final notificationPreferencesProvider =
    AutoDisposeFutureProvider<Map<String, bool>>.internal(
  notificationPreferences,
  name: r'notificationPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationPreferencesRef
    = AutoDisposeFutureProviderRef<Map<String, bool>>;
String _$editProfileNotifierHash() =>
    r'a66e32704000c517e354efa96c4d6d98ad71a24a';

/// See also [EditProfileNotifier].
@ProviderFor(EditProfileNotifier)
final editProfileNotifierProvider =
    AutoDisposeNotifierProvider<EditProfileNotifier, AsyncValue<void>>.internal(
  EditProfileNotifier.new,
  name: r'editProfileNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$editProfileNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EditProfileNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$notificationPrefsNotifierHash() =>
    r'ef3a9a9c51349d380acd8cc5b271240244e71d59';

/// See also [NotificationPrefsNotifier].
@ProviderFor(NotificationPrefsNotifier)
final notificationPrefsNotifierProvider = AutoDisposeNotifierProvider<
    NotificationPrefsNotifier, AsyncValue<void>>.internal(
  NotificationPrefsNotifier.new,
  name: r'notificationPrefsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationPrefsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationPrefsNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
