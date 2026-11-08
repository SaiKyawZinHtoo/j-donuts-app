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
}
