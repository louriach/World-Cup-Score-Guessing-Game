import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../data/auth_repository.dart';
import '../providers/auth_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _usernameController = TextEditingController();
  File? _avatarFile;
  bool _usernameTaken = false;
  bool _checkingUsername = false;
  Timer? _debounce;

  @override
  void dispose() {
    _usernameController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 3) {
      setState(() {
        _usernameTaken = false;
        _checkingUsername = false;
      });
      return;
    }

    setState(() => _checkingUsername = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final taken = await ref
          .read(authRepositoryProvider)
          .isUsernameTaken(value.trim());
      if (mounted) {
        setState(() {
          _usernameTaken = taken;
          _checkingUsername = false;
        });
      }
    });
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _avatarFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    if (username.length < 3 || _usernameTaken) return;

    Uint8List? avatarBytes;
    if (_avatarFile != null) {
      avatarBytes = await _avatarFile!.readAsBytes();
    }

    await ref.read(onboardingNotifierProvider.notifier).completeOnboarding(
          username: username,
          avatarBytes: avatarBytes,
        );
  }

  bool get _canSubmit {
    final username = _usernameController.text.trim();
    return username.length >= 3 &&
        !_usernameTaken &&
        !_checkingUsername;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingNotifierProvider);

    ref.listen(onboardingNotifierProvider, (_, next) {
      if (next is AsyncData && context.mounted) {
        context.go('/home');
      }
    });

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundBase,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text('Set up your\nprofile', style: AppTextStyles.heading1),
              const SizedBox(height: AppSpacing.xxxl),

              // Avatar picker
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: _AvatarPicker(file: _avatarFile),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Username field
              Text('Choose a username', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              _UsernameField(
                controller: _usernameController,
                onChanged: _onUsernameChanged,
                isTaken: _usernameTaken,
                isChecking: _checkingUsername,
              ),
              const SizedBox(height: AppSpacing.sm),
              _UsernameHint(
                username: _usernameController.text,
                isTaken: _usernameTaken,
                isChecking: _checkingUsername,
              ),

              const SizedBox(height: AppSpacing.huge),

              if (state is AsyncError)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.base),
                  child: Text(
                    'Something went wrong. Please try again.',
                    style: AppTextStyles.bodySecondary
                        .copyWith(color: AppColors.error),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: _canSubmit
                      ? AppColors.buttonPrimary
                      : AppColors.buttonDisabled,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  onPressed: (state is AsyncLoading || !_canSubmit)
                      ? null
                      : _submit,
                  child: state is AsyncLoading
                      ? const CupertinoActivityIndicator(
                          color: AppColors.textInverse)
                      : Text(
                          'Let\'s go',
                          style: AppTextStyles.bodyLargeBold
                              .copyWith(color: AppColors.buttonPrimaryLabel),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  final File? file;
  const _AvatarPicker({this.file});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.backgroundElevated,
            image: file != null
                ? DecorationImage(
                    image: FileImage(file!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: file == null
              ? const Icon(
                  CupertinoIcons.person_fill,
                  size: 48,
                  color: AppColors.textDisabled,
                )
              : null,
        ),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.backgroundBase, width: 2),
          ),
          child: const Icon(
            CupertinoIcons.camera_fill,
            size: 14,
            color: AppColors.textInverse,
          ),
        ),
      ],
    );
  }
}

class _UsernameField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isTaken;
  final bool isChecking;

  const _UsernameField({
    required this.controller,
    required this.onChanged,
    required this.isTaken,
    required this.isChecking,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isTaken
        ? AppColors.borderError
        : controller.text.length >= 3 && !isChecking
            ? AppColors.borderSuccess
            : AppColors.borderDefault;

    return AnimatedContainer(
      duration: AppDurations.fast,
      decoration: BoxDecoration(
        color: AppColors.backgroundInput,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: CupertinoTextField(
        controller: controller,
        onChanged: onChanged,
        placeholder: 'e.g. golden_eagle_07',
        placeholderStyle:
            AppTextStyles.body.copyWith(color: AppColors.textDisabled),
        style: AppTextStyles.body,
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: null, // border handled by container
        autocorrect: false,
        textInputAction: TextInputAction.done,
        maxLength: 20,
      ),
    );
  }
}

class _UsernameHint extends StatelessWidget {
  final String username;
  final bool isTaken;
  final bool isChecking;

  const _UsernameHint({
    required this.username,
    required this.isTaken,
    required this.isChecking,
  });

  @override
  Widget build(BuildContext context) {
    if (username.isEmpty) {
      return Text(
        'Min 3 characters. Letters, numbers and underscores only.',
        style: AppTextStyles.caption,
      );
    }
    if (isChecking) {
      return Text('Checking...', style: AppTextStyles.caption);
    }
    if (isTaken) {
      return Text(
        'That username is taken — try another.',
        style: AppTextStyles.caption.copyWith(color: AppColors.error),
      );
    }
    if (username.length >= 3) {
      return Text(
        '✓ Looks good!',
        style: AppTextStyles.caption.copyWith(color: AppColors.success),
      );
    }
    return const SizedBox.shrink();
  }
}
