import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/features/product/product_import.dart';
import 'package:j_donuts_app/l10n/app_localizations.dart';

const _product = Product(
  id: 'p1',
  code: 'DN-001',
  name: 'Glazed Donut',
  priceMmk: 1500,
  isNew: true,
  discountPercent: 0,
  imageUrl: 'https://example.com/img.png',
  description: 'Enjoy our scrumptious donuts, soft, sweet, and satisfying in every bite. Choose from classic glazed, rich chocolate, or fun sprinkles. Dive into deliciousness now! Every box is baked fresh each morning with love.',
);

class _StubProductRepository implements ProductRepository {
  @override
  Future<Result<Product>> getProduct(String id) async =>
      const Result.ok(_product);
}

void main() {
  setUp(() async {
    await GetIt.instance.reset();
    GetIt.instance.registerFactory<ProductDetailBloc>(
      () => ProductDetailBloc(
        getProductUseCase: GetProductUseCase(_StubProductRepository()),
      ),
    );
  });

  tearDown(() => GetIt.instance.reset());

  Widget app({bool reduce = false, double scale = 1}) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (c, child) => MediaQuery(
      data: MediaQuery.of(c).copyWith(
        disableAnimations: reduce,
        textScaler: TextScaler.linear(scale),
      ),
      child: child!,
    ),
    home: const ProductDetailScreen(productId: 'p1'),
  );

  Future<void> load(WidgetTester tester, Widget w) async {
    // Tall view: the square picture makes the page taller than the default.
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(w);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('total and quantity update', (tester) async {
    await load(tester, app());
    expect(find.byKey(const Key('productDetailScreen')), findsOneWidget);
    expect(find.text('ADD TO CART'), findsOneWidget);
    expect(find.text('1,500 MMK'), findsWidgets);
    expect(
      find.descendant(
        of: find.byKey(const Key('quantityPill')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('quantityIncrement')));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('3,000 MMK'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('quantityPill')),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('description toggle expands', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await load(tester, app());
    final size = find.descendant(
      of: find.byKey(const Key('descriptionToggle')),
      matching: find.byType(AnimatedSize),
    );
    final before = tester.getSize(size).height;
    await tester.tap(find.byKey(const Key('descriptionToggle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.getSize(size).height, greaterThan(before));
  });

  testWidgets('pill straddles card edge and lower half is tappable', (
    tester,
  ) async {
    await load(tester, app());
    final pill = tester.getRect(find.byKey(const Key('quantityPill')));
    final card = tester.getRect(find.byKey(const Key('productCard')));
    expect((pill.center.dy - card.bottom).abs(), lessThan(2));
    final inc = tester.getCenter(find.byKey(const Key('quantityIncrement')));
    await tester.tapAt(Offset(inc.dx, card.bottom + pill.height / 4));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('3,000 MMK'), findsOneWidget);
  });

  testWidgets('reduce motion renders final state on first frame', (
    tester,
  ) async {
    await tester.pumpWidget(app(reduce: true));
    await tester.pump();
    await tester.pump();
    expect(
      tester.widget<Opacity>(find.byKey(const Key('detailEntrance'))).opacity,
      1.0,
    );
  });

  testWidgets('text scale 1.3 does not overflow', (tester) async {
    await load(tester, app(scale: 1.3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hero element survives Loading -> Loaded', (tester) async {
    final gate = Completer<void>();
    await GetIt.instance.reset();
    GetIt.instance.registerFactory<ProductDetailBloc>(
      () => ProductDetailBloc(
        getProductUseCase: GetProductUseCase(_SlowRepository(gate.future)),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProductDetailScreen(productId: 'p1', heroTag: 'h'),
      ),
    );
    await tester.pump();
    final before = tester.element(find.byType(Hero));
    gate.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('ADD TO CART'), findsOneWidget);
    expect(identical(tester.element(find.byType(Hero)), before), isTrue);
  });

  testWidgets('back arrow pops a pushed route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (c) => TextButton(
            onPressed: () => Navigator.of(c).push(
              MaterialPageRoute<void>(
                builder: (_) => const ProductDetailScreen(productId: 'p1'),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(ProductDetailScreen), findsNothing);
  });

  testWidgets('back arrow does not throw when it cannot pop', (tester) async {
    await load(tester, app());
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

class _SlowRepository implements ProductRepository {
  final Future<void> gate;
  _SlowRepository(this.gate);
  @override
  Future<Result<Product>> getProduct(String id) async {
    await gate;
    return const Result.ok(_product);
  }
}
