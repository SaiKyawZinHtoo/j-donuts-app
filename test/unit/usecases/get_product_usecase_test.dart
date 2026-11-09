import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/features/product/product_import.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  test('GetProductUseCase returns Ok with the product', () async {
    final repo = MockProductRepository();
    const product = Product(
      id: 'p1',
      code: 'DN-001',
      name: 'Glazed Donut',
      priceMmk: 1500,
      isNew: true,
      discountPercent: 0,
      imageUrl: 'img.png',
      description: 'Classic glazed donut.',
    );
    when(() => repo.getProduct('p1'))
        .thenAnswer((_) async => const Result.ok(product));

    final result = await GetProductUseCase(repo).call('p1');

    expect(result, isA<Ok<Product>>());
    expect((result as Ok<Product>).value.name, 'Glazed Donut');
  });

  test('GetProductUseCase returns Err when repository fails', () async {
    final repo = MockProductRepository();
    when(() => repo.getProduct('missing'))
        .thenAnswer((_) async => const Result.err('Not found'));

    final result = await GetProductUseCase(repo).call('missing');

    expect(result, isA<Err<Product>>());
  });
}
