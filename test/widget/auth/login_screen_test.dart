import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('entering a 5-digit phone number keeps Continue disabled', (tester) async {
    await tester.pumpWidget(makeTestableWidget(const PhoneScreen()));
    await tester.enterText(find.byType(AppTextField), '0912');
    await tester.pump();
    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('entering a valid phone number enables Continue', (tester) async {
    await tester.pumpWidget(makeTestableWidget(const PhoneScreen()));
    await tester.enterText(find.byType(AppTextField), '09123456789');
    await tester.pump();
    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(button.onPressed, isNotNull);
  });
}
