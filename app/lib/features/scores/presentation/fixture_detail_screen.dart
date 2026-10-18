import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/fixture.dart';
import '../../../shared/models/guess.dart';
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
  late final FocusNode _homeFocus;
  late final FocusNode _awayFocus;
  bool _predictsPenalties = false;
  bool _seeded = false;
  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _homeCtrl = TextEditingController();
    _awayCtrl = TextEditingController();
    _homeFocus = FocusNode()..addListener(_onFocusChange);
    _awayFocus = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _homeCtrl.dispose();
    _awayCtrl.dispose();
    _homeFocus.dispose();
    _awayFocus.dispose();
    super.dispose();
  }

  void _seedFromGuess(Guess guess) {
    if (_seeded) return;
    _seeded = true;
    _homeCtrl.text = guess.homeScoreGuess.toString();
    _awayCtrl.text = guess.awayScoreGuess.toString();
    _predictsPenalties = guess.predictsPenalties;
  }

  void _onFocusChange() {
    // Autosave when both fields lose focus and both have values
    if (!_homeFocus.hasFocus && !_awayFocus.hasFocus) {
      _trySave();
    }
  }

  Future<void> _trySave() async {
    final home = int.tryParse(_homeCtrl.text);
    final away = int.tryParse(_awayCtrl.text);
    if (home == null || away == null) return;
    if (_saving) return;
    // Deduplicate: don't save if values haven't changed from existing guess
    final existing = ref.read(fixtureGuessProvider(widget.fixtureId)).valueOrNull;
    if (existing != null &&
        existing.homeScoreGuess == home &&
        existing.awayScoreGuess == away &&
        existing.predictsPenalties == _predictsPenalties) return;

    setState(() => _saving = true);

    await ref.read(guessNotifierProvider(widget.fixtureId).notifier).save(
          homeScore: home,
          awayScore: away,
          predictsPenalties: _predictsPenalties,
        );

    if (mounted) {
      setState(() {
        _saving = false;
        _saved = true;
      });
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _saved = false);
    }
  }

  Future<void> _togglePenalties(bool value) async {
    setState(() => _predictsPenalties = value);
    // Save immediately when penalties toggle changes
    final home = int.tryParse(_homeCtrl.text);
    final away = int.tryParse(_awayCtrl.text);
    if (home == null || away == null) return;

    await ref.read(guessNotifierProvider(widget.fixtureId).notifier).save(
          homeScore: home,
          awayScore: away,
          predictsPenalties: value,
        );

    if (mounted) {
      HapticFeedback.selectionClick();
      setState(() => _saved = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _saved = false);
    }
  }

  Future<void> _goToFixture(BuildContext context, String fixtureId) async {
    // Dismiss keyboard and save before navigating
    FocusScope.of(context).unfocus();
    await _trySave();
    if (mounted) context.pushReplacement('/scores/$fixtureId');
  }

  @override
  Widget build(BuildContext context) {
    final allFixturesAsync = ref.watch(fixturesProvider);
    final fixtureAsync = allFixturesAsync.whenData(
          (list) => list.firstWhere((f) => f.id == widget.fixtureId),
        );
    final guessAsync = ref.watch(fixtureGuessProvider(widget.fixtureId));

    // Find next upcoming fixture after this one
    final nextFixture = allFixturesAsync.valueOrNull
        ?.where((f) => f.isUpcoming && f.id != widget.fixtureId)
        .toList()
        .firstOrNull;

    guessAsync.whenData((g) {
      if (g != null) _seedFromGuess(g);
    });

    final isGuessing = fixtureAsync.valueOrNull != null &&
        !fixtureAsync.value!.isCompleted &&
        !fixtureAsync.value!.isLocked;

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
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.pop(),
          child: const Icon(CupertinoIcons.back, color: AppColors.primary),
        ),
        trailing: AnimatedSwitcher(
          duration: AppDurations.fast,
          child: _saving
              ? const CupertinoActivityIndicator(key: ValueKey('loading'))
              : _saved
                  ? Icon(CupertinoIcons.checkmark_circle_fill,
                      key: const ValueKey('saved'),
                      color: AppColors.success,
                      size: 20)
                  : const SizedBox.shrink(key: ValueKey('idle')),
        ),
      ),
      child: fixtureAsync.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (_, __) => Center(
          child: Text('Failed to load match',
              style: AppTextStyles.bodySecondary),
        ),
        data: (fixture) => SafeArea(
          child: Column(
            children: [
              Expanded(
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
                          homeFocus: _homeFocus,
                          awayFocus: _awayFocus,
                          predictsPenalties: _predictsPenalties,
                          existingGuess: guessAsync.valueOrNull,
                          onPenaltiesChanged: _togglePenalties,
                        ),
                    ],
                  ),
                ),
              ),
              // Bottom navigation buttons — only shown on guessing screen
              if (isGuessing)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.sm,
                    AppSpacing.pagePadding,
                    AppSpacing.pagePadding,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          color: AppColors.backgroundSurface,
                          borderRadius: BorderRadius.circular(AppRadius.button),
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          onPressed: () => context.pop(),
                          child: DefaultTextStyle.merge(
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            child: const Text('Back'),
                          ),
                        ),
                      ),
                      if (nextFixture != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: CupertinoButton(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.button),
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            onPressed: () => _goToFixture(context, nextFixture.id),
                            child: DefaultTextStyle.merge(
                              style: AppTextStyles.bodyLargeBold.copyWith(
                                color: AppColors.textInverse,
                              ),
                              child: const Text('Next fixture →'),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
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
// Guess entry — autosaves on defocus
// ---------------------------------------------------------------------------

class _GuessEntry extends StatelessWidget {
  final Fixture fixture;
  final TextEditingController homeCtrl;
  final TextEditingController awayCtrl;
  final FocusNode homeFocus;
  final FocusNode awayFocus;
  final bool predictsPenalties;
  final Guess? existingGuess;
  final ValueChanged<bool> onPenaltiesChanged;

  const _GuessEntry({
    required this.fixture,
    required this.homeCtrl,
    required this.awayCtrl,
    required this.homeFocus,
    required this.awayFocus,
    required this.predictsPenalties,
    required this.existingGuess,
    required this.onPenaltiesChanged,
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
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Autosaves when you move between fields',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: _ScoreInput(
                controller: homeCtrl,
                focusNode: homeFocus,
                nextFocus: awayFocus,
                label: fixture.homeTeam,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Text('–', style: AppTextStyles.scoreLarge),
            ),
            Expanded(
              child: _ScoreInput(
                controller: awayCtrl,
                focusNode: awayFocus,
                label: fixture.awayTeam,
              ),
            ),
          ],
        ),

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
                  activeTrackColor: AppColors.primary,
                  onChanged: onPenaltiesChanged,
                ),
              ],
            ),
          ),
        ],

        if (existingGuess != null) ...[
          const SizedBox(height: AppSpacing.base),
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
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final String label;

  const _ScoreInput({
    required this.controller,
    required this.focusNode,
    this.nextFocus,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundInput,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(
              color: AppColors.scoreFieldIdle,
              width: 1.5,
            ),
          ),
          child: CupertinoTextField(
            controller: controller,
            focusNode: focusNode,
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
            onSubmitted: (_) {
              if (nextFocus != null) {
                nextFocus!.requestFocus();
              } else {
                focusNode.unfocus();
              }
            },
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

// ---------------------------------------------------------------------------
// Locked state
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
// Result view
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
                    color: AppColors.primary.withValues(alpha: 0.15),
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
