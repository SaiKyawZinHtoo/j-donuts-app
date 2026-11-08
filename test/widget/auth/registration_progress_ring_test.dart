import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';

Widget _host(Widget child, {bool disableAnimations = false}) => MediaQuery(
  data: MediaQueryData(disableAnimations: disableAnimations),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: child),
  ),
);

RegistrationRingPainter _painter(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((p) => p.painter)
    .whereType<RegistrationRingPainter>()
    .single;

void main() {
  test('progressFor maps steps to fractions', () {
    expect(RegistrationProgressRing.progressFor(RegistrationStep.phone), 0.25);
    expect(RegistrationProgressRing.progressFor(RegistrationStep.otp), 0.5);
    expect(RegistrationProgressRing.progressFor(RegistrationStep.name), 0.75);
    expect(RegistrationProgressRing.progressFor(RegistrationStep.dob), 1.0);
  });

  testWidgets('animates from previous step fraction to current', (t) async {
    await t.pumpWidget(
      _host(const RegistrationProgressRing(step: RegistrationStep.otp)),
    );
    expect(_painter(t).progress, closeTo(0.25, 1e-9));
    await t.pump(MotionTokens.kRingStepDuration);
    expect(_painter(t).progress, closeTo(0.5, 1e-9));
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('phone step starts from 0', (t) async {
    await t.pumpWidget(
      _host(const RegistrationProgressRing(step: RegistrationStep.phone)),
    );
    expect(_painter(t).progress, 0);
    await t.pump(MotionTokens.kRingStepDuration);
    expect(_painter(t).progress, closeTo(0.25, 1e-9));
  });

  testWidgets('uses ring tokens and size', (t) async {
    await t.pumpWidget(
      _host(
        const RegistrationProgressRing(step: RegistrationStep.name),
        disableAnimations: true,
      ),
    );
    final p = _painter(t);
    expect(p.trackColor, AppColors.ringCyan);
    expect(p.progressColor, AppColors.ringPink);
    expect(
      t.getSize(find.byType(RegistrationProgressRing)),
      const Size.square(AppSpacing.ringSize),
    );
  });

  testWidgets('completed morphs to check', (t) async {
    await t.pumpWidget(
      _host(
        const RegistrationProgressRing(
          step: RegistrationStep.dob,
          completed: true,
        ),
      ),
    );
    await t.pump(MotionTokens.kRingStepDuration);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('disableAnimations shows final state on first frame', (t) async {
    await t.pumpWidget(
      _host(
        const RegistrationProgressRing(step: RegistrationStep.otp),
        disableAnimations: true,
      ),
    );
    expect(_painter(t).progress, 0.5);
    await t.pumpWidget(
      _host(
        const RegistrationProgressRing(
          step: RegistrationStep.dob,
          completed: true,
        ),
        disableAnimations: true,
      ),
    );
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
