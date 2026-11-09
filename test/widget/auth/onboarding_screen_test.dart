import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';

import 'test_helpers.dart';

Widget _app({
  bool disableAnimations = false,
  double textScale = 1.0,
  Size size = const Size(375, 667),
}) => MediaQuery(
  data: MediaQueryData(
    size: size,
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

  testWidgets('the Log In link is bold (Mija bold style, accent colour)', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final link = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('loginLinkButton')),
        matching: find.byType(Text),
      ),
    );
    expect(link.style?.fontWeight, FontWeight.w700);
    expect(link.style?.fontFamily, AppFonts.heading);
    expect(link.style?.color, AppColors.accent);
  });

  testWidgets('the donut header fades out with a gradient mask', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final mask = tester.widget<ShaderMask>(
      find.ancestor(
        of: find.byType(DonutTile).first,
        matching: find.byType(ShaderMask),
      ),
    );
    expect(mask.blendMode, BlendMode.dstIn);
  });

  testWidgets('there is no logo circle above the title', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final logos = find.byWidgetPredicate(
      (w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName.contains('brand_logo'),
    );
    expect(logos, findsNothing);
  });

  testWidgets('legal footer is body size in the secondary text colour', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final footer = tester.widget<AppLegalFooter>(find.byType(AppLegalFooter));
    expect(footer.textStyle.fontSize, AppTextStyles.body.fontSize);
    expect(footer.textStyle.color, AppColors.textSecondary);
    final loginLine = tester.widget<Text>(
      find.text(
        AppLocalizations.of(tester.element(find.byType(OnboardingScreen)))!
            .alreadyHaveAccount,
      ),
    );
    expect(footer.textStyle.fontSize, loginLine.style?.fontSize);
  });

  testWidgets('social buttons use the Google SVG, Apple PNG and Facebook SVG', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.byType(SocialSignInButton), findsNWidgets(3));
    expect(find.byType(SvgPicture), findsNWidgets(2));
    expect(
      find.descendant(
        of: find.byKey(const Key('appleSignInButton')),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );
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
      expect(
        tester.widget<FadeTransition>(_inTile(i, FadeTransition)).opacity.value,
        0,
      );
    }
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      expect(
        tester
            .widget<FractionalTranslation>(_inTile(i, FractionalTranslation))
            .translation,
        Offset.zero,
      );
      expect(
        tester.widget<FadeTransition>(_inTile(i, FadeTransition)).opacity.value,
        1,
      );
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
      expect(
        tester.widget<FadeTransition>(_inTile(i, FadeTransition)).opacity.value,
        1,
      );
    }
  });

  Future<void> pumpAt(WidgetTester tester, Size size, double scale) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(size: size, textScale: scale));
    await tester.pumpAndSettle();
  }

  for (final (size, scale) in [
    (const Size(375, 667), 1.0),
    (const Size(375, 667), 1.3),
    (const Size(430, 932), 1.0),
  ]) {
    testWidgets('no overflow, title clear of tiles at $size x$scale', (
      tester,
    ) async {
      await pumpAt(tester, size, scale);
      expect(tester.takeException(), isNull);
      final title = tester.getRect(
        find.text(
          AppLocalizations.of(tester.element(find.byType(OnboardingScreen)))!
              .onboardingTitle,
        ),
      );
      for (var i = 0; i < 4; i++) {
        expect(
          title.overlaps(tester.getRect(find.byType(DonutTile).at(i))),
          isFalse,
          reason: 'tile $i',
        );
      }
      final button = find.byKey(const Key('getStartedButton'));
      if (scale == 1.0) {
        expect(tester.getRect(button).bottom, lessThanOrEqualTo(size.height));
      } else {
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        expect(tester.getRect(button).bottom, lessThanOrEqualTo(size.height));
      }
      if (size.height > 900) {
        expect(
          tester.getRect(find.byType(AppLegalFooter)).bottom,
          lessThanOrEqualTo(size.height),
        );
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tile clip extends below the lowest tile (no flat cut)', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 667), 1.0);
    var lowest = 0.0;
    for (var i = 0; i < 4; i++) {
      final r = tester.getRect(find.byType(DonutTile).at(i));
      if (r.bottom > lowest) lowest = r.bottom;
    }
    final clip = tester.getRect(
      find
          .ancestor(
            of: find.byType(DonutTile).first,
            matching: find.byType(ClipRect),
          )
          .first,
    );
    expect(clip.bottom, greaterThanOrEqualTo(lowest));
  });
}
