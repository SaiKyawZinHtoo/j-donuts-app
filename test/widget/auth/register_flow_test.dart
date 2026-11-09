import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/core/core_import.dart' show AppOtpBox;
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('3 wrong OTP codes locks entry', (tester) async {
    final repo = MockAuthRepository();
    when(() => repo.checkPhone(any()))
        .thenAnswer((_) async => const Result.ok(false));
    final bloc = buildAuthBloc(repository: repo);
    bloc.add(const PhoneSubmitted('09123456789'));
    await tester.pumpWidget(makeTestableWidget(const OtpScreen(), bloc: bloc));
    await tester.pump();
    await tester.pump();

    // Each attempt uses a different wrong digit: entering the same value
    // again would not change the TextField's text, so no onChanged fires.
    Future<void> enterWrongCode(String digit) async {
      final fields = find.byType(TextField);
      // Clear first: once all 6 boxes hold text, editing one in place would
      // re-trigger completion on every intermediate (mixed-digit) state.
      for (var i = 0; i < 6; i++) {
        await tester.enterText(fields.at(i), '');
      }
      await tester.pump();
      for (var i = 0; i < 6; i++) {
        await tester.enterText(fields.at(i), digit);
      }
      await tester.pump();
    }

    await enterWrongCode('0');
    expect(bloc.state, isA<OtpInvalid>());
    await enterWrongCode('1');
    expect(bloc.state, isA<OtpInvalid>());
    await enterWrongCode('2');
    expect(bloc.state, isA<OtpLocked>());

    await tester.pump();
    expect(
      find.text('Too many attempts. Please resend the code.'),
      findsOneWidget,
    );

    bloc.close();
  });

  testWidgets('wrong OTP code shakes the boxes sideways then settles', (
    tester,
  ) async {
    final repo = MockAuthRepository();
    when(() => repo.checkPhone(any()))
        .thenAnswer((_) async => const Result.ok(false));
    final bloc = buildAuthBloc(repository: repo);
    bloc.add(const PhoneSubmitted('09123456789'));
    await tester.pumpWidget(makeTestableWidget(const OtpScreen(), bloc: bloc));
    await tester.pump();
    await tester.pump();

    final fields = find.byType(TextField);
    for (var i = 0; i < 6; i++) {
      await tester.enterText(fields.at(i), '0');
    }
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    double dx() => tester
        .widgetList<Transform>(
          find.ancestor(
            of: find.byType(AppOtpBox),
            matching: find.byType(Transform),
          ),
        )
        .map((t) => t.transform.getTranslation().x)
        .fold<double>(0, (a, b) => a.abs() > b.abs() ? a : b);
    expect(dx().abs(), greaterThan(0));
    await tester.pump(const Duration(seconds: 1));
    expect(dx(), 0);
    await tester.pumpWidget(const SizedBox());
    bloc.close(); // cancels the OTP countdown timer
    await tester.pump();
  });
}
