import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/fixture.dart';
import '../../../shared/models/guess.dart';
import '../../../shared/widgets/toast.dart';
import '../providers/scores_providers.dart';

class FixtureDetailScreen extends ConsumerStatefulWidget {
  final String fixtureId;
  const FixtureDetailScreen({super.key, required this.fixtureId});

  @override
  ConsumerState<FixtureDetailScreen> createState() =>
      _FixtureDetailScreenState();
}

class _FixtureDetailScreenState extends ConsumerState<FixtureDetailScreen> {
  late final TextEditingController _homeCtrl;
  late final TextEditingController _awayCtrl;
  bool _predictsPenalties = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _homeCtrl = TextEditingController();
    _awayCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _homeCtrl.dispose();
    _awayCtrl.dispose();
    super.dispose();
  }

  void _seedFromGuess(Guess guess) {
    if (_homeCtrl.text.isEmpty && _awayCtrl.text.isEmpty) {
      _homeCtrl.text = guess.homeScoreGuess.toString();
      _awayCtrl.text = guess.awayScoreGuess.toString();
      _predictsPenalties = guess.predictsPenalties;
    }
  }

  Future<void> _submit(Fixture fixture) async {
    final home = int.tryParse(_homeCtrl.text);
    final away = int.tryParse(_awayCtrl.text);
    if (home == null || away == null) return;

    await ref.read(guessNotifierProvider(widget.fixtureId).notifier).save(
          homeScore: home,
          awayScore: away,
          predictsPenalties: _predictsPenalties,
        );

    if (mounted) {
      setState(() => _showSuccess = true);
      HapticFeedback.mediumImpact();

      Toast.show(
        context,
        'Prediction saved!',
        subtitle: 'See how your league mates guessed',
        style: ToastStyle.success,
        onTap: () => context.push('/scores/${widget.fixtureId}'),
      );

      await Future.delayed(AppDurations.slow);
      if (mounted) setState(() => _showSuccess = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fixtureAsync = ref.watch(fixturesProvider).whenData(
          (list) => list.firstWhere((f) => f.id == widget.fixtureId),
        );
    final guessAsync = ref.watch(fixtureGuessProvider(widget.fixtureId));
    final guessState = ref.watch(guessNotifierProvider(widget.fixtureId));

    guessAsync.whenData((g) {
      if (g != null) _seedFromGuess(g);
    });

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundBase,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          fixtureAsync.valueOrNull != null
              ? '${fixtureAsync.value!.homeTeam} vs ${fixtureAsync.value!.awayTeam}'
              : 'Match',
        ),
        backgroundColor: AppColors.backgroundSurface,
        border: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5),
        ),
      ),
      child: fixtureAsync.when(
        loading: () =>
            const Center(child: CupertinoActivityIndicator()),
        error: (_, __) => Center(
          child: Text('Failed to load match',
              style: AppTextStyles.bodySecondary),
        ),
        data: (fixture) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xl),
                _MatchHeader(fixture: fixture),
                const SizedBox(height: AppSpacing.xxxl),
                if (fixture.isCompleted)
                  _ResultView(fixture: fixture, guess: guessAsync.valueOrNull)
                else if (fixture.isLocked)
                  _LockedView(guess: guessAsync.valueOrNull)
                else
                  _GuessEntry(
                    fixture: fixture,
                    homeCtrl: _homeCtrl,
                    awayCtrl: _awayCtrl,
                    predictsPenalties: _predictsPenalties,
                    showSuccess: _showSuccess,
                    isLoading: guessState is AsyncLoading,
                    existingGuess: guessAsync.valueOrNull,
                    onPenaltiesChanged: (v) =>
                        setState(() => _predictsPenalties = v),
                    onSubmit: () => _submit(fixture),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Match header — teams and kickoff time
// ---------------------------------------------------------------------------

class _MatchHeader extends StatelessWidget {
  final Fixture fixture;
  const _MatchHeader({required this.fixture});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          DateFormat('EEEE d MMMM · HH:mm').format(fixture.kickoffTime.toLocal()),
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Text(
                fixture.homeTeam,
                style: AppTextStyles.heading3,
                textAlign: TextAlign.center,
              ),
            ),
            Text('vs', style: AppTextStyles.bodySecondary),
            Expanded(
              child: Text(
                fixture.awayTeam,
                style: AppTextStyles.heading3,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _stageLabel(fixture.stage),
          style: AppTextStyles.caption.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }

  String _stageLabel(FixtureStage stage) => switch (stage) {
        FixtureStage.group => 'Group Stage',
        FixtureStage.roundOf16 => 'Round of 16',
        FixtureStage.quarterFinal => 'Quarter Final',
        FixtureStage.semiFinal => 'Semi Final',
        FixtureStage.final_ => 'Final',
      };
}

// ---------------------------------------------------------------------------
// Guess entry form
// ---------------------------------------------------------------------------

class _GuessEntry extends StatelessWidget {
  final Fixture fixture;
  final TextEditingController homeCtrl;
  final TextEditingController awayCtrl;
  final bool predictsPenalties;
  final bool showSuccess;
  final bool isLoading;
  final Guess? existingGuess;
  final ValueChanged<bool> onPenaltiesChanged;
  final VoidCallback onSubmit;

  const _GuessEntry({
    required this.fixture,
    required this.homeCtrl,
    required this.awayCtrl,
    required this.predictsPenalties,
    required this.showSuccess,
    required this.isLoading,
    required this.existingGuess,
    required this.onPenaltiesChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          existingGuess != null ? 'Update your prediction' : 'Your prediction',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: AppSpacing.xl),
        // Score inputs
        Row(
          children: [
            Expanded(
              child: _ScoreInput(
                controller: homeCtrl,
                label: fixture.homeTeam,
                showSuccess: showSuccess,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Text('–', style: AppTextStyles.scoreLarge),
            ),
            Expanded(
              child: _ScoreInput(
                controller: awayCtrl,
                label: fixture.awayTeam,
                showSuccess: showSuccess,
              ),
            ),
          ],
        ),

        // Penalties toggle — knockout rounds only
        if (fixture.stage.isKnockout) ...[
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: AppRadius.cardBR,
              border: Border.all(
                color: predictsPenalties
                    ? AppColors.primary
                    : AppColors.borderSubtle,
                width: predictsPenalties ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Goes to penalties',
                          style: AppTextStyles.bodyLargeBold),
                      Text('+1 bonus point if correct',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: predictsPenalties,
                  activeColor: AppColors.primary,
                  onChanged: onPenaltiesChanged,
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.xxxl),
        _SubmitButton(
          showSuccess: showSuccess,
          isLoading: isLoading,
          onPressed: onSubmit,
        ),

        if (existingGuess != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              'Last updated ${DateFormat('d MMM · HH:mm').format(existingGuess!.updatedAt.toLocal())}',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ],
    );
  }
}

class _ScoreInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool showSuccess;

  const _ScoreInput({
    required this.controller,
    required this.label,
    required this.showSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: AppDurations.fast,
          decoration: BoxDecoration(
            color: AppColors.backgroundInput,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(
              color: showSuccess
                  ? AppColors.scoreFieldSuccess
                  : AppColors.scoreFieldIdle,
              width: showSuccess ? 2 : 1.5,
            ),
          ),
          child: CupertinoTextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: AppTextStyles.scoreDisplay,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _SingleDigitFormatter(),
            ],
            placeholder: '0',
            placeholderStyle: AppTextStyles.scoreDisplay
                .copyWith(color: AppColors.textDisabled),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
            decoration: null,
            maxLength: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool showSuccess;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.showSuccess,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        color: showSuccess ? AppColors.success : AppColors.buttonPrimary,
        borderRadius: BorderRadius.circular(AppRadius.button),
        onPressed: isLoading ? null : onPressed,
        child: AnimatedSwitcher(
          duration: AppDurations.fast,
          child: isLoading
              ? const CupertinoActivityIndicator(color: AppColors.textInverse)
              : showSuccess
                  ? const Icon(CupertinoIcons.checkmark,
                      key: ValueKey('check'), color: AppColors.textInverse)
                  : Text(
                      'Submit prediction',
                      key: const ValueKey('label'),
                      style: AppTextStyles.bodyLargeBold
                          .copyWith(color: AppColors.buttonPrimaryLabel),
                    ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Locked state — shows submitted guess but no editing
// ---------------------------------------------------------------------------

class _LockedView extends StatelessWidget {
  final Guess? guess;
  const _LockedView({this.guess});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(CupertinoIcons.lock_fill,
            color: AppColors.textSecondary, size: 32),
        const SizedBox(height: AppSpacing.base),
        Text('Predictions are locked', style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.sm),
        Text('Good luck!', style: AppTextStyles.bodySecondary),
        if (guess != null) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Your prediction: ${guess!.homeScoreGuess} – ${guess!.awayScoreGuess}',
            style: AppTextStyles.bodyLargeBold,
          ),
          if (guess!.predictsPenalties)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text('+ penalties bonus',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.primary)),
            ),
        ] else ...[
          const SizedBox(height: AppSpacing.xl),
          Text('You didn\'t submit a prediction for this match.',
              style: AppTextStyles.bodySecondary),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Result view — shows actual score vs user's guess and points earned
// ---------------------------------------------------------------------------

class _ResultView extends StatelessWidget {
  final Fixture fixture;
  final Guess? guess;
  const _ResultView({required this.fixture, this.guess});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Final Score', style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.base),
        Text(
          '${fixture.homeScore} – ${fixture.awayScore}',
          style: AppTextStyles.scoreDisplay.copyWith(color: AppColors.primary),
        ),
        if (fixture.wentToPenalties == true) ...[
          const SizedBox(height: AppSpacing.sm),
          Text('Decided on penalties',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
        ],
        const SizedBox(height: AppSpacing.xxxl),
        if (guess != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: AppRadius.cardBR,
            ),
            child: Column(
              children: [
                Text('Your prediction', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${guess!.homeScoreGuess} – ${guess!.awayScoreGuess}',
                  style: AppTextStyles.scoreLarge,
                ),
                const SizedBox(height: AppSpacing.base),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.badge),
                  ),
                  child: Text(
                    '${guess!.pointsEarned ?? '–'} pts',
                    style: AppTextStyles.bodyLargeBold
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ] else
          Text('No prediction submitted',
              style: AppTextStyles.bodySecondary),
      ],
    );
  }
}

// Limits score input to 0–19 (handles extra time scores gracefully)
class _SingleDigitFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    if (next.text.isEmpty) return next;
    final value = int.tryParse(next.text);
    if (value == null || value > 19) return old;
    return next;
  }
}
