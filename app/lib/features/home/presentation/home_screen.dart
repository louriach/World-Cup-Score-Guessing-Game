import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_nav_bar.dart';
import '../../../shared/models/fixture.dart';
import '../../../shared/models/league.dart';
import '../../scores/providers/scores_providers.dart';
import '../providers/home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Guard: if the user has no profile row yet, send them to onboarding.
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final row = await Supabase.instance.client
            .from('users')
            .select('id')
            .eq('id', userId)
            .maybeSingle();
        if (row == null && context.mounted) {
          context.go('/onboarding');
        }
      });
    }

    final nextMatchdayAsync = ref.watch(nextMatchdayProvider);
    final snapshotsAsync = ref.watch(leagueSnapshotsProvider);
    final guessesAsync = ref.watch(myGuessesProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundBase,
      navigationBar: appNavBar(context: context, middle: const Text('Golden Goals')),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Up next module ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  AppSpacing.xl,
                  AppSpacing.pagePadding,
                  0,
                ),
                child: nextMatchdayAsync.when(
                  loading: () => const _SectionSkeleton(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (next) => next == null
                      ? const _TournamentCompleteCard()
                      : _NextMatchdayModule(
                          matchday: next.matchday,
                          fixtures: next.fixtures,
                          guesses: guessesAsync.valueOrNull ?? {},
                        ),
                ),
              ),
            ),

            // ── League snapshots carousel ────────────────────────────────
            SliverToBoxAdapter(
              child: snapshotsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (snapshots) => snapshots.isEmpty
                    ? const _NoLeaguesPrompt()
                    : _LeagueCarousel(snapshots: snapshots),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xxxl),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Up next module ─────────────────────────────────────────────────────────

class _NextMatchdayModule extends StatelessWidget {
  final int matchday;
  final List<Fixture> fixtures;
  final Map<String, dynamic> guesses;

  const _NextMatchdayModule({
    required this.matchday,
    required this.fixtures,
    required this.guesses,
  });

  @override
  Widget build(BuildContext context) {
    final count = fixtures.length;
    final guessedCount = fixtures.where((f) => guesses.containsKey(f.id)).length;
    final allSameDay = fixtures
        .every((f) => _sameDay(f.kickoffTime, fixtures.first.kickoffTime));

    final headline = count == 1
        ? 'Up next: ${fixtures.first.homeTeam} vs ${fixtures.first.awayTeam}'
        : allSameDay
            ? 'There ${count == 1 ? 'is' : 'are'} $count matches ${_dayLabel(fixtures.first.kickoffTime)}'
            : '$count upcoming matches in matchday $matchday';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(headline, style: AppTextStyles.heading3),
            ),
          ],
        ),
        if (count > 1)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              '$guessedCount of $count predictions made',
              style: AppTextStyles.bodySecondary.copyWith(
                color: guessedCount == count
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.base),
        ...fixtures.map((f) => _HomeFixtureCard(
              fixture: f,
              hasGuess: guesses.containsKey(f.id),
            )),
      ],
    );
  }

  String _dayLabel(DateTime dt) {
    final now = DateTime.now();
    if (_sameDay(dt, now)) return 'today';
    if (_sameDay(dt, now.add(const Duration(days: 1)))) return 'tomorrow';
    return 'on ${DateFormat('EEEE').format(dt)}';
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _HomeFixtureCard extends StatelessWidget {
  final Fixture fixture;
  final bool hasGuess;

  const _HomeFixtureCard({required this.fixture, required this.hasGuess});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/scores/${fixture.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: AppRadius.cardBR,
          border: Border.all(
            color: hasGuess ? AppColors.borderSuccess : AppColors.borderSubtle,
            width: hasGuess ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                fixture.homeTeam,
                style: AppTextStyles.body,
                textAlign: TextAlign.right,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: hasGuess
                  ? const Icon(CupertinoIcons.checkmark_circle_fill,
                      color: AppColors.success, size: 20)
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundElevated,
                        borderRadius:
                            BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text('Predict',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.primary)),
                    ),
            ),
            Expanded(
              child: Text(
                fixture.awayTeam,
                style: AppTextStyles.body,
              ),
            ),
            const Icon(CupertinoIcons.chevron_right,
                size: 14, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}

class _TournamentCompleteCard extends StatelessWidget {
  const _TournamentCompleteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: AppRadius.cardBR,
        border: Border.all(color: AppColors.primary, width: 1.5),
        boxShadow: AppShadows.goldGlow,
      ),
      child: Column(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.base),
          Text('Tournament complete!', style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Check the leaderboard to see how you finished.',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── League carousel ────────────────────────────────────────────────────────

class _LeagueCarousel extends StatelessWidget {
  final List<LeagueSnapshot> snapshots;
  const _LeagueCarousel({required this.snapshots});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.sectionGap,
            AppSpacing.pagePadding,
            AppSpacing.base,
          ),
          child: Text('Your leagues', style: AppTextStyles.heading3),
        ),
        SizedBox(
          height: 232,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding),
            itemCount: snapshots.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.base),
            itemBuilder: (_, i) => _LeagueSnapshotCard(snapshot: snapshots[i]),
          ),
        ),
      ],
    );
  }
}

