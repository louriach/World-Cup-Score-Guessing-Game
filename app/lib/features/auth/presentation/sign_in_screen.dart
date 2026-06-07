import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TextField, InputDecoration, OutlineInputBorder, Colors;
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
        if (!kIsWeb) await PushNotificationService.initialize();
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
              if (kIsWeb)
                _MagicLinkForm()
              else
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

class _MagicLinkForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<_MagicLinkForm> createState() => _MagicLinkFormState();
}

class _MagicLinkFormState extends ConsumerState<_MagicLinkForm> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final magicState = ref.watch(magicLinkNotifierProvider);
    final sent = magicState is AsyncData && magicState.value == true;

    if (sent) {
      return Column(
        children: [
          const Icon(CupertinoIcons.mail_solid, color: AppColors.primary, size: 40),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Check your email',
            style: AppTextStyles.bodyLargeBold,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'We sent a sign-in link to ${_emailCtrl.text}',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
        ],
      );
    }

    return Column(
      children: [
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Email address',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.backgroundSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.button),
            onPressed: magicState is AsyncLoading
                ? null
                : () => ref
                    .read(magicLinkNotifierProvider.notifier)
                    .sendMagicLink(_emailCtrl.text),
            child: magicState is AsyncLoading
                ? const CupertinoActivityIndicator()
                : const Text(
                    'Send sign-in link',
                    style: TextStyle(
                      color: AppColors.textInverse,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        if (magicState is AsyncError)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              'Could not send link. Check your email and try again.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ),
      ],
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
