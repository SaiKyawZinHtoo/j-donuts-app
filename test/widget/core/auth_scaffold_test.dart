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

void main() {
  testWidgets('footer shown without inset, hidden with keyboard inset',
      (tester) async {
    await tester.pumpWidget(_app(const AuthScaffold(child: Text('x'))));
    expect(find.byType(AppLegalFooter), findsOneWidget);

    await tester.pumpWidget(_app(const AuthScaffold(child: Text('x')),
        inset: const EdgeInsets.only(bottom: 300)));
    expect(find.byType(AppLegalFooter), findsNothing);
  });

  testWidgets('AppBackButton pops to previous route', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('first'))),
      GoRoute(
          path: '/b',
          builder: (_, _) => const Scaffold(body: AppBackButton())),
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.push('/b');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
    expect(find.text('first'), findsOneWidget);
  });

  testWidgets('no overflow on 375x667 with keyboard and tall child',
      (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(
      AuthScaffold(
        child: Column(children: [
          for (var i = 0; i < 4; i++)
            const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: TextField()),
        ]),
      ),
      inset: const EdgeInsets.only(bottom: 300),
    ));
    expect(tester.takeException(), isNull);
  });
}
