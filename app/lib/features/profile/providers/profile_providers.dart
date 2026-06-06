import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/profile_repository.dart';

part 'profile_providers.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) => ProfileRepository();

@riverpod
Future<UserProfile> userProfile(Ref ref, String userId) =>
    ref.read(profileRepositoryProvider).fetchProfile(userId);

@riverpod
Future<List<PredictionRecord>> userPredictions(Ref ref, String userId) =>
    ref.read(profileRepositoryProvider).fetchPredictions(userId);

@riverpod
Future<Map<String, bool>> notificationPreferences(Ref ref) =>
    ref.read(profileRepositoryProvider).fetchNotificationPreferences();

@riverpod
class EditProfileNotifier extends _$EditProfileNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> save({
    required String userId,
    String? username,
    Uint8List? avatarBytes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      String? avatarUrl;
      if (avatarBytes != null) {
        avatarUrl = await repo.uploadAvatar(avatarBytes);
      }
      await repo.updateProfile(username: username, avatarUrl: avatarUrl);
      ref.invalidate(userProfileProvider(userId));
    });
  }
}

@riverpod
class NotificationPrefsNotifier extends _$NotificationPrefsNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> save({
    required bool reminder24h,
    required bool reminder1h,
    required bool resultNotification,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(profileRepositoryProvider).updateNotificationPreferences(
            reminder24h: reminder24h,
            reminder1h: reminder1h,
            resultNotification: resultNotification,
          ),
    );
  }
}
