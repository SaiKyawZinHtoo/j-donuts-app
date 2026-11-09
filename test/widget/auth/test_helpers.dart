import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';
import 'package:j_donuts_app/l10n/app_localizations.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

/// Builds an [AuthBloc] backed by a mock [AuthRepository] whose calls never
/// resolve within a test's lifetime unless the test itself stubs them —
/// enough for screens that only need the bloc's initial state.
AuthBloc buildAuthBloc({AuthRepository? repository}) {
  final repo = repository ?? MockAuthRepository();
  return AuthBloc(
    loginUseCase: LoginUseCase(repo),
    registerUseCase: RegisterUseCase(repo),
    getSessionUseCase: GetSessionUseCase(repo),
    authRepository: repo,
  );
}

/// Wraps [child] in a `MaterialApp.router` (the screens navigate via
/// go_router's `context.go`/`context.push`) plus a [BlocProvider], so widget
/// tests can pump a bare screen. Supply [bloc] to control/seed AuthBloc
/// state; otherwise a bloc backed by a bare mock repository is created.
Widget makeTestableWidget(Widget child, {AuthBloc? bloc}) {
  final router = GoRouter(
    initialLocation: '/__test__',
    routes: [
      GoRoute(path: '/__test__', builder: (context, state) => child),
      for (final path in const [
        '/phone',
        '/otp',
        '/name',
        '/dob',
        '/welcome',
        '/home',
      ])
        GoRoute(
          path: path,
          builder: (context, state) =>
              Scaffold(body: Center(child: Text(path))),
        ),
    ],
  );
  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, routerChild) => BlocProvider<AuthBloc>.value(
      value: bloc ?? buildAuthBloc(),
      child: routerChild!,
    ),
  );
}
