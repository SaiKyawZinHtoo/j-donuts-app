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

  testWidgets('only active label visible', (t) async {
    await t.pumpWidget(_host(1, (_) {}));
    double opacity(String l) => t
        .widget<Opacity>(find.ancestor(
            of: find.text(l), matching: find.byType(Opacity)))
        .opacity;
    expect(opacity('Rewards'), 1);
    expect(opacity('Home'), 0);
    expect(opacity('Explore'), 0);
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
      t.getSemantics(find.bySemanticsLabel('Rewards')),
      matchesSemantics(
        label: 'Rewards',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    h.dispose();
  });

  testWidgets('active label sits to the right of its icon', (t) async {
    await t.pumpWidget(_host(0, (_) {}));
    expect(
      t.getTopLeft(find.text('Home')).dx,
      greaterThan(t.getTopRight(find.byIcon(Icons.home_outlined)).dx - 1),
    );
  });

  testWidgets('switching tabs mid-animation never overflows', (t) async {
    await t.pumpWidget(_host(0, (_) {}));
    await t.pumpWidget(_host(3, (_) {}));
    for (var i = 0; i < 10; i++) {
      await t.pump(MotionTokens.kNavPillDuration ~/ 10);
    }
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.text('Wallet'), findsOneWidget);
  });
}
