import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';

import 'test_helpers.dart';

void main() {
  const screens = <String, (Widget, String)>{
    'phone': (PhoneScreen(), 'phoneNumberField'),
    'login': (PhoneScreen(isLogin: true), 'phoneNumberField'),
    'name': (NameScreen(), 'firstNameField'),
    'dob': (DobScreen(), 'dobMonthField'),
  };

  for (final e in screens.entries) {
    final (screen, fieldKey) = e.value;
    testWidgets('${e.key}: continue pinned low, field above it', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(makeTestableWidget(screen));
      await tester.pumpAndSettle();
      final btn = tester.getRect(find.byKey(const Key('continueButton')));
      expect(btn.bottom, greaterThan(0.7 * 667));
      expect(
        tester.getRect(find.byKey(Key(fieldKey))).bottom,
        lessThan(btn.top),
      );

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      final kb = tester.getRect(find.byKey(const Key('continueButton')));
      expect(kb.bottom, lessThanOrEqualTo(667 - 300));
      expect(kb.top, greaterThanOrEqualTo(0));
    });
  }

  testWidgets('phone hint is a light placeholder color', (tester) async {
    await tester.pumpWidget(makeTestableWidget(const PhoneScreen()));
    final f = tester.widget<TextField>(find.byType(TextField));
    expect(f.decoration!.hintStyle!.color, AppColors.hint);
    expect(AppColors.hint.a, lessThan(1));
    expect(f.style!.color, AppColors.textPrimary);
  });
}
