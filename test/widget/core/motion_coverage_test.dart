import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/core_import.dart';

Widget _app(Widget child, {required bool reduce}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduce),
    child: Scaffold(body: child),
  ),
);

void main() {
  testWidgets('AppEmptyState fades in normally', (tester) async {
    await tester.pumpWidget(
      _app(const AppEmptyState(message: 'x'), reduce: false),
    );
    expect(
      tester.widget<Opacity>(find.byType(Opacity).first).opacity,
      lessThan(1),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, 1);
  });

  testWidgets('AppEmptyState is instantly opaque under Reduce Motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const AppEmptyState(message: 'x'), reduce: true),
    );
    expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, 1);
  });
}
