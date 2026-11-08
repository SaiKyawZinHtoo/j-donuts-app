import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:j_donuts_app/core/di/service_locator.dart';
import 'package:j_donuts_app/data/local/database.dart';

void main() {
  tearDown(() async {
    if (GetIt.instance.isRegistered<AppDatabase>()) {
      await GetIt.instance<AppDatabase>().close();
    }
    await GetIt.instance.reset();
  });

  test('service locator registers AppDatabase as a singleton', () {
    setupServiceLocator();
    final a = GetIt.instance<AppDatabase>();
    final b = GetIt.instance<AppDatabase>();
    expect(identical(a, b), isTrue);
  });
}
