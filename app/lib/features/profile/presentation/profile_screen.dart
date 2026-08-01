import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/models/fixture.dart';
import '../../../shared/models/guess.dart';
import '../../auth/providers/auth_providers.dart';
import '../../leagues/providers/leagues_providers.dart';
import '../data/profile_repository.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  /// Null or matches current user → own profile. Otherwise → peer profile.
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _tabIndex = 0; // 0=Predictions, 1=Leagues, 2=Settings (own only)

  String get _targetUserId =>
      widget.userId ?? Supabase.instance.client.auth.currentUser!.id;

  bool get _isOwnProfile =>
      widget.userId == null ||
      widget.userId == Supabase.instance.client.auth.currentUser?.id;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider(_targetUserId));

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundBase,
      navigationBar: CupertinoNavigationBar(
        middle: profileAsync.maybeWhen(
          data: (p) => Text(p.username),
          orElse: () => const Text('Profile'),
        ),
        backgroundColor: AppColors.backgroundSurface,
        border: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5),
        ),
        trailing: _isOwnProfile
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showEditSheet(context, profileAsync.valueOrNull),
                child: AppIcon.pencil(size: 18, color: AppColors.primary),
              )
            : null,
      ),
      child: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (_, __) => Center(
            child: Text('Could not load profile',
                style: AppTextStyles.bodySecondary),
          ),
          data: (profile) => Column(
            children: [
              _ProfileHeader(profile: profile, isOwnProfile: _isOwnProfile),
              _TabBar(
                index: _tabIndex,
                isOwnProfile: _isOwnProfile,
                onChanged: (i) => setState(() => _tabIndex = i),
              ),
              Expanded(child: _tabContent(profile)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabContent(UserProfile profile) {
    return switch (_tabIndex) {
      0 => _PredictionsTab(userId: _targetUserId),
      1 => _LeaguesTab(userId: _targetUserId),
      _ => _SettingsTab(),
    };
  }

  void _showEditSheet(BuildContext context, UserProfile? profile) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => _EditProfileSheet(
        profile: profile,
        userId: _targetUserId,
      ),
    );
  }
}

// ── Profile header ──────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final bool isOwnProfile;
  const _ProfileHeader({required this.profile, required this.isOwnProfile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundSurface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.xl,
      ),
      child: Row(
        children: [
          _Avatar(url: profile.avatarUrl, size: 64),
          const SizedBox(width: AppSpacing.base),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.username, style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Joined ${DateFormat('MMMM yyyy').format(profile.createdAt)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tab bar ─────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final int index;
  final bool isOwnProfile;
  final ValueChanged<int> onChanged;

  const _TabBar({
    required this.index,
    required this.isOwnProfile,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ['Predictions', 'Leagues', if (isOwnProfile) 'Settings'];

    return Container(
      color: AppColors.backgroundSurface,
      child: Row(
        children: tabs.asMap().entries.map((e) {
          final selected = e.key == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected
                          ? AppColors.primary
                          : AppColors.borderSubtle,
                      width: selected ? 2 : 0.5,
                    ),
                  ),
                ),
                child: Text(
                  e.value,
                  textAlign: TextAlign.center,
                  style: selected
                      ? AppTextStyles.labelLarge
                          .copyWith(color: AppColors.primary)
                      : AppTextStyles.label,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Predictions tab ──────────────────────────────────────────────────────────

class _PredictionsTab extends ConsumerWidget {
  final String userId;
  const _PredictionsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictionsAsync = ref.watch(userPredictionsProvider(userId));

    return predictionsAsync.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (_, __) => Center(
        child: Text('Failed to load predictions',
            style: AppTextStyles.bodySecondary),
      ),
      data: (records) {
        if (records.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.sportscourt,
                    size: 48, color: AppColors.textDisabled),
                const SizedBox(height: AppSpacing.base),
                Text('No predictions yet', style: AppTextStyles.heading3),
                const SizedBox(height: AppSpacing.sm),
                Text('Head to Scores to make your first guess.',
                    style: AppTextStyles.bodySecondary),
              ],
            ),
          );
        }

        final totalPoints = records.fold<int>(
            0, (sum, r) => sum + (r.guess.pointsEarned ?? 0));
        final guessedCount =
            records.where((r) => r.guess.pointsEarned != null).length;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _PredictionsSummary(
                totalPoints: totalPoints,
                totalGuesses: records.length,
                settledGuesses: guessedCount,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _PredictionRow(record: records[i]),
                childCount: records.length,
              ),
            ),
            const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl)),
          ],
        );
      },
    );
  }
}

