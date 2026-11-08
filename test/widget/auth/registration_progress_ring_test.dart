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

  const ringSquare = Size.square(AppSpacing.ringSize);
  final paintFinder = find.byWidgetPredicate(
    (w) => w is CustomPaint && w.painter is RegistrationRingPainter,
  );

  testWidgets('ring and completed disc are ringSize square', (t) async {
    await t.pumpWidget(
      _host(const RegistrationProgressRing(step: RegistrationStep.otp)),
    );
    expect(t.getSize(paintFinder), ringSquare);
    await t.pumpWidget(
      _host(
        const RegistrationProgressRing(
          step: RegistrationStep.dob,
          completed: true,
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(t.getSize(find.byKey(const ValueKey('ring-done'))), ringSquare);
  });

  testWidgets('morphs from ring to check when completed', (t) async {
    Widget ring(bool done) => _host(
      RegistrationProgressRing(step: RegistrationStep.dob, completed: done),
    );
    await t.pumpWidget(ring(false));
    expect(paintFinder, findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
    await t.pumpWidget(ring(true));
    await t.pump(MotionTokens.kRingStepDuration ~/ 2);
    await t.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(paintFinder, findsNothing);
  });

  for (final c in [
    (RegistrationStep.otp, 0.25, 0.5),
    (RegistrationStep.name, 0.5, 0.75),
    (RegistrationStep.dob, 0.75, 1.0),
  ]) {
    testWidgets('animates ${c.$1.name} from ${c.$2} to ${c.$3}', (t) async {
      await t.pumpWidget(_host(RegistrationProgressRing(step: c.$1)));
      expect(_painter(t).progress, closeTo(c.$2, 1e-9));
      await t.pump(MotionTokens.kRingStepDuration ~/ 2);
      expect(_painter(t).progress, greaterThan(c.$2));
      expect(_painter(t).progress, lessThan(c.$3));
      await t.pumpAndSettle();
      expect(_painter(t).progress, closeTo(c.$3, 1e-9));
      expect(find.byIcon(Icons.check), findsNothing);
    });
  }

  testWidgets('semantics announce progress and completion', (t) async {
    await t.pumpWidget(
      _host(
        const RegistrationProgressRing(step: RegistrationStep.otp),
        disableAnimations: true,
      ),
    );
    expect(
      t.getSemantics(find.byType(RegistrationProgressRing)).value,
      '50%',
    );
    expect(find.bySemanticsLabel('Registration progress'), findsOneWidget);
    await t.pumpWidget(
      _host(
        const RegistrationProgressRing(
          step: RegistrationStep.dob,
          completed: true,
        ),
        disableAnimations: true,
      ),
    );
    expect(find.bySemanticsLabel('Registration complete'), findsOneWidget);
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

  testWidgets('reduce motion: completed check on first frame', (t) async {
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
