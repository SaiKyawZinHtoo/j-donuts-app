import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:j_donuts_app/core/di/service_locator.dart';
import 'package:j_donuts_app/main.dart';

void main() {
  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets('MyApp builds and shows the initial route', (tester) async {
    setupServiceLocator();
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
