import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/core/router/app_page_transitions.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';
import 'package:j_donuts_app/features/shell/shell_import.dart';

int landings = 0;

Widget _app({required bool reduce}) => MaterialApp.router(
  builder: (c, child) => MediaQuery(
    data: MediaQuery.of(c).copyWith(disableAnimations: reduce),
    child: child!,
  ),
  routerConfig: GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: '/',
        builder: (_, _) {
          landings++;
          return const Text('landed');
        },
      ),
    ],
  ),
);

void main() {
  setUp(() => landings = 0);

  testWidgets('reduce motion: skips animation and still leaves the splash', (
    t,
  ) async {
    await t.pumpWidget(_app(reduce: true));
    await t.pump();
    await t.pumpAndSettle();
    expect(find.text('landed'), findsOneWidget);
    expect(landings, 1);
  });

  testWidgets('animated: shows logo, then navigates once after hold+exit', (
    t,
  ) async {
    await t.pumpWidget(_app(reduce: false));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('landed'), findsNothing);
    await t.pump(const Duration(seconds: 3));
    await t.pumpAndSettle();
    await t.pump(const Duration(seconds: 3));
    expect(find.text('landed'), findsOneWidget);
    expect(landings, 1);
  });

  testWidgets(
    'animated: eight donuts burst around the logo, then handoff flag set',
    (t) async {
      await t.pumpWidget(_app(reduce: false));
      await t.pump(const Duration(milliseconds: 1500));
      expect(find.byType(Image), findsNWidgets(9)); // 8 donuts + logo
      expect(t.takeException(), isNull);
      await t.pump(const Duration(seconds: 3));
      await t.pumpAndSettle();
      expect(find.text('landed'), findsOneWidget);
      expect(OnboardingScreen.skipTileEntrance, isTrue);
      OnboardingScreen.skipTileEntrance = false;
    },
  );

  group('sharedAxisX', () {
    Future<Widget> build(WidgetTester t, {required bool reduce}) async {
      late Widget out;
      await t.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
              child: Builder(
                builder: (context) {
                  final page = AppPageTransitions.sharedAxisX<void>(
                    GoRouterState(
                      _FakeConfig(),
                      uri: Uri(path: '/x'),
                      matchedLocation: '/x',
                      pageKey: const ValueKey('x'),
                      fullPath: '/x',
                      pathParameters: const {},
                    ),
                    const Text('child'),
                  );
                  out = page.transitionsBuilder(
                    context,
                    const AlwaysStoppedAnimation(0.5),
                    const AlwaysStoppedAnimation(0),
                    page.child,
                  );
                  return out;
                },
              ),
            ),
          ),
        ),
      );
      return out;
    }

    testWidgets('reduce motion returns bare child', (t) async {
      final w = await build(t, reduce: true);
      expect(w, isA<Text>());
    });

    testWidgets('otherwise fades and slides by stepSlideOffset', (t) async {
      final w = await build(t, reduce: false);
      final fade = w as FadeTransition;
      final slide = fade.child! as SlideTransition;
      expect(fade.opacity.value, inExclusiveRange(0, 1));
      final width = t.view.physicalSize.width / t.view.devicePixelRatio;
      final dx = slide.position.value.dx;
      expect(dx, greaterThan(0));
      expect(dx, lessThan(AppSpacing.stepSlideOffset / width));
    });
  });
}

class _FakeConfig extends RouteConfiguration {
  _FakeConfig()
    : super(
        ValueNotifier(RoutingConfig(routes: const [])),
        navigatorKey: GlobalKey<NavigatorState>(),
      );
}
