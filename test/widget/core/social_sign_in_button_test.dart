import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/core_import.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('SVG asset renders as SvgPicture at the icon size', (t) async {
    await t.pumpWidget(
      _host(
        SocialSignInButton(
          asset: AppAssets.googleIcon,
          label: 'Continue with Google',
          onPressed: () {},
        ),
      ),
    );
    final svg = t.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svg.width, AppSpacing.socialIconSize);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('PNG asset renders as Image, not SvgPicture', (t) async {
    await t.pumpWidget(
      _host(
        SocialSignInButton(
          asset: AppAssets.appleIcon,
          label: 'Continue with Apple',
          onPressed: () {},
        ),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(SvgPicture), findsNothing);
  });

  testWidgets('tap calls onPressed once; label is the tooltip', (t) async {
    var taps = 0;
    await t.pumpWidget(
      _host(
        SocialSignInButton(
          asset: AppAssets.facebookIcon,
          label: 'Continue with Facebook',
          onPressed: () => taps++,
        ),
      ),
    );
    await t.tap(find.byType(SocialSignInButton));
    expect(taps, 1);
    expect(
      t.widget<IconButton>(find.byType(IconButton)).tooltip,
      'Continue with Facebook',
    );
  });

  testWidgets('tap target is at least 44 logical pixels', (t) async {
    await t.pumpWidget(
      _host(
        SocialSignInButton(
          asset: AppAssets.googleIcon,
          label: 'x',
          onPressed: () {},
        ),
      ),
    );
    final size = t.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(44));
    expect(size.height, greaterThanOrEqualTo(44));
  });
}