class _LeagueSnapshotCard extends StatelessWidget {
  final LeagueSnapshot snapshot;
  const _LeagueSnapshotCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id;

    return GestureDetector(
      onTap: () => context.push('/leagues/${snapshot.league.id}'),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: AppRadius.cardBR,
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // League name + member count
            Text(
              snapshot.league.name,
              style: AppTextStyles.bodyLargeBold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${snapshot.totalMembers} members',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(height: 0.5, color: AppColors.borderSubtle),
            const SizedBox(height: AppSpacing.md),

            // Top 4 rows
            ...snapshot.topMembers.asMap().entries.map((e) {
              final rank = e.key + 1;
              final member = e.value as LeagueMember;
              final isYou = member.userId == currentUserId;
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        _rankLabel(rank),
                        style: AppTextStyles.caption.copyWith(
                          color: rank == 1
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _MiniAvatar(url: member.avatarUrl),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        isYou ? 'You' : member.username,
                        style: isYou
                            ? AppTextStyles.labelLarge
                                .copyWith(color: AppColors.primary)
                            : AppTextStyles.label.copyWith(
                                color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${member.totalPoints}',
                      style: AppTextStyles.labelLarge,
                    ),
                  ],
                ),
              );
            }),

            // Fade hint that there are more rows below
            if (snapshot.totalMembers > 4)
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.textSecondary,
                    AppColors.backgroundSurface.withOpacity(0),
                  ],
                ).createShader(bounds),
                child: Text(
                  '+ ${snapshot.totalMembers - 4} more',
                  style: AppTextStyles.caption,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _rankLabel(int rank) => switch (rank) {
        1 => '🥇',
        2 => '🥈',
        3 => '🥉',
        _ => '$rank.',
      };
}

class _MiniAvatar extends StatelessWidget {
  final String? url;
  const _MiniAvatar({this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.backgroundElevated,
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null
          ? CachedNetworkImage(
              imageUrl: url!,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox.shrink(),
              errorWidget: (_, __, ___) => const Icon(
                CupertinoIcons.person_fill,
                size: 12,
                color: AppColors.textDisabled,
              ),
            )
          : const Icon(CupertinoIcons.person_fill,
              size: 12, color: AppColors.textDisabled),
    );
  }
}

// ── Empty / skeleton states ────────────────────────────────────────────────

class _NoLeaguesPrompt extends StatelessWidget {
  const _NoLeaguesPrompt();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.sectionGap,
        AppSpacing.pagePadding,
        0,
      ),
      child: GestureDetector(
        onTap: () => context.go('/leagues'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            borderRadius: AppRadius.cardBR,
            border:
                Border.all(color: AppColors.borderSubtle, width: 0.5),
          ),
          child: Column(
            children: [
              const Icon(CupertinoIcons.person_3,
                  size: 36, color: AppColors.textDisabled),
              const SizedBox(height: AppSpacing.base),
              Text('No leagues yet', style: AppTextStyles.bodyLargeBold),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Create or join a league to see the table here.',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: AppRadius.cardBR,
      ),
    );
  }
}
