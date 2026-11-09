import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:drift/native.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/data/local/daos/auth_dao.dart';
import 'package:j_donuts_app/data/local/database.dart' hide AuthUser;
import 'package:j_donuts_app/features/auth/auth_import.dart';

class FakeSecureStorage extends FlutterSecureStoragePlatform {
  final Map<String, String> _store = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    required Map<String, String> options,
  }) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async => _store[key];

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    _store.remove(key);
  }

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async => _store.containsKey(key);

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    _store.clear();
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async => Map.of(_store);
}

void main() {
  late AppDatabase db;
  late FakeAuthRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    FlutterSecureStoragePlatform.instance = FakeSecureStorage();
    repo = FakeAuthRepositoryImpl(
      localDataSource: AuthLocalDataSource(AuthDao(db)),
      sessionDataSource: const SessionDataSource(FlutterSecureStorage()),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('login returns Err for an unregistered phone', () async {
    final result = await repo.login('+959000000000');
    expect(result, isA<Err<AuthUser>>());
  }, timeout: const Timeout(Duration(seconds: 5)));

  test(
    'completeRegistration persists the user and saves the session',
    () async {
      final result = await repo.completeRegistration(
        phone: '+959111111111',
        firstName: 'Shan',
        dob: DateTime(1999, 5, 1),
      );
      expect(result, isA<Ok<AuthUser>>());

      final session = await repo.getSession();
      expect(session, isA<Ok<AuthUser?>>());
      expect((session as Ok<AuthUser?>).value?.phone, '+959111111111');

      final login = await repo.login('+959111111111');
      expect(login, isA<Ok<AuthUser>>());
    },
    timeout: const Timeout(Duration(seconds: 5)),
  );

  test('logout clears the session', () async {
    await repo.completeRegistration(
      phone: '+959222222222',
      firstName: 'Lin',
      dob: DateTime(1998, 3, 3),
    );
    await repo.logout();
    final session = await repo.getSession();
    expect((session as Ok<AuthUser?>).value, isNull);
  }, timeout: const Timeout(Duration(seconds: 5)));
}
