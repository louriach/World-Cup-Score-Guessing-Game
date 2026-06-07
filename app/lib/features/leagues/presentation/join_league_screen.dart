import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/league.dart';
import '../data/leagues_repository.dart';
import '../providers/leagues_providers.dart';

class JoinLeagueScreen extends ConsumerStatefulWidget {
  const JoinLeagueScreen({super.key});

  @override
  ConsumerState<JoinLeagueScreen> createState() => _JoinLeagueScreenState();
}

class _JoinLeagueScreenState extends ConsumerState<JoinLeagueScreen> {
  final _codeCtrl = TextEditingController();
  final _phraseCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    _phraseCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _codeCtrl.text.trim().length == 8 &&
      _phraseCtrl.text.trim().isNotEmpty;

  Future<void> _join() async {
    await ref.read(joinLeagueNotifierProvider.notifier).join(
          code: _codeCtrl.text,
          phrase: _phraseCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(joinLeagueNotifierProvider);

    ref.listen(joinLeagueNotifierProvider, (_, next) {
      if (next case AsyncData(value: final League league?)) {
        context.go('/leagues/${league.id}');
      }
    });

    // Extract human-readable error
    String? errorMessage;
    if (state is AsyncError) {
      final err = state.error;
      errorMessage = err is LeagueJoinException
          ? err.message
          : 'Something went wrong. Please try again.';
    }

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundBase,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Join a league'),
        backgroundColor: AppColors.backgroundSurface,
        border: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Ask your league admin for the 8-digit code and secret phrase.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.xxxl),

              Text('League code', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              _JoinField(
                controller: _codeCtrl,
                placeholder: '00000000',
                keyboardType: TextInputType.number,
                maxLength: 8,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Secret phrase', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              _JoinField(
                controller: _phraseCtrl,
                placeholder: 'e.g. golden-tiger-bends-spoon',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.huge),

              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.base),
                  child: Text(
                    errorMessage,
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
                      : _join,
                  child: state is AsyncLoading
                      ? const CupertinoActivityIndicator(
                          color: AppColors.textInverse)
                      : Text(
                          'Join league',
                          style: AppTextStyles.bodyLargeBold.copyWith(
                              color: AppColors.buttonPrimaryLabel),
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

class _JoinField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final TextInputType keyboardType;
  final int? maxLength;
  final ValueChanged<String> onChanged;

  const _JoinField({
    required this.controller,
    required this.placeholder,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundInput,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.borderDefault, width: 1.5),
      ),
      child: CupertinoTextField(
        controller: controller,
        onChanged: onChanged,
        placeholder: placeholder,
        placeholderStyle:
            AppTextStyles.body.copyWith(color: AppColors.textDisabled),
        style: AppTextStyles.body,
        padding: const EdgeInsets.all(AppSpacing.base),
        keyboardType: keyboardType,
        decoration: null,
        maxLength: maxLength,
        autocorrect: false,
      ),
    );
  }
}
