import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Handles APNs token registration and notification routing.
// The actual push sending happens server-side in Supabase Edge Functions —
// no FCM server key or APNs auth credentials are held on the device.
abstract class PushNotificationService {
  static GoRouter? _router;

  /// Call once after the router is created so notification taps can navigate.
  static void setRouter(GoRouter router) => _router = router;

  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _registerToken(messaging);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen(_saveToken);

    // App opened from a notification tap while in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // App was terminated — check if launched via notification
    final initial = await messaging.getInitialMessage();
    if (initial != null) _handleNotificationTap(initial);

    // Foreground notifications — show a banner via FCM's own overlay on Android;
    // on iOS we rely on system banners since the app is in foreground
    FirebaseMessaging.onMessage.listen((message) {
      // Could surface an in-app toast here in a future iteration
    });
  }

  static Future<void> _registerToken(FirebaseMessaging messaging) async {
    final token = await messaging.getToken();
    if (token != null) await _saveToken(token);
  }

  static Future<void> _saveToken(String token) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await Supabase.instance.client.from('push_tokens').upsert(
      {
        'user_id': userId,
        'token': token,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

  static void _handleNotificationTap(RemoteMessage message) {
    final route = _routeFromData(message.data);
    if (route != null) _router?.go(route);
  }

  /// Maps notification data payload to an app route.
  ///   reminder_24h / reminder_1h  → /scores/:fixtureId  (predict screen)
  ///   result                      → /scores/:fixtureId  (result view)
  static String? _routeFromData(Map<String, dynamic> data) {
    final fixtureId = data['fixture_id'] as String?;
    if (fixtureId == null) return null;
    return '/scores/$fixtureId';
  }
}
