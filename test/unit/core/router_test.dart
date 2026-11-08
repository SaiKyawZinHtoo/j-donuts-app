import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/core/di/service_locator.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/core/router/app_router.dart';
import 'package:j_donuts_app/data/local/database.dart' hide AuthUser;
import 'package:j_donuts_app/features/auth/auth_import.dart';

class _Session extends GetSessionUseCase {
  final AuthUser? user;
  _Session(this.user) : super(_NoRepo());
  @override
  Future<Result<AuthUser?>> call() async => Ok(user);
}

class _NoRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _FakeStorage extends FlutterSecureStoragePlatform {
  @override
  dynamic noSuchMethod(Invocation i) async => null;
}

Future<void> _boot(WidgetTester t, AuthUser? user) async {
  FlutterSecureStoragePlatform.instance = _FakeStorage();
  setupServiceLocator();
  GetIt.instance.unregister<AppDatabase>();
  GetIt.instance.registerLazySingleton<AppDatabase>(
    () => AppDatabase.forTesting(NativeDatabase.memory()),
  );
  GetIt.instance.unregister<GetSessionUseCase>();
  GetIt.instance.registerSingleton<GetSessionUseCase>(_Session(user));
  await t.pumpWidget(
    MaterialApp.router(
      routerConfig: createAppRouter(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  tearDown(() async {
    if (GetIt.instance.isRegistered<AppDatabase>()) {
      await GetIt.instance<AppDatabase>().close();
    }
    await GetIt.instance.reset();
  });

  testWidgets('no session: splash then onboarding', (t) async {
    await _boot(t, null);
    await t.pump(const Duration(seconds: 3));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('getStartedButton')), findsOneWidget);
  });

  testWidgets('session: splash straight to home, onboarding never shown', (
    t,
  ) async {
    await _boot(
      t,
      AuthUser(id: '1', phone: '1', firstName: 'A', dob: DateTime(2000)),
    );
    var sawOnboarding = false;
    for (var i = 0; i < 300; i++) {
      await t.pump(const Duration(milliseconds: 20));
      sawOnboarding |= find
          .byKey(const Key('getStartedButton'))
          .evaluate()
          .isNotEmpty;
    }
    expect(sawOnboarding, isFalse);
    expect(find.byKey(const Key('homeScreen')), findsOneWidget);
  });
}
