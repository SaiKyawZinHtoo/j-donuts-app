import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:get_it/get_it.dart';

import 'package:j_donuts_app/core/di/service_locator.dart';
import 'package:j_donuts_app/data/local/database.dart';
import 'package:j_donuts_app/main.dart';

/// In-memory stand-in so the router's session check doesn't hit a real
/// secure-storage platform channel (unavailable in widget tests).
class _FakeSecureStorage extends FlutterSecureStoragePlatform {
  @override
  Future<void> write({
    required String key,
    required String? value,
    required Map<String, String> options,
  }) async {}

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async =>
      null;

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {}

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async =>
      false;

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {}

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async =>
      {};
}

void main() {
  tearDown(() async {
    if (GetIt.instance.isRegistered<AppDatabase>()) {
      await GetIt.instance<AppDatabase>().close();
    }
    await GetIt.instance.reset();
  });

  testWidgets('MyApp builds and shows the initial route', (tester) async {
    FlutterSecureStoragePlatform.instance = _FakeSecureStorage();
    setupServiceLocator();
    // Swap the real (file-backed) database for an in-memory one so the
    // router's session check doesn't spin up native sqlite in this test.
    GetIt.instance.unregister<AppDatabase>();
    GetIt.instance.registerLazySingleton<AppDatabase>(
      () => AppDatabase.forTesting(NativeDatabase.memory()),
    );
    await tester.pumpWidget(const MyApp());
    // The router's redirect awaits GetSessionUseCase, which includes a fake
    // ~1s network delay -- advance the fake clock past it before settling.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
