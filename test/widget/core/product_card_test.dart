import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/core/core_import.dart';

const _img = 'assets/images/seed/product_placeholder.png';

Widget _host(Widget child, {double scale = 1}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (c, w) => MediaQuery(
    data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
    child: w!,
  ),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  for (final mode in ProductCardImageMode.values) {
    testWidgets('$mode renders title and image', (t) async {
      await t.pumpWidget(_host(
          ProductCard(imageUrl: _img, title: 'Glazed', mode: mode)));
      expect(find.text('Glazed'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('$mode title wraps to 2 lines within budget at 1.3x', (t) async {
      const long = 'Glazed Strawberry Sprinkle Donut With Extra Cream Filling '
          'And Chocolate Drizzle On Top Deluxe Edition';
      final titleFinder = find.text(long);
      await t.pumpWidget(_host(
          ProductCard(imageUrl: _img, title: long, mode: mode),
          scale: 1.3));
      expect(t.takeException(), isNull);
      final ctx = t.element(find.byType(ProductCard));
      final imageH = ProductCard.widthFor(mode) /
          (mode == ProductCardImageMode.photo
              ? AppSpacing.cardPhotoAspect
              : AppSpacing.cardCutoutAspect);
      final budget = ProductCard.heightFor(ctx, mode) - AppSpacing.sm - imageH;
      final h = t.getSize(titleFinder).height;
      expect(h, lessThanOrEqualTo(budget + 1));
      expect(h, greaterThan(budget / 2 + 1)); // more than one line
      final text = t.widget<Text>(titleFinder);
      expect(text.maxLines, 2);
    });

    testWidgets('$mode Hero only when heroTag set', (t) async {
      await t.pumpWidget(_host(
          ProductCard(imageUrl: _img, title: 'a', mode: mode, heroTag: 'h')));
      expect(find.byType(Hero), findsOneWidget);
      await t.pumpWidget(
          _host(ProductCard(imageUrl: _img, title: 'a', mode: mode)));
      expect(find.byType(Hero), findsNothing);
    });
  }

  testWidgets('cutout Hero wraps only the image, not the white card', (t) async {
    await t.pumpWidget(_host(const ProductCard(
        imageUrl: _img,
        title: 'a',
        mode: ProductCardImageMode.cutout,
        heroTag: 'h')));
    expect(
        find.descendant(of: find.byType(Hero), matching: find.byType(DecoratedBox)),
        findsNothing);
    expect(
        find.descendant(of: find.byType(Hero), matching: find.byType(Image)),
        findsOneWidget);
  });

  testWidgets('badge shown only when label set', (t) async {
    await t.pumpWidget(_host(const ProductCard(
        imageUrl: _img,
        title: 'a',
        mode: ProductCardImageMode.photo,
        badgeLabel: '50% off')));
    expect(find.text('50% off'), findsOneWidget);
    await t.pumpWidget(_host(const ProductCard(
        imageUrl: _img, title: 'a', mode: ProductCardImageMode.photo)));
    expect(find.text('50% off'), findsNothing);
  });

  testWidgets('tap calls onTap once', (t) async {
    var n = 0;
    await t.pumpWidget(_host(ProductCard(
        imageUrl: _img,
        title: 'tap me',
        mode: ProductCardImageMode.photo,
        onTap: () => n++)));
    await t.tap(find.text('tap me'));
    expect(n, 1);
  });

  test('widthFor tokens', () {
    expect(ProductCard.widthFor(ProductCardImageMode.photo),
        AppSpacing.cardPhotoWidth);
    expect(ProductCard.widthFor(ProductCardImageMode.cutout),
        AppSpacing.cardCutoutWidth);
  });
}
