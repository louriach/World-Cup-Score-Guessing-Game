import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/league.dart';
import '../providers/leagues_providers.dart';

class LeaguesScreen extends ConsumerWidget {
  const LeaguesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaguesAsync = ref.watch(myLeaguesProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundBase,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Leagues'),
        backgroundColor: AppColors.backgroundSurface,
        border: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add, color: AppColors.primary),
          onPressed: () => _showLeagueOptions(context),
        ),
      ),
      child: SafeArea(
        child: leaguesAsync.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (_, __) => Center(
            child: Text('Failed to load leagues',
                style: AppTextStyles.bodySecondary),
          ),
          data: (leagues) => leagues.isEmpty
              ? _EmptyState()
              : _LeagueList(leagues: leagues),
        ),
      ),
    );
  }

  void _showLeagueOptions(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              context.push('/leagues/create');
            },
            child: const Text('Create a league'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              context.push('/leagues/join');
            },
            child: const Text('Join a league'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.person_3,
                size: 56, color: AppColors.textDisabled),
            const SizedBox(height: AppSpacing.xl),
            Text('No leagues yet', style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create a league and challenge your mates, or join one with a code and phrase.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: AppColors.buttonPrimary,
                borderRadius: BorderRadius.circular(AppRadius.button),
                onPressed: () => context.push('/leagues/create'),
                child: Text(
                  'Create a league',
                  style: AppTextStyles.bodyLargeBold
                      .copyWith(color: AppColors.buttonPrimaryLabel),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: AppColors.buttonSecondary,
                borderRadius: BorderRadius.circular(AppRadius.button),
                onPressed: () => context.push('/leagues/join'),
                child: Text('Join a league',
                    style: AppTextStyles.bodyLargeBold
                        .copyWith(color: AppColors.buttonSecondaryLabel)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeagueList extends StatelessWidget {
  final List<League> leagues;
  const _LeagueList({required this.leagues});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      itemCount: leagues.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.listGap),
      itemBuilder: (context, i) => _LeagueCard(league: leagues[i]),
    );
  }
}

class _LeagueCard extends StatelessWidget {
  final League league;
  const _LeagueCard({required this.league});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/leagues/${league.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: AppRadius.cardBR,
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(league.name, style: AppTextStyles.bodyLargeBold),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Code: ${league.joinCode}',
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right,
                color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}
