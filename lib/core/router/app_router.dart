import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_import.dart';
import '../../features/home/home_import.dart';
import '../../features/product/product_import.dart';
import '../../features/rewards/rewards_import.dart';
import '../../features/shell/shell_import.dart';
import '../result/result.dart';

/// Routes reachable before/while a user authenticates.
const _authRoutes = {
  '/',
  '/onboarding',
  '/phone',
  '/otp',
  '/name',
  '/dob',
  '/welcome',
};

/// Generic placeholder for a route whose real screen is built in a later
/// feature task. Routes are infrastructure; screens arrive feature by feature.
class _RoutePlaceholderScreen extends PlaceholderTabScreen {
  const _RoutePlaceholderScreen({required super.label});
}

/// Shared by the `/home` and `/rewards` routes: same shell, different
/// starting tab.
AppShellScreen _buildShell({required int initialIndex}) => AppShellScreen(
  homeTab: BlocProvider<HomeBloc>(
    create: (_) => GetIt.instance<HomeBloc>()..add(const HomeRequested()),
    child: const HomeScreen(),
  ),
  rewardsTab: BlocProvider<RewardsBloc>(
    create: (_) => GetIt.instance<RewardsBloc>()..add(const RewardsRequested()),
    child: const RewardsScreen(),
  ),
  initialIndex: initialIndex,
);

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final result = await GetIt.instance<GetSessionUseCase>().call();
    final hasSession = result is Ok<AuthUser?> && result.value != null;
    final isAuthRoute = _authRoutes.contains(state.matchedLocation);

    if (!hasSession && !isAuthRoute) return '/onboarding';
    if (hasSession && isAuthRoute) return '/home';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          const _RoutePlaceholderScreen(label: 'Splash'),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) =>
          const _RoutePlaceholderScreen(label: 'Onboarding'),
    ),
    GoRoute(
      path: '/phone',
      builder: (context, state) =>
          const _RoutePlaceholderScreen(label: 'Phone'),
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
      builder: (context, state) =>
          const _RoutePlaceholderScreen(label: 'Date of birth'),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) =>
          const _RoutePlaceholderScreen(label: 'Welcome'),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) =>
          _buildShell(initialIndex: AppShellScreen.homeIndex),
    ),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductDetailScreen(productId: id);
      },
    ),
    GoRoute(
      path: '/rewards',
      builder: (context, state) =>
          _buildShell(initialIndex: AppShellScreen.rewardsIndex),
    ),
  ],
);
