import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/league.dart';
import '../providers/leagues_providers.dart';

class LeagueDetailScreen extends ConsumerWidget {
  final String leagueId;
  const LeagueDetailScreen({super.key, required this.leagueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaguesAsync = ref.watch(myLeaguesProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider(leagueId));
    final currentUserId = Supabase.instance.client.auth.currentUser!.id;

    final league = leaguesAsync.valueOrNull
        ?.firstWhere((l) => l.id == leagueId, orElse: () => throw StateError(''));

    final isAdmin = league?.adminUserId == currentUserId;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundBase,
      navigationBar: CupertinoNavigationBar(
        middle: Text(league?.name ?? ''),
        backgroundColor: AppColors.backgroundSurface,
        border: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5),
        ),
        trailing: league != null
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.share,
                    color: AppColors.primary, size: 20),
                onPressed: () => _share(league),
              )
            : null,
      ),
      child: SafeArea(
        child: leaderboardAsync.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (_, __) => Center(
            child: Text('Failed to load leaderboard',
                style: AppTextStyles.bodySecondary),
          ),
          data: (members) => CustomScrollView(
            slivers: [
              // League join details banner
              if (league != null)
                SliverToBoxAdapter(
                  child: _JoinDetailsBanner(league: league),
                ),

              // Leaderboard header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.xl,
                    AppSpacing.pagePadding,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Leaderboard',
                            style: AppTextStyles.heading3),
                      ),
                      Text('${members.length} members',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ),

              // Leaderboard rows
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _LeaderboardRow(
                    rank: i + 1,
                    member: members[i],
                    isCurrentUser: members[i].userId == currentUserId,
                    isAdmin: isAdmin,
                    leagueAdminId: league?.adminUserId ?? '',
                    onRemove: isAdmin && members[i].userId != currentUserId
                        ? () => _confirmRemove(context, ref, members[i])
                        : null,
                  ),
                  childCount: members.length,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _share(League league) {
    Share.share(
      'Join my Golden Goals league!\n\nLeague: ${league.name}\nCode: ${league.joinCode}\nPhrase: ${league.joinPhrase}',
    );
  }

  void _confirmRemove(
      BuildContext context, WidgetRef ref, LeagueMember member) {
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Remove member'),
        content: Text(
            'Remove ${member.username} from this league? They can rejoin with the code and phrase.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              ref.read(removeMemberNotifierProvider.notifier).remove(
                    leagueId: leagueId,
                    userId: member.userId,
                  );
            },
            child: const Text('Remove'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _JoinDetailsBanner extends StatelessWidget {
  final League league;
  const _JoinDetailsBanner({required this.league});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.pagePadding),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: AppRadius.cardBR,
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Invite friends', style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSpacing.md),
          _CopyRow(label: 'Code', value: league.joinCode),
          const SizedBox(height: AppSpacing.sm),
          _CopyRow(label: 'Phrase', value: league.joinPhrase),
        ],
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  final String label;
  final String value;
  const _CopyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        Expanded(child: Text(value, style: AppTextStyles.bodyLargeBold)),
        CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: () => Clipboard.setData(ClipboardData(text: value)),
          child: const Icon(CupertinoIcons.doc_on_clipboard,
              size: 16, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final LeagueMember member;
  final bool isCurrentUser;
  final bool isAdmin;
  final String leagueAdminId;
  final VoidCallback? onRemove;

  const _LeaderboardRow({
    required this.rank,
    required this.member,
    required this.isCurrentUser,
    required this.isAdmin,
    required this.leagueAdminId,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isLeagueAdmin = member.userId == leagueAdminId;

    return GestureDetector(
      onTap: () => context.push('/me/${member.userId}'),
      onLongPress: onRemove,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: AppSpacing.xs,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.backgroundSurface,
          borderRadius: AppRadius.cardBR,
          border: Border.all(
            color: isCurrentUser ? AppColors.primary : AppColors.borderSubtle,
            width: isCurrentUser ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 28,
              child: Text(
                _rankLabel(rank),
                style: AppTextStyles.rank.copyWith(
                  color: rank <= 3
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Avatar
            _Avatar(url: member.avatarUrl, size: 36),
            const SizedBox(width: AppSpacing.md),
            // Name + games played
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(member.username,
                          style: isCurrentUser
                              ? AppTextStyles.bodyLargeBold
                              : AppTextStyles.body),
                      if (isLeagueAdmin) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(AppRadius.badge),
                          ),
                          child: Text('admin',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${member.gamesGuessed} predictions made',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            // Points
            Text(
              '${member.totalPoints}',
              style: AppTextStyles.scoreMedium.copyWith(
                color: isCurrentUser ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text('pts', style: AppTextStyles.caption),
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

class _Avatar extends StatelessWidget {
  final String? url;
  final double size;
  const _Avatar({this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
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
                color: AppColors.textDisabled,
              ),
            )
          : const Icon(CupertinoIcons.person_fill,
              color: AppColors.textDisabled),
    );
  }
}
