import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    show
        Colors,
        MaterialApp,
        NoSplash,
        ThemeData;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/notifications/push_notification_service.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/pwa_install_banner.dart';
import 'shared/widgets/web_frame.dart';

class GoldenGoalsApp extends ConsumerWidget {
  const GoldenGoalsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    PushNotificationService.setRouter(router);

    if (kIsWeb) {
      return MaterialApp.router(
        title: 'Golden Goals',
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.backgroundBase,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        // builder wraps every route inside the frame + PWA banner
        builder: (context, child) => DefaultTextStyle(
          style: const TextStyle(
            decoration: TextDecoration.none,
            color: AppColors.textPrimary,
          ),
          child: WebFrame(
            child: PwaInstallBanner(
              child: child!,
            ),
          ),
        ),
      );
    }

    return CupertinoApp.router(
      title: 'Golden Goals',
      theme: AppTheme.cupertinoTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
