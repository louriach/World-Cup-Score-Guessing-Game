import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/league.dart';
import '../providers/leagues_providers.dart';

class CreateLeagueScreen extends ConsumerStatefulWidget {
  const CreateLeagueScreen({super.key});

  @override
  ConsumerState<CreateLeagueScreen> createState() => _CreateLeagueScreenState();
}

class _CreateLeagueScreenState extends ConsumerState<CreateLeagueScreen> {
  final _nameCtrl = TextEditingController();
  final _phraseCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phraseCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _nameCtrl.text.trim().isNotEmpty &&
      _phraseCtrl.text.trim().split(RegExp(r'[\s-]+')).length >= 2;

  Future<void> _create() async {
    await ref.read(createLeagueNotifierProvider.notifier).create(
          name: _nameCtrl.text,
          phrase: _phraseCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createLeagueNotifierProvider);

    // On success, show the share sheet then navigate to the league
    ref.listen(createLeagueNotifierProvider, (_, next) {
      if (next case AsyncData(value: final League league?)) {
        _showShareSheet(context, league);
      }
    });

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundBase,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Create a league'),
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
              Text('League name', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              _Field(
                controller: _nameCtrl,
                placeholder: 'e.g. The Office Pundits',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Secret phrase', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Share this with your league. Keep it funny.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              _Field(
                controller: _phraseCtrl,
                placeholder: 'e.g. golden tiger bends spoon',
                onChanged: (val) {
                  // Auto-replace spaces with hyphens as the user types
                  final hyphenated = val.replaceAll(' ', '-');
                  if (hyphenated != val) {
                    _phraseCtrl.value = TextEditingValue(
                      text: hyphenated,
                      selection: TextSelection.collapsed(
                          offset: hyphenated.length),
                    );
                  }
                  setState(() {});
                },
                maxLength: 40,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Min 2 words.',
                style: AppTextStyles.caption,
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
                      : _create,
                  child: state is AsyncLoading
                      ? const CupertinoActivityIndicator(
                          color: AppColors.textInverse)
                      : DefaultTextStyle.merge(
                          style: AppTextStyles.bodyLargeBold.copyWith(
                              color: AppColors.buttonPrimaryLabel),
                          child: const Text('Create league'),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context, League league) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => _LeagueCreatedSheet(
        league: league,
        onDone: () {
          Navigator.pop(context);
          context.go('/leagues/${league.id}');
        },
      ),
    );
  }
}

/// Shown after league creation — displays code + phrase with copy/share actions.
class _LeagueCreatedSheet extends StatelessWidget {
  final League league;
  final VoidCallback onDone;

  const _LeagueCreatedSheet({required this.league, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final shareText =
        'Join my Golden Goals league!\n\nLeague: ${league.name}\nCode: ${league.joinCode}\nPhrase: ${league.joinPhrase}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: AppRadius.sheetBR,
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.borderDefault,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            Text('League created! 🎉', style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.xl),
            _CodeRow(label: 'Code', value: league.joinCode),
            const SizedBox(height: AppSpacing.base),
            _CodeRow(label: 'Phrase', value: league.joinPhrase),
            const SizedBox(height: AppSpacing.xxxl),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: AppColors.buttonPrimary,
                borderRadius: BorderRadius.circular(AppRadius.button),
                onPressed: () => Share.share(shareText),
                child: Text(
                  'Share with mates',
                  style: AppTextStyles.bodyLargeBold
                      .copyWith(color: AppColors.buttonPrimaryLabel),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            CupertinoButton(
              onPressed: onDone,
              child: Text('Done', style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeRow extends StatelessWidget {
  final String label;
  final String value;
  const _CodeRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      ),
      child: Row(
        children: [
          Text('$label: ', style: AppTextStyles.caption),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyLargeBold),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
            },
            child: const Icon(CupertinoIcons.doc_on_clipboard,
                size: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String> onChanged;
  final int? maxLength;

  const _Field({
    required this.controller,
    required this.placeholder,
    required this.onChanged,
    this.maxLength,
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
        decoration: null,
        maxLength: maxLength,
        autocorrect: false,
      ),
    );
  }
}
