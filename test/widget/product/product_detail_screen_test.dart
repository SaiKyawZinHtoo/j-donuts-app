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
  description: 'Classic glazed donut.',
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

  testWidgets('total updates when quantity changes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProductDetailScreen(productId: 'p1'),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const Key('productDetailScreen')), findsOneWidget);
    expect(find.text('Add to cart · 1,500 MMK'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quantityIncrement')));
    await tester.pump();

    expect(find.text('Add to cart · 3,000 MMK'), findsOneWidget);
  });
}
