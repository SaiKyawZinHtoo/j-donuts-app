import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';
import 'package:j_donuts_app/l10n/app_localizations.dart';

import 'test_helpers.dart';

Widget _app({bool disableAnimations = false}) => MediaQuery(
  data: MediaQueryData(disableAnimations: disableAnimations),
  child: makeTestableWidget(const WelcomeScreen()),
);

void main() {
  for (final size in const [Size(375, 667), Size(430, 932)]) {
    testWidgets('renders tiles without overflow at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(WelcomeScreen)),
      )!;
      expect(find.text(l10n.welcomeTitle), findsOneWidget);
      expect(find.byKey(const Key('letsExploreButton')), findsOneWidget);
      expect(find.byType(DonutTile), findsNWidgets(4));
      expect(
        find.descendant(
          of: find.byType(DonutTile),
          matching: find.byType(Image),
        ),
        findsNWidgets(4),
      );
      expect(find.byIcon(Icons.circle), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('reduce motion: tiles fully opaque on first frame', (
    tester,
  ) async {
    await tester.pumpWidget(_app(disableAnimations: true));
    for (var i = 0; i < 4; i++) {
      final f = tester.widget<FadeTransition>(
        find
            .descendant(
              of: find.byType(DonutTile).at(i),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(f.opacity.value, 1.0);
    }
  });
}
