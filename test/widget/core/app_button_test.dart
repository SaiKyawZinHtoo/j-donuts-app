import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/core_import.dart';

Widget _app(Widget body) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: body),
);

void main() {
  testWidgets('disabled button uses primaryDisabled', (tester) async {
    await tester.pumpWidget(
      _app(const AppButton(label: 'go', onPressed: null)),
    );
    final style = tester
        .widget<ElevatedButton>(find.byType(ElevatedButton))
        .style!;
    expect(
      style.backgroundColor!.resolve({WidgetState.disabled}),
      AppColors.primaryDisabled,
    );
  });

  testWidgets('press scales via Listener to 0.97 and back', (tester) async {
    await tester.pumpWidget(_app(AppButton(label: 'go', onPressed: () {})));
    double scale() =>
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;
    expect(scale(), 1.0);
    final g = await tester.startGesture(
      tester.getCenter(find.byType(AppButton)),
    );
    await tester.pump();
    expect(scale(), 0.97);
    await g.up();
    await tester.pump();
    expect(scale(), 1.0);
  });

  testWidgets('loading shows spinner, hides label, keeps full width', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Center(
          child: SizedBox(
            width: 300,
            child: Column(
              children: [
                AppButton(label: 'go', onPressed: () {}, loading: true),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(MotionTokens.kButtonMorphDuration);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('GO'), findsNothing);
    expect(tester.getSize(find.byType(ElevatedButton)).width, 300);
  });

  testWidgets('fills bounded width in a Column', (tester) async {
    await tester.pumpWidget(
      _app(
        Center(
          child: SizedBox(
            width: 300,
            child: Column(
              children: [AppButton(label: 'go', onPressed: () {})],
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(ElevatedButton)).width, 300);
  });

  testWidgets('inside a Row does not throw', (tester) async {
    await tester.pumpWidget(
      _app(
        Row(
          children: [AppButton(label: 'go', onPressed: () {})],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('GO'), findsOneWidget);
  });

  Color material(WidgetTester t) => t
      .widget<Material>(
        find
            .descendant(
              of: find.byType(ElevatedButton),
              matching: find.byType(Material),
            )
            .first,
      )
      .color!;
  double scale(WidgetTester t) =>
      t.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

  testWidgets('rendered colors: loading primary, disabled primaryDisabled', (
    t,
  ) async {
    await t.pumpWidget(
      _app(AppButton(label: 'go', onPressed: () {}, loading: true)),
    );
    await t.pump(MotionTokens.kButtonMorphDuration * 2);
    expect(material(t), AppColors.primary);
    await t.pumpWidget(_app(const AppButton(label: 'go', onPressed: null)));
    await t.pump(MotionTokens.kButtonMorphDuration * 2);
    expect(material(t), AppColors.primaryDisabled);
  });

  testWidgets('tap on loading button does not call onPressed', (t) async {
    var n = 0;
    await t.pumpWidget(
      _app(AppButton(label: 'go', onPressed: () => n++, loading: true)),
    );
    await t.tap(find.byType(AppButton));
    expect(n, 0);
  });

  testWidgets('label exposed to semantics in both states', (t) async {
    for (final loading in [false, true]) {
      await t.pumpWidget(
        _app(AppButton(label: 'go', onPressed: () {}, loading: loading)),
      );
      await t.pump(MotionTokens.kButtonMorphDuration * 2);
      expect(t.getSemantics(find.byType(ElevatedButton)).label, 'go');
    }
  });

  testWidgets('reduce motion: instant scale and zero morph', (t) async {
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: AppButton(label: 'go', onPressed: () {}),
          ),
        ),
      ),
    );
    expect(
      t.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
      Duration.zero,
    );
    expect(
      t.widget<AnimatedScale>(find.byType(AnimatedScale)).duration,
      Duration.zero,
    );
    final g = await t.startGesture(t.getCenter(find.byType(AppButton)));
    await t.pump();
    expect(scale(t), 0.97);
    await g.up();
  });

  testWidgets('disabled and loading do not scale', (t) async {
    for (final b in [
      const AppButton(label: 'go', onPressed: null),
      AppButton(label: 'go', onPressed: () {}, loading: true),
    ]) {
      await t.pumpWidget(_app(b));
      final g = await t.startGesture(t.getCenter(find.byType(AppButton)));
      await t.pump();
      expect(scale(t), 1.0);
      await g.up();
    }
  });

  testWidgets('pointer cancel resets scale', (t) async {
    await t.pumpWidget(_app(AppButton(label: 'go', onPressed: () {})));
    final g = await t.startGesture(t.getCenter(find.byType(AppButton)));
    await t.pump();
    expect(scale(t), 0.97);
    await g.cancel();
    await t.pump();
    expect(scale(t), 1.0);
  });

  testWidgets('trailingLabel renders label and total separately', (tester) async {
    await tester.pumpWidget(
      _app(AppButton(label: 'Add', trailingLabel: '1,500 MMK', onPressed: () {})),
    );
    expect(find.text('ADD'), findsOneWidget);
    expect(find.text('1,500 MMK'), findsOneWidget);
  });
}
