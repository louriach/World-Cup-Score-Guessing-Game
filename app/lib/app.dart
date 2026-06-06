import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/notifications/push_notification_service.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';

class GoldenGoalsApp extends ConsumerWidget {
  const GoldenGoalsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Give the notification service a reference to the router so
    // notification taps can navigate regardless of app state.
    PushNotificationService.setRouter(router);

    return CupertinoApp.router(
      title: 'Golden Goals',
      theme: AppTheme.cupertinoTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
