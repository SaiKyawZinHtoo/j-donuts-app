import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/core_import.dart';

Widget _host(int index, ValueChanged<int> onTap, {bool reduce = false}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: reduce),
    child: MaterialApp(
      home: Scaffold(
        bottomNavigationBar: AppBottomNav(currentIndex: index, onTap: onTap),
      ),
    ),
  );
}

double _pillX(WidgetTester t) =>
    t.getTopLeft(find.byKey(const Key('navPill'))).dx;

void main() {
  testWidgets('tap item 2 calls onTap(2)', (t) async {
    int? tapped;
    await t.pumpWidget(_host(0, (i) => tapped = i));
    await t.tap(find.byIcon(Icons.radio_button_checked));
    expect(tapped, 2);
  });

  testWidgets('slot icons: home first, crown second', (t) async {
    await t.pumpWidget(_host(0, (_) {}));
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.workspace_premium_outlined), findsOneWidget);
  });

  testWidgets('pill slides monotonically between slots', (t) async {
    await t.pumpWidget(_host(0, (_) {}));
    final start = _pillX(t);
    await t.pumpWidget(_host(2, (_) {}));
    await t.pump(MotionTokens.kNavPillDuration ~/ 2);
    final mid = _pillX(t);
    await t.pumpAndSettle();
    final end = _pillX(t);
    expect(end, greaterThan(start));
    expect(mid, greaterThan(start));
    expect(mid, lessThan(end));
  });

  testWidgets('only active label shown', (t) async {
    await t.pumpWidget(_host(1, (_) {}));
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Rewards'), findsNothing);
  });

  testWidgets('disableAnimations: pill final on first frame', (t) async {
    await t.pumpWidget(_host(0, (_) {}, reduce: true));
    final start = _pillX(t);
    await t.pumpWidget(_host(2, (_) {}, reduce: true));
    await t.pump();
    final end = _pillX(t);
    expect(end, greaterThan(start));
    await t.pumpAndSettle();
    expect(_pillX(t), end);
  });

  testWidgets('semantics selected on active item', (t) async {
    final h = t.ensureSemantics();
    await t.pumpWidget(_host(1, (_) {}));
    expect(
      t.getSemantics(find.bySemanticsLabel('Explore')),
      matchesSemantics(
        label: 'Explore',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    h.dispose();
  });
}