class _PredictionsSummary extends StatelessWidget {
  final int totalPoints;
  final int totalGuesses;
  final int settledGuesses;

  const _PredictionsSummary({
    required this.totalPoints,
    required this.totalGuesses,
    required this.settledGuesses,
  });

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
      child: Row(
        children: [
          _StatCell(label: 'Total points', value: '$totalPoints'),
          _Divider(),
          _StatCell(label: 'Predictions', value: '$totalGuesses'),
          _Divider(),
          _StatCell(
            label: 'Settled',
            value: '$settledGuesses',
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style:
                  AppTextStyles.scoreMedium.copyWith(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.xs),
          Text(label,
              style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 0.5, height: 36, color: AppColors.borderSubtle);
}

class _PredictionRow extends StatelessWidget {
  final PredictionRecord record;
  const _PredictionRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final guess = record.guess;
    final fixture = record.fixture;
    final settled = guess.pointsEarned != null;
    final pts = guess.pointsEarned ?? 0;

    return GestureDetector(
      onTap: () => context.push('/scores/${fixture.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: AppSpacing.xs,
        ),
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
                  Text(
                    '${fixture.homeTeam} vs ${fixture.awayTeam}',
                    style: AppTextStyles.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(
                        'Your guess: ${guess.homeScoreGuess}–${guess.awayScoreGuess}',
                        style: AppTextStyles.caption,
                      ),
                      if (fixture.isCompleted && fixture.homeScore != null) ...[
                        Text('  ·  Result: ${fixture.homeScore}–${fixture.awayScore}',
                            style: AppTextStyles.caption),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.base),
            if (settled)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: pts > 0
                      ? AppColors.primary.withOpacity(0.15)
                      : AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                ),
                child: Text(
                  '+$pts',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: pts > 0 ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              )
            else
              Text('Pending', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

// ── Leagues tab ──────────────────────────────────────────────────────────────

class _LeaguesTab extends ConsumerWidget {
  final String userId;
  const _LeaguesTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaguesAsync = ref.watch(myLeaguesProvider);

    return leaguesAsync.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (_, __) => Center(
        child: Text('Failed to load leagues',
            style: AppTextStyles.bodySecondary),
      ),
      data: (leagues) {
        if (leagues.isEmpty) {
          return Center(
            child: Text('Not in any leagues yet.',
                style: AppTextStyles.bodySecondary),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          itemCount: leagues.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.listGap),
          itemBuilder: (_, i) {
            final league = leagues[i];
            return GestureDetector(
              onTap: () => context.push('/leagues/${league.id}'),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface,
                  borderRadius: AppRadius.cardBR,
                  border:
                      Border.all(color: AppColors.borderSubtle, width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(league.name,
                            style: AppTextStyles.bodyLargeBold)),
                    const Icon(CupertinoIcons.chevron_right,
                        size: 14, color: AppColors.textDisabled),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Settings tab (own profile only) ─────────────────────────────────────────

class _SettingsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<_SettingsTab> {
  bool _reminder24h = true;
  bool _reminder1h = true;
  bool _resultNotification = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await ref.read(notificationPreferencesProvider.future);
    if (mounted) {
      setState(() {
        _reminder24h = prefs['reminder_24h'] ?? true;
        _reminder1h = prefs['reminder_1h'] ?? true;
        _resultNotification = prefs['result_notification'] ?? true;
        _loaded = true;
      });
    }
  }

  Future<void> _save() async {
    await ref.read(notificationPrefsNotifierProvider.notifier).save(
          reminder24h: _reminder24h,
          reminder1h: _reminder1h,
          resultNotification: _resultNotification,
        );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        // Notifications section
        Text('Notifications', style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        _SettingsCard(children: [
          _ToggleRow(
            label: '24h before kickoff',
            value: _reminder24h,
            onChanged: (v) {
              setState(() => _reminder24h = v);
              _save();
            },
          ),
          _SettingsDivider(),
          _ToggleRow(
            label: '1h before kickoff',
            value: _reminder1h,
            onChanged: (v) {
              setState(() => _reminder1h = v);
              _save();
            },
          ),
          _SettingsDivider(),
          _ToggleRow(
            label: 'Result & points',
            value: _resultNotification,
            onChanged: (v) {
              setState(() => _resultNotification = v);
              _save();
            },
          ),
        ]),

        const SizedBox(height: AppSpacing.xl),

        // Account section
        Text('Account', style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        _SettingsCard(children: [
          _ActionRow(
            label: 'Sign out',
            isDestructive: true,
            onTap: () => _confirmSignOut(context),
          ),
          _SettingsDivider(),
          _ActionRow(
            label: 'Delete account',
            isDestructive: true,
            onTap: () => _confirmDeleteAccount(context),
          ),
        ]),

        const SizedBox(height: AppSpacing.xxxl),
        Center(
          child: Text('Golden Goals · v1.0.0',
              style: AppTextStyles.caption),
        ),
      ],
    );
  }

  void _confirmSignOut(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/sign-in');
            },
            child: const Text('Sign out'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Delete account'),
        content: const Text(
          'This will permanently delete your account and all your data. This cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authRepositoryProvider).deleteAccount();
              if (context.mounted) context.go('/sign-in');
            },
            child: const Text('Delete account'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: AppRadius.cardBR,
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          CupertinoSwitch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ActionRow({
    required this.label,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding,
          vertical: AppSpacing.base,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: isDestructive ? AppColors.error : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 0.5,
        margin: const EdgeInsets.only(left: AppSpacing.cardPadding),
        color: AppColors.borderSubtle,
      );
}

// ── Edit profile sheet ───────────────────────────────────────────────────────

class _EditProfileSheet extends ConsumerStatefulWidget {
  final UserProfile? profile;
  final String userId;

  const _EditProfileSheet({required this.profile, required this.userId});

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _usernameCtrl;
  Uint8List? _newAvatarBytes;
  bool _checkingUsername = false;
  bool _usernameTaken = false;

  @override
  void initState() {
    super.initState();
    _usernameCtrl =
        TextEditingController(text: widget.profile?.username ?? '');
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      !_checkingUsername &&
      !_usernameTaken &&
      (_usernameCtrl.text.trim().length >= 3 || _newAvatarBytes != null);

  Future<void> _save() async {
    await ref.read(editProfileNotifierProvider.notifier).save(
          userId: widget.userId,
          username: _usernameCtrl.text.trim() != widget.profile?.username
              ? _usernameCtrl.text
              : null,
          avatarBytes: _newAvatarBytes,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: AppRadius.sheetBR,
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Edit profile', style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.xl),
            Text('Username', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundInput,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(
                  color: _usernameTaken
                      ? AppColors.borderError
                      : AppColors.borderDefault,
                  width: 1.5,
                ),
              ),
              child: CupertinoTextField(
                controller: _usernameCtrl,
                style: AppTextStyles.body,
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: null,
                autocorrect: false,
                maxLength: 20,
              ),
            ),
            if (_usernameTaken)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text('Username taken.',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.error)),
              ),
            const SizedBox(height: AppSpacing.xxxl),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: _canSave
                    ? AppColors.buttonPrimary
                    : AppColors.buttonDisabled,
                borderRadius: BorderRadius.circular(AppRadius.button),
                onPressed: (state is AsyncLoading || !_canSave) ? null : _save,
                child: state is AsyncLoading
                    ? const CupertinoActivityIndicator(
                        color: AppColors.textInverse)
                    : DefaultTextStyle.merge(
                        style: AppTextStyles.bodyLargeBold
                            .copyWith(color: AppColors.buttonPrimaryLabel),
                        child: const Text('Save'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared avatar widget ─────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? url;
  final double size;
  const _Avatar({this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
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
                color: AppColors.textDisabled,
              ),
            )
          : const Icon(CupertinoIcons.person_fill,
              color: AppColors.textDisabled),
    );
  }
}
