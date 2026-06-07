import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/leagues/presentation/create_league_screen.dart';
import '../../features/leagues/presentation/join_league_screen.dart';
import '../../features/leagues/presentation/league_detail_screen.dart';
import '../../features/leagues/presentation/leagues_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/scores/presentation/fixture_detail_screen.dart';
import '../../features/scores/presentation/scores_screen.dart';
import '../shell/app_shell.dart';

part 'router.g.dart';

/// Bridges Supabase auth state changes into a [ChangeNotifier] so go_router
/// re-evaluates its redirect whenever the session changes (sign in, sign out,
/// token expiry).
class _AuthChangeNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;

  _AuthChangeNotifier(Stream<AuthState> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

@riverpod
GoRouter router(Ref ref) {
  // Rebuild the router redirect when auth state changes so an expired
  // session kicks the user back to sign-in without requiring a restart.
  final authStream = Supabase.instance.client.auth.onAuthStateChange;
  final notifier = _AuthChangeNotifier(authStream);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/home',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuth = session != null;
      final loc = state.matchedLocation;
      final isAuthRoute =
          loc.startsWith('/sign-in') || loc.startsWith('/onboarding');

      // Not signed in — send to sign-in unless already there
      if (!isAuth && !isAuthRoute) return '/sign-in';

      // Signed in but trying to view auth screens — redirect to home
      // (onboarding redirect is handled in SignInScreen after profile check)
      if (isAuth && loc == '/sign-in') return '/home';

      return null;
    },
    routes: [
      GoRoute(path: '/sign-in', pageBuilder: (_, __) => _fadePage(const SignInScreen())),
      GoRoute(path: '/onboarding', pageBuilder: (_, __) => _fadePage(const OnboardingScreen())),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', pageBuilder: (_, __) => _fadePage(const HomeScreen())),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/scores',
              pageBuilder: (_, __) => _fadePage(const ScoresScreen()),
              routes: [
                GoRoute(
                  path: ':fixtureId',
                  pageBuilder: (_, state) =>
                      _fadePage(FixtureDetailScreen(fixtureId: state.pathParameters['fixtureId']!)),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/leagues',
              pageBuilder: (_, __) => _fadePage(const LeaguesScreen()),
              routes: [
                GoRoute(path: 'create', pageBuilder: (_, __) => _fadePage(const CreateLeagueScreen())),
                GoRoute(path: 'join', pageBuilder: (_, __) => _fadePage(const JoinLeagueScreen())),
                GoRoute(
                  path: ':leagueId',
                  pageBuilder: (_, state) =>
                      _fadePage(LeagueDetailScreen(leagueId: state.pathParameters['leagueId']!)),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/me',
              pageBuilder: (_, __) => _fadePage(const ProfileScreen()),
              routes: [
                GoRoute(
                  path: ':userId',
                  pageBuilder: (_, state) =>
                      _fadePage(ProfileScreen(userId: state.pathParameters['userId'])),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
}

/// Instant page transition — no slide, no fade delay. Feels like a web page.
CustomTransitionPage<void> _fadePage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (_, __, ___, child) => child,
  );
}
