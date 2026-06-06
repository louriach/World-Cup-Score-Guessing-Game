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
      GoRoute(path: '/sign-in', builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/scores',
              builder: (_, __) => const ScoresScreen(),
              routes: [
                GoRoute(
                  path: ':fixtureId',
                  builder: (_, state) =>
                      FixtureDetailScreen(fixtureId: state.pathParameters['fixtureId']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/leagues',
              builder: (_, __) => const LeaguesScreen(),
              routes: [
                GoRoute(path: 'create', builder: (_, __) => const CreateLeagueScreen()),
                GoRoute(path: 'join', builder: (_, __) => const JoinLeagueScreen()),
                GoRoute(
                  path: ':leagueId',
                  builder: (_, state) =>
                      LeagueDetailScreen(leagueId: state.pathParameters['leagueId']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/me',
              builder: (_, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: ':userId',
                  builder: (_, state) =>
                      ProfileScreen(userId: state.pathParameters['userId']),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
}
