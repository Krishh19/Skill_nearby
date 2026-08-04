import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories.dart';
import '../features/flows/flow_screens.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screens.dart';

GoRouter createRouter(SkillRepository repository) => GoRouter(
  initialLocation: repository.preferences.onboardingComplete
      ? '/nearby'
      : '/welcome',
  redirect: (context, state) {
    final onboardingPath =
        state.uri.path.startsWith('/welcome') ||
        state.uri.path.startsWith('/onboarding');
    if (!repository.preferences.onboardingComplete && !onboardingPath)
      return '/welcome';
    if (repository.preferences.onboardingComplete && onboardingPath)
      return '/nearby';
    return null;
  },
  routes: [
    GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
    GoRoute(
      path: '/onboarding/location',
      builder: (_, __) => const LocationScreen(),
    ),
    GoRoute(
      path: '/onboarding/profile',
      builder: (_, __) => const CreateProfileScreen(),
    ),
    GoRoute(
      path: '/onboarding/skills',
      builder: (_, __) => const SkillsScreen(),
    ),
    GoRoute(
      path: '/onboarding/preferences',
      builder: (_, __) => const PreferencesScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/nearby', builder: (_, __) => const NearbyScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/requests',
              builder: (_, __) => const RequestsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/messages',
              builder: (_, __) => const MessagesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/me', builder: (_, __) => const MyProfileScreen()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/profiles/:id',
      builder: (_, state) =>
          ProfileDetailScreen(profileId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/request/:id',
      builder: (_, state) =>
          RequestSwapScreen(profileId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/request-review/:id',
      builder: (_, state) =>
          RequestReviewScreen(profileId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/request-sent',
      builder: (_, __) => const RequestSentScreen(),
    ),
    GoRoute(
      path: '/chat/:id',
      builder: (_, state) => ChatScreen(profileId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/complete/:id',
      builder: (_, state) =>
          CompleteSwapScreen(requestId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/rating/:id',
      builder: (_, state) =>
          RatingScreen(requestId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/standing-offers',
      builder: (_, __) => const StandingOffersScreen(),
    ),
    GoRoute(path: '/safety', builder: (_, __) => const SafetyScreen()),
    GoRoute(
      path: '/offline-data',
      builder: (_, __) => const OfflineDataScreen(),
    ),
  ],
);

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.near_me_outlined),
          selectedIcon: Icon(Icons.near_me),
          label: 'Nearby',
        ),
        NavigationDestination(
          icon: Icon(Icons.swap_horiz_outlined),
          selectedIcon: Icon(Icons.swap_horiz),
          label: 'Requests',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: 'Messages',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    ),
  );
}
