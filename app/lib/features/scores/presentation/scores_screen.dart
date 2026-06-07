import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/fixture.dart';
import '../../../shared/models/guess.dart';
import '../providers/scores_providers.dart';

class ScoresScreen extends ConsumerStatefulWidget {
  const ScoresScreen({super.key});

  @override
  ConsumerState<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends ConsumerState<ScoresScreen> {
  // 0 = Upcoming, 1 = Results
  int _segmentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundBase,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Scores'),
        backgroundColor: AppColors.backgroundSurface,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _SegmentedControl(
              index: _segmentIndex,
              onChanged: (i) => setState(() => _segmentIndex = i),
            ),
            Expanded(
              child: _segmentIndex == 0
                  ? const _UpcomingList()
                  : const _ResultsList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _SegmentedControl({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.md,
      ),
      child: CupertinoSlidingSegmentedControl<int>(
        backgroundColor: AppColors.backgroundSurface,
        thumbColor: AppColors.backgroundElevated,
        groupValue: index,
        onValueChanged: (v) => onChanged(v ?? 0),
        children: const {
          0: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Text('Upcoming'),
          ),
          1: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Text('Results'),
          ),
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Upcoming fixtures
// ---------------------------------------------------------------------------

class _UpcomingList extends ConsumerWidget {
  const _UpcomingList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixturesAsync = ref.watch(fixturesByMatchdayProvider);
    final guessesAsync = ref.watch(myGuessesProvider);

    return fixturesAsync.when(
      loading: () =>
          const Center(child: CupertinoActivityIndicator()),
      error: (e, _) => Center(
        child: Text('Failed to load fixtures',
            style: AppTextStyles.bodySecondary),
      ),
      data: (byMatchday) {
        final guesses = guessesAsync.valueOrNull ?? {};
        final upcoming = byMatchday.entries
            .where((e) => e.value.any((f) => !f.isCompleted))
            .toList();

        if (upcoming.isEmpty) {
          return Center(
            child: Text('No upcoming fixtures',
                style: AppTextStyles.bodySecondary),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            left: AppSpacing.pagePadding,
            right: AppSpacing.pagePadding,
            bottom: AppSpacing.xxxl,
          ),
          itemCount: upcoming.length,
          itemBuilder: (context, i) {
            final matchday = upcoming[i].key;
            final fixtures = upcoming[i]
                .value
                .where((f) => !f.isCompleted)
                .toList();

            return _MatchdaySection(
              matchday: matchday,
              fixtures: fixtures,
              guesses: guesses,
            );
          },
        );
      },
    );
  }
}

class _MatchdaySection extends StatelessWidget {
  final int matchday;
  final List<Fixture> fixtures;
  final Map<String, Guess> guesses;

  const _MatchdaySection({
    required this.matchday,
    required this.fixtures,
    required this.guesses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xl,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            'Matchday $matchday',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...fixtures.map((f) => _FixtureCard(
              fixture: f,
              guess: guesses[f.id],
            )),
      ],
    );
  }
}

class _FixtureCard extends StatelessWidget {
  final Fixture fixture;
  final Guess? guess;

  const _FixtureCard({required this.fixture, this.guess});

  @override
  Widget build(BuildContext context) {
    final hasGuess = guess != null;
    final isLocked = fixture.isLocked;

    return GestureDetector(
      onTap: () => context.push('/scores/${fixture.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: AppRadius.cardBR,
          border: Border.all(
            color: hasGuess ? AppColors.borderSuccess : AppColors.borderSubtle,
            width: hasGuess ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          children: [
            // Kickoff time + lock status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('E d MMM · HH:mm').format(fixture.kickoffTime.toLocal()),
                  style: AppTextStyles.caption,
                ),
                if (isLocked)
                  Text('Locked',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.error))
                else if (hasGuess)
                  Text('Guessed ✓',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.success)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Teams + scores
            Row(
              children: [
                Expanded(
                  child: Text(
                    fixture.homeTeam,
                    style: AppTextStyles.bodyLargeBold,
                    textAlign: TextAlign.center,
                  ),
                ),
                _ScoreDisplay(guess: guess),
                Expanded(
                  child: Text(
                    fixture.awayTeam,
                    style: AppTextStyles.bodyLargeBold,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  final Guess? guess;
  const _ScoreDisplay({this.guess});

  @override
  Widget build(BuildContext context) {
    if (guess == null) {
      return Container(
        width: 72,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        ),
        child: Text(
          '? – ?',
          textAlign: TextAlign.center,
          maxLines: 1,
          style: AppTextStyles.scoreMedium.copyWith(
            color: AppColors.textDisabled,
            fontSize: 16,
          ),
        ),
      );
    }

    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.borderSuccess, width: 1),
      ),
      child: Text(
        '${guess!.homeScoreGuess} – ${guess!.awayScoreGuess}',
        textAlign: TextAlign.center,
        maxLines: 1,
        style: AppTextStyles.scoreMedium.copyWith(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Results
// ---------------------------------------------------------------------------

class _ResultsList extends ConsumerWidget {
  const _ResultsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixturesAsync = ref.watch(fixturesByMatchdayProvider);
    final guessesAsync = ref.watch(myGuessesProvider);

    return fixturesAsync.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (_, __) => Center(
        child: Text('Failed to load results',
            style: AppTextStyles.bodySecondary),
      ),
      data: (byMatchday) {
        final guesses = guessesAsync.valueOrNull ?? {};
        final completed = byMatchday.entries
            .where((e) => e.value.any((f) => f.isCompleted))
            .toList()
            .reversed
            .toList();

        if (completed.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.sportscourt,
                    size: 48, color: AppColors.textDisabled),
                const SizedBox(height: AppSpacing.base),
                Text('No results yet', style: AppTextStyles.heading3),
                const SizedBox(height: AppSpacing.sm),
                Text('Check back after the first kick-off',
                    style: AppTextStyles.bodySecondary),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            left: AppSpacing.pagePadding,
            right: AppSpacing.pagePadding,
            bottom: AppSpacing.xxxl,
          ),
          itemCount: completed.length,
          itemBuilder: (context, i) {
            final fixtures =
                completed[i].value.where((f) => f.isCompleted).toList();
            return _MatchdaySection(
              matchday: completed[i].key,
              fixtures: fixtures,
              guesses: guesses,
            );
          },
        );
      },
    );
  }
}
