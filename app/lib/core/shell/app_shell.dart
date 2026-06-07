import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_icon.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AppShell({super.key, required this.shell});

  void _onTap(int index) => shell.goBranch(
        index,
        initialLocation: index == shell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && MediaQuery.of(context).size.width > 600) {
      return _SidebarShell(
        shell: shell,
        currentIndex: shell.currentIndex,
        onTap: _onTap,
      );
    }

    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(child: shell),
          _BottomNav(
            currentIndex: shell.currentIndex,
            onTap: _onTap,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop sidebar layout
// ---------------------------------------------------------------------------

class _SidebarShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SidebarShell({
    required this.shell,
    required this.currentIndex,
    required this.onTap,
  });

  static const _labels = ['Home', 'Scores', 'Leagues', 'Me'];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.backgroundBase,
      child: Row(
        children: [
          // ── Left sidebar ──────────────────────────────────────────────
          Container(
            width: 220,
            decoration: const BoxDecoration(
              color: AppColors.backgroundSurface,
              border: Border(
                right: BorderSide(color: AppColors.borderSubtle, width: 0.5),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/app_icon.png',
                          width: 32,
                          height: 32,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Golden Goals',
                          style: AppTextStyles.bodyLargeBold.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Nav items
                  ...List.generate(_labels.length, (i) {
                    final selected = i == currentIndex;
                    return _HoverNavItem(
                      key: ValueKey(i),
                      selected: selected,
                      onTap: () => onTap(i),
                      child: Row(
                        children: [
                          _sidebarIcon(i, selected),
                          const SizedBox(width: 12),
                          Text(
                            _labels[i],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? AppColors.primary : AppColors.textSecondary,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────────────────
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: shell,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverNavItem extends StatefulWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  const _HoverNavItem({super.key, required this.selected, required this.onTap, required this.child});

  @override
  State<_HoverNavItem> createState() => _HoverNavItemState();
}

class _HoverNavItemState extends State<_HoverNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: widget.selected
                  ? AppColors.primary.withOpacity(0.12)
                  : _hovered
                      ? AppColors.backgroundElevated
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

Widget _sidebarIcon(int index, bool selected) {
  final color = selected ? AppColors.primary : AppColors.textSecondary;
  switch (index) {
    case 0: return AppIcon.home(size: 18, color: color);
    case 1: return AppIcon.scores(size: 18, color: color);
    case 2: return AppIcon.leagues(size: 18, color: color);
    default: return AppIcon.me(size: 18, color: color);
  }
}

// ---------------------------------------------------------------------------
// Mobile bottom nav
// ---------------------------------------------------------------------------

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: AppIcon.home(size: 22, color: AppColors.textSecondary),
          activeIcon: AppIcon.home(size: 22, color: AppColors.primary),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: AppIcon.scores(size: 22, color: AppColors.textSecondary),
          activeIcon: AppIcon.scores(size: 22, color: AppColors.primary),
          label: 'Scores',
        ),
        BottomNavigationBarItem(
          icon: AppIcon.leagues(size: 22, color: AppColors.textSecondary),
          activeIcon: AppIcon.leagues(size: 22, color: AppColors.primary),
          label: 'Leagues',
        ),
        BottomNavigationBarItem(
          icon: AppIcon.me(size: 22, color: AppColors.textSecondary),
          activeIcon: AppIcon.me(size: 22, color: AppColors.primary),
          label: 'Me',
        ),
      ],
    );
  }
}
