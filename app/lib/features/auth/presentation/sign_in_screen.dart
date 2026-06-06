import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/notifications/push_notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signInState = ref.watch(signInNotifierProvider);

    ref.listen(signInNotifierProvider, (_, next) async {
      if (next is! AsyncData) return;
      if (next is AsyncData) {
        final repo = ref.read(authRepositoryProvider);
        final hasProfile = await repo.hasCompletedOnboarding();
        // Request notification permission now that the user is signed in
        await PushNotificationService.initialize();
        if (context.mounted) {
          context.go(hasProfile ? '/home' : '/onboarding');
        }
      }
    });

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundBase,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _Logo(),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Predict every score.\nBeat your mates.',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const Spacer(flex: 3),
              if (signInState is AsyncError)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.base),
                  child: Text(
                    '${(signInState as AsyncError).error}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySecondary
                        .copyWith(color: AppColors.error),
                  ),
                ),
              SignInWithAppleButton(
                onPressed: signInState is AsyncLoading
                    ? () {}
                    : () => ref
                        .read(signInNotifierProvider.notifier)
                        .signInWithApple(),
                style: SignInWithAppleButtonStyle.black,
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                'By signing in you agree to our Terms of Service\nand Privacy Policy.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.goldGlow,
          ),
          child: Image.asset(
            'assets/images/app_icon.png',
            width: 56,
            height: 56,
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Text('Golden Goals', style: AppTextStyles.brandTitle),
      ],
    );
  }
}
