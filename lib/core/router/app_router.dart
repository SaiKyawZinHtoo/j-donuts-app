import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:j_donuts_app/features/auth/auth_import.dart';
import 'package:j_donuts_app/features/home/home_import.dart';
import 'package:j_donuts_app/features/product/product_import.dart';
import 'package:j_donuts_app/features/rewards/rewards_import.dart';
import 'package:j_donuts_app/features/shell/shell_import.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/core/router/app_page_transitions.dart';

/// Routes reachable before/while a user authenticates.
const _authRoutes = {
  '/onboarding',
  '/phone',
  '/otp',
  '/name',
  '/dob',
  '/welcome',
};

/// Shared by the `/home` and `/rewards` routes: same shell, different
/// starting tab.
AppShellScreen _buildShell({required int initialIndex}) => AppShellScreen(
  homeTab: BlocProvider<HomeBloc>(
    create: (_) => GetIt.instance<HomeBloc>()..add(const HomeRequested()),
    child: const HomeScreen(),
  ),
  rewardsTab: (isActive) => BlocProvider<RewardsBloc>(
    create: (_) => GetIt.instance<RewardsBloc>()..add(const RewardsRequested()),
    child: RewardsScreen(isActive: isActive),
  ),
  initialIndex: initialIndex,
);

final GoRouter appRouter = createAppRouter();

GoRouter createAppRouter() => GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    if (state.matchedLocation == '/splash') return null;
    final result = await GetIt.instance<GetSessionUseCase>().call();
    final hasSession = result is Ok<AuthUser?> && result.value != null;
    final isAuthRoute = _authRoutes.contains(state.matchedLocation);

    if (state.matchedLocation == '/') {
      return hasSession ? '/home' : '/onboarding';
    }
    if (!hasSession && !isAuthRoute) return '/onboarding';
    if (hasSession && isAuthRoute && state.matchedLocation != '/welcome') {
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    ShellRoute(
      builder: (context, state, child) => BlocProvider<AuthBloc>(
        create: (_) => GetIt.instance<AuthBloc>(),
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/phone',
          pageBuilder: (context, state) => AppPageTransitions.sharedAxisX(
            state,
            PhoneScreen(isLogin: state.extra == 'login'),
            reduceMotion: MediaQuery.disableAnimationsOf(context),
          ),
        ),
        GoRoute(
          path: '/otp',
          pageBuilder: (context, state) => AppPageTransitions.sharedAxisX(
            state,
            const OtpScreen(),
            reduceMotion: MediaQuery.disableAnimationsOf(context),
          ),
        ),
        GoRoute(
          path: '/name',
          pageBuilder: (context, state) => AppPageTransitions.sharedAxisX(
            state,
            const NameScreen(),
            reduceMotion: MediaQuery.disableAnimationsOf(context),
          ),
        ),
        GoRoute(
          path: '/dob',
          pageBuilder: (context, state) => AppPageTransitions.sharedAxisX(
            state,
            const DobScreen(),
            reduceMotion: MediaQuery.disableAnimationsOf(context),
          ),
        ),
        GoRoute(
          path: '/welcome',
          pageBuilder: (context, state) => AppPageTransitions.sharedAxisX(
            state,
            const WelcomeScreen(),
            reduceMotion: MediaQuery.disableAnimationsOf(context),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) =>
          _buildShell(initialIndex: AppShellScreen.homeIndex),
    ),
    GoRoute(
      path: '/product/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        final extra = state.extra;
        // CupertinoPage (not CustomTransitionPage) keeps the iOS edge-swipe back.
        return CupertinoPage<void>(
          key: state.pageKey,
          child: ProductDetailScreen(
            productId: id,
            heroTag: extra is String ? extra : null,
          ),
        );
      },
    ),
    GoRoute(
      path: '/rewards',
      builder: (context, state) =>
          _buildShell(initialIndex: AppShellScreen.rewardsIndex),
    ),
  ],
);
