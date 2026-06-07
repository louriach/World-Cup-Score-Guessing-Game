import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeData, ColorScheme, Colors, MaterialApp, NoSplash;
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

    // Give the notification service a reference to the router so
    // notification taps can navigate regardless of app state.
    PushNotificationService.setRouter(router);

    final child = WebFrame(
      child: PwaInstallBanner(
        child: kIsWeb
            ? MaterialApp.router(
                title: 'Golden Goals',
                routerConfig: router,
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  colorScheme: ColorScheme.dark(
                    primary: AppColors.primary,
                    surface: AppColors.backgroundSurface,
                  ),
                  scaffoldBackgroundColor: AppColors.backgroundBase,
                  splashFactory: NoSplash.splashFactory,
                  highlightColor: Colors.transparent,
                ),
              )
            : CupertinoApp.router(
                title: 'Golden Goals',
                theme: AppTheme.cupertinoTheme,
                routerConfig: router,
                debugShowCheckedModeBanner: false,
              ),
      ),
    );

    return child;
  }
}
