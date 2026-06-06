import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/notifications/push_notification_service.dart';

// Supabase anon key and URL are injected at build time via --dart-define.
// They are never hard-coded here. Run the app with:
//   flutter run --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx
//
// The anon key is safe to ship in the app binary — it is public-facing and
// all data access is restricted by Row Level Security on the server.
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(_supabaseUrl.isNotEmpty, 'SUPABASE_URL is not set. Pass via --dart-define.');
  assert(_supabaseAnonKey.isNotEmpty, 'SUPABASE_ANON_KEY is not set. Pass via --dart-define.');

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  await Firebase.initializeApp();
  // Notification permission is requested after sign-in, not at cold start.
  // PushNotificationService.initialize() is called from auth flow instead.

  runApp(const ProviderScope(child: GoldenGoalsApp()));
}
