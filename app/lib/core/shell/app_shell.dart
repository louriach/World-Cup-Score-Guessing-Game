import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AppShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(child: shell),
          _BottomNav(
            currentIndex: shell.currentIndex,
            onTap: (index) => shell.goBranch(
              index,
              initialLocation: index == shell.currentIndex,
            ),
          ),
        ],
      ),
    );
  }
}

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
