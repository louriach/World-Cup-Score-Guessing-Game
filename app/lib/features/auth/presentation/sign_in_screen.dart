import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TextField, InputDecoration, OutlineInputBorder, Colors;
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
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

    // On web, hide logo/tagline once the code-entry step is shown
    // so the layout doesn't jump when the form grows.
    final showingCodeEntry = kIsWeb &&
        ref.watch(otpNotifierProvider).valueOrNull != null;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundBase,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            children: [
              const Spacer(flex: 2),
              AnimatedOpacity(
                opacity: showingCodeEntry ? 0.0 : 1.0,
                duration: AppDurations.fast,
                child: AnimatedSize(
                  duration: AppDurations.fast,
                  curve: Curves.easeInOut,
                  child: showingCodeEntry
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
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
                          ],
                        ),
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
                _OtpForm()
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

class _OtpForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<_OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends ConsumerState<_OtpForm> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpNotifierProvider);

    // Navigate once verified
    ref.listen(otpNotifierProvider, (prev, next) async {
      if (next is! AsyncData || next.value == null) return;
      if (prev is AsyncLoading) {
        // Only navigate after verifyOtp succeeds (not after sendOtp)
        final client = Supabase.instance.client;
        if (client.auth.currentSession != null) {
          final repo = ref.read(authRepositoryProvider);
          final hasProfile = await repo.hasCompletedOnboarding();
          if (context.mounted) {
            context.go(hasProfile ? '/home' : '/onboarding');
          }
        }
      }
    });

    final emailSent = otpState is AsyncData && otpState.value != null;
    final isLoading = otpState is AsyncLoading;
    final codeReady = _codeCtrl.text.trim().length >= 6;

    if (!emailSent) {
      // ── Step 1: Enter email ──────────────────────────────────────────────
      return Column(
        children: [
          _EmailField(controller: _emailCtrl),
          const SizedBox(height: AppSpacing.base),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.button),
              onPressed: isLoading
                  ? null
                  : () => ref
                      .read(otpNotifierProvider.notifier)
                      .sendOtp(_emailCtrl.text),
              child: isLoading
                  ? const CupertinoActivityIndicator()
                  : DefaultTextStyle.merge(
                      style: AppTextStyles.bodyLargeBold
                          .copyWith(color: AppColors.textInverse),
                      child: const Text('Send code'),
                    ),
            ),
          ),
          if (otpState is AsyncError)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'Could not send code. Check your email and try again.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ),
        ],
      );
    }

    // ── Step 2: Enter 6-digit code ───────────────────────────────────────
    final email = otpState.value!;
    return Column(
      children: [
        const Icon(CupertinoIcons.mail_solid, color: AppColors.primary, size: 36),
        const SizedBox(height: AppSpacing.base),
        Text('Check your email', style: AppTextStyles.bodyLargeBold),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'We sent a sign-in code to $email',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: AppSpacing.xl),
        _CodeField(controller: _codeCtrl..addListener(() => setState(() {}))),
        const SizedBox(height: AppSpacing.base),
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: codeReady ? AppColors.primary : AppColors.buttonDisabled,
            borderRadius: BorderRadius.circular(AppRadius.button),
            onPressed: (isLoading || !codeReady)
                ? null
                : () => ref
                    .read(otpNotifierProvider.notifier)
                    .verifyOtp(email, _codeCtrl.text),
            child: isLoading
                ? const CupertinoActivityIndicator()
                : DefaultTextStyle.merge(
                    style: AppTextStyles.bodyLargeBold
                        .copyWith(color: AppColors.textInverse),
                    child: const Text('Verify code'),
                  ),
          ),
        ),
        if (otpState is AsyncError)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              'Invalid or expired code. Please try again.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ),
        const SizedBox(height: AppSpacing.base),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            _codeCtrl.clear();
            ref.read(otpNotifierProvider.notifier).reset();
          },
          child: Text(
            'Use a different email',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
    );
  }
}

class _CodeField extends StatelessWidget {
  final TextEditingController controller;
  const _CodeField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      // Use text keyboard — more reliably captured on iOS Safari PWA
      // than the number pad, which can silently drop input.
      keyboardType: TextInputType.text,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      enableSuggestions: false,
      maxLength: 8,
      textAlign: TextAlign.center,
      style: AppTextStyles.heading2.copyWith(
        color: AppColors.textPrimary,
        letterSpacing: 8,
      ),
      decoration: InputDecoration(
        hintText: '00000000',
        counterText: '',
        hintStyle: AppTextStyles.heading2.copyWith(
          color: AppColors.textDisabled,
          letterSpacing: 8,
        ),
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
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.goldGlow,
            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Image.asset(
              'assets/images/app_icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Text('Golden Goals', style: AppTextStyles.brandTitle),
      ],
    );
  }
}
