import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';

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

/// Wraps [child] in a MaterialApp + BlocProvider so widget tests can pump a
/// bare screen. Supply [bloc] to control/seed AuthBloc state; otherwise a
/// bloc backed by a bare mock repository is created.
Widget makeTestableWidget(Widget child, {AuthBloc? bloc}) {
  return MaterialApp(
    onGenerateRoute: (settings) => MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(body: Center(child: Text(settings.name ?? ''))),
    ),
    home: BlocProvider<AuthBloc>.value(
      value: bloc ?? buildAuthBloc(),
      child: child,
    ),
  );
}
