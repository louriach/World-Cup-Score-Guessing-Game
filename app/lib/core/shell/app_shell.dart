import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AppShell({super.key, required this.shell});

  void _onTap(int index) => shell.goBranch(
        index,
        initialLocation: index == shell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    // On wide web screens, show a side nav instead of bottom nav
    if (kIsWeb && MediaQuery.of(context).size.width > 600) {
      return _DesktopShell(
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
// Desktop layout — top nav bar with text tabs
// ---------------------------------------------------------------------------

class _DesktopShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _DesktopShell({
    required this.shell,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (icon: CupertinoIcons.house_fill, label: 'Home'),
    (icon: CupertinoIcons.flag_fill, label: 'Scores'),
    (icon: CupertinoIcons.person_3_fill, label: 'Leagues'),
    (icon: CupertinoIcons.person_crop_circle_fill, label: 'Me'),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundBase,
      child: Column(
        children: [
          // Top nav bar
          Container(
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.backgroundSurface,
              border: Border(
                bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 24),
                // Logo
                Image.asset(
                  'assets/images/app_icon.png',
                  width: 28,
                  height: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Golden Goals',
                  style: AppTextStyles.bodyLargeBold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                // Nav items
                ...List.generate(_items.length, (i) {
                  final item = _items[i];
                  final selected = i == currentIndex;
                  return CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () => onTap(i),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 16,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(width: 24),
              ],
            ),
          ),
          // Page content
          Expanded(child: shell),
        ],
      ),
    );
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
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.house_fill),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.flag_fill),
          label: 'Scores',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person_3_fill),
          label: 'Leagues',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person_crop_circle_fill),
          label: 'Me',
        ),
      ],
    );
  }
}
