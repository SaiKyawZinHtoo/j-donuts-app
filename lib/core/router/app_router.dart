import 'package:go_router/go_router.dart';

import '../../features/shell/shell_import.dart';

/// Generic placeholder for a route whose real screen is built in a later
/// feature task. Routes are infrastructure; screens arrive feature by feature.
class _RoutePlaceholderScreen extends PlaceholderTabScreen {
  const _RoutePlaceholderScreen({required super.label});
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // STUB: the real session check depends on AuthRepository/GetSessionUseCase,
    // built in Tasks 3-4. Task 4 Step 7 wires this guard for real. For now,
    // never redirect.
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const _RoutePlaceholderScreen(label: 'Splash'),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const _RoutePlaceholderScreen(label: 'Onboarding'),
    ),
    GoRoute(
      path: '/phone',
      builder: (context, state) => const _RoutePlaceholderScreen(label: 'Phone'),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => const _RoutePlaceholderScreen(label: 'OTP'),
    ),
    GoRoute(
      path: '/name',
      builder: (context, state) => const _RoutePlaceholderScreen(label: 'Name'),
    ),
    GoRoute(
      path: '/dob',
      builder: (context, state) => const _RoutePlaceholderScreen(label: 'Date of birth'),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const _RoutePlaceholderScreen(label: 'Welcome'),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => AppShellScreen(
        homeTab: const _RoutePlaceholderScreen(label: 'Home'),
        rewardsTab: const _RoutePlaceholderScreen(label: 'Rewards'),
      ),
    ),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return _RoutePlaceholderScreen(label: 'Product $id');
      },
    ),
    GoRoute(
      path: '/rewards',
      builder: (context, state) => AppShellScreen(
        homeTab: const _RoutePlaceholderScreen(label: 'Home'),
        rewardsTab: const _RoutePlaceholderScreen(label: 'Rewards'),
      ),
    ),
  ],
);
