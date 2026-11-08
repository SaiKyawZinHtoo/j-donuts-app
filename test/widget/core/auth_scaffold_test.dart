import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:j_donuts_app/core/core_import.dart';

Widget _app(Widget home, {EdgeInsets inset = EdgeInsets.zero}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(viewInsets: inset),
    child: child!,
  ),
);

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 667);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('footer shown without inset, hidden with keyboard inset', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const AuthScaffold(child: Text('x'))));
    expect(find.byType(AppLegalFooter), findsOneWidget);

    await tester.pumpWidget(
      _app(
        const AuthScaffold(child: Text('x')),
        inset: const EdgeInsets.only(bottom: 300),
      ),
    );
    expect(find.byType(AppLegalFooter), findsNothing);
  });

  testWidgets('tall child + keyboard: no overflow, scrolls, header stays', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(
      _app(
        AuthScaffold(
          child: Column(
            children: [
              for (var i = 0; i < 8; i++)
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: TextField(),
                ),
              const SizedBox(key: Key('last'), height: 700),
            ],
          ),
        ),
        inset: const EdgeInsets.only(bottom: 300),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(AppLegalFooter), findsNothing);
    expect(find.byType(AppBackButton), findsOneWidget);
    final lastTop = tester.getTopLeft(find.byKey(const Key('last'))).dy;
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
    await tester.pump();
    expect(
      tester.getTopLeft(find.byKey(const Key('last'))).dy,
      lessThan(lastTop),
    );
    expect(tester.getRect(find.byType(AppBackButton)).top, lessThan(100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('short child: header at top, footer at bottom', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app(const AuthScaffold(child: Text('x'))));
    expect(tester.getRect(find.byType(AppBackButton)).top, lessThan(100));
    final footer = tester.getRect(find.byType(AppLegalFooter));
    expect(footer.bottom, greaterThan(667 - 60));
    expect(footer.bottom, lessThanOrEqualTo(667));
  });

  testWidgets('trailing is top-right when showBack is false', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _app(
        const AuthScaffold(
          showBack: false,
          trailing: Text('skip', key: Key('trail')),
          child: Text('x'),
        ),
      ),
    );
    expect(find.byType(AppBackButton), findsNothing);
    expect(
      tester.getCenter(find.byKey(const Key('trail'))).dx,
      greaterThan(375 / 2),
    );
  });

  testWidgets('footer callbacks fire', (tester) async {
    var terms = 0, privacy = 0;
    await tester.pumpWidget(
      _app(
        AuthScaffold(
          child: const Text('x'),
          onTapTerms: () => terms++,
          onTapPrivacy: () => privacy++,
        ),
      ),
    );
    final rich = tester.widget<RichText>(
      find.descendant(
        of: find.byType(AppLegalFooter),
        matching: find.byType(RichText),
      ),
    );
    final taps = <VoidCallback>[];
    rich.text.visitChildren((s) {
      if (s is TextSpan && s.recognizer is TapGestureRecognizer) {
        taps.add((s.recognizer as TapGestureRecognizer).onTap!);
      }
      return true;
    });
    expect(taps, hasLength(2));
    for (final t in taps) {
      t();
    }
    expect([terms, privacy], [1, 1]);
  });

  testWidgets('AppBackButton pops to previous route', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('first')),
        ),
        GoRoute(
          path: '/b',
          builder: (_, _) => const Scaffold(body: AppBackButton()),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.push('/b');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
    expect(find.text('first'), findsOneWidget);
  });

  testWidgets('AppBackButton does not throw when it cannot pop', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: AppBackButton()),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AppBackButton), findsOneWidget);
  });

  testWidgets('AppBackButton onPressed override replaces pop', (tester) async {
    var called = 0;
    await tester.pumpWidget(
      _app(Scaffold(body: AppBackButton(onPressed: () => called++))),
    );
    await tester.tap(find.byType(AppBackButton));
    expect(called, 1);
  });

  testWidgets('bottom sits above footer; stays with keyboard, footer hides', (
    tester,
  ) async {
    _phone(tester);
    const bottom = SizedBox(key: Key('bot'), height: 56, width: 100);
    await tester.pumpWidget(
      _app(const AuthScaffold(bottom: bottom, child: Text('x'))),
    );
    expect(
      tester.getRect(find.byKey(const Key('bot'))).bottom,
      lessThanOrEqualTo(tester.getRect(find.byType(AppLegalFooter)).top),
    );
    await tester.pumpWidget(
      _app(
        const AuthScaffold(bottom: bottom, child: Text('x')),
        inset: const EdgeInsets.only(bottom: 300),
      ),
    );
    expect(find.byType(AppLegalFooter), findsNothing);
    expect(find.byKey(const Key('bot')), findsOneWidget);
    expect(tester.getRect(find.byKey(const Key('bot'))).bottom, lessThan(667));
  });
}
