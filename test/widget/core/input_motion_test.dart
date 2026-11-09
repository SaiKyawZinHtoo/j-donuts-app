import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/core_import.dart';

Widget _otp({String? error, bool reduce = false}) => MaterialApp(
  theme: AppTheme.light,
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduce),
    child: Scaffold(
      body: AppOtpBox(length: 6, onCompleted: (_) {}, errorText: error),
    ),
  ),
);

Color _borderColor(WidgetTester t) {
  final field = t.widget<TextField>(find.byType(TextField).first);
  final b = field.decoration!.enabledBorder! as OutlineInputBorder;
  return b.borderSide.color;
}

void main() {
  testWidgets('OTP box border eases to the error colour, not a jump', (
    t,
  ) async {
    await t.pumpWidget(_otp());
    expect(_borderColor(t), AppColors.border);
    await t.pumpWidget(_otp(error: 'Wrong code'));
    await t.pump(MotionTokens.kFieldStateDuration ~/ 2);
    final mid = _borderColor(t);
    expect(mid, isNot(AppColors.border));
    expect(mid, isNot(AppColors.error));
    await t.pumpAndSettle();
    expect(_borderColor(t), AppColors.error);
  });

  testWidgets('OTP error text fades in and out', (t) async {
    await t.pumpWidget(_otp());
    expect(find.text('Wrong code'), findsNothing);
    await t.pumpWidget(_otp(error: 'Wrong code'));
    await t.pump(MotionTokens.kFieldStateDuration ~/ 2);
    expect(find.byType(AnimatedSwitcher), findsOneWidget);
    await t.pumpAndSettle();
    expect(find.text('Wrong code'), findsOneWidget);
  });

  testWidgets('OTP error is instant under Reduce Motion', (t) async {
    await t.pumpWidget(_otp(reduce: true));
    await t.pumpWidget(_otp(error: 'Wrong code', reduce: true));
    await t.pump();
    expect(_borderColor(t), AppColors.error);
  });

  testWidgets('text field border changes colour smoothly on focus', (t) async {
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: AppTextField(controller: TextEditingController())),
      ),
    );
    await t.tap(find.byType(TextField));
    await t.pump(const Duration(milliseconds: 40));
    final inDecorator = find.byType(InputDecorator);
    expect(inDecorator, findsOneWidget);
    await t.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
  });
}
