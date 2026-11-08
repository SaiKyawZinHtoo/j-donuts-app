import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';

import 'test_helpers.dart';

Widget _app({bool disableAnimations = false, double textScale = 1.0}) =>
    MediaQuery(
      data: MediaQueryData(
        size: const Size(375, 667),
        disableAnimations: disableAnimations,
        textScaler: TextScaler.linear(textScale),
      ),
      child: makeTestableWidget(const OnboardingScreen()),
    );

Finder _inTile(int i, Type t) =>
    find.descendant(of: find.byType(DonutTile).at(i), matching: find.byType(t));

void main() {
  testWidgets('shows 4 tiles, keys and legal footer', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.byType(DonutTile), findsNWidgets(4));
    for (final k in [
      'getStartedButton',
      'loginLinkButton',
      'googleSignInButton',
      'appleSignInButton',
      'facebookSignInButton',
    ]) {
      expect(find.byKey(Key(k)), findsOneWidget);
    }
    expect(find.byType(AppLegalFooter), findsOneWidget);
  });

  testWidgets('tiles start at slideFrom with opacity 0, end at rest', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    for (var i = 0; i < 4; i++) {
      final tile = tester.widget<DonutTile>(find.byType(DonutTile).at(i));
      expect(
        tester
            .widget<FractionalTranslation>(_inTile(i, FractionalTranslation))
            .translation,
        tile.slideFrom,
      );
      expect(tester.widget<Opacity>(_inTile(i, Opacity)).opacity, 0);
    }
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      expect(
        tester
            .widget<FractionalTranslation>(_inTile(i, FractionalTranslation))
            .translation,
        Offset.zero,
      );
      expect(tester.widget<Opacity>(_inTile(i, Opacity)).opacity, 1);
    }
  });

  testWidgets('disableAnimations shows final state on first frame', (
    tester,
  ) async {
    await tester.pumpWidget(_app(disableAnimations: true));
    for (var i = 0; i < 4; i++) {
      expect(
        tester
            .widget<FractionalTranslation>(_inTile(i, FractionalTranslation))
            .translation,
        Offset.zero,
      );
      expect(tester.widget<Opacity>(_inTile(i, Opacity)).opacity, 1);
    }
  });

  testWidgets('375x667 at 1.3 text scale does not overflow', (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(textScale: 1.3));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
