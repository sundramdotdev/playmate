import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/storage_service.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/dice/dice_screen.dart';
import '../features/coin/coin_screen.dart';
import '../features/team_generator/team_screen.dart';
import '../features/score_tracker/score_screen.dart';
import '../features/cricket/cricket_screen.dart';
import '../features/spin_wheel/spin_wheel_screen.dart';
import '../features/tournament/tournament_screen.dart';
import '../features/timer/timer_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/about/about_screen.dart';
import '../features/about/privacy_policy_screen.dart';
import '../features/about/terms_screen.dart';
import '../features/about/changelog_screen.dart';

GoRouter createAppRouter({String? initialLocation}) {
  return GoRouter(
    initialLocation:
        initialLocation ??
        (StorageService.hasCompletedOnboarding() ? '/' : '/onboarding'),
    redirect: (BuildContext context, GoRouterState state) {
      final bool completed = StorageService.hasCompletedOnboarding();
      final bool isOnboarding = state.matchedLocation == '/onboarding';
      if (!completed && !isOnboarding) {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/dice', builder: (context, state) => const DiceScreen()),
      GoRoute(path: '/coin', builder: (context, state) => const CoinScreen()),
      GoRoute(
        path: '/teams',
        builder: (context, state) => const TeamGeneratorScreen(),
      ),
      GoRoute(
        path: '/scores',
        builder: (context, state) => const ScoreTrackerScreen(),
      ),
      GoRoute(
        path: '/cricket',
        builder: (context, state) => const CricketScreen(),
      ),
      GoRoute(
        path: '/spin',
        builder: (context, state) => const SpinWheelScreen(),
      ),
      GoRoute(
        path: '/tournament',
        builder: (context, state) => const TournamentScreen(),
      ),
      GoRoute(
        path: '/timers',
        builder: (context, state) => const TimerScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(path: '/terms', builder: (context, state) => const TermsScreen()),
      GoRoute(
        path: '/changelog',
        builder: (context, state) => const ChangelogScreen(),
      ),
    ],
  );
}

final GoRouter appRouter = createAppRouter();
