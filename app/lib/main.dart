import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/notifications/push_notification_service.dart';

// The anon/publishable key is safe to ship in the app binary — it is public-facing
// and all data access is restricted by Row Level Security on the server.
const _supabaseUrl = 'https://abmzwhjuisawlywmzapd.supabase.co';
const _supabaseAnonKey = 'sb_publishable_nmuGWO3sHRVMK9Z1rXSV-w_0DuD03JZ';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  // Firebase is only needed on native platforms for push notifications.
  // Web uses magic link auth and has no push notifications.
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }

  runApp(const ProviderScope(child: GoldenGoalsApp()));
}
