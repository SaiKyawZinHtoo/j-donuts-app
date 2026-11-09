import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/features/product/product_import.dart';

class MockProductRepository extends Mock implements ProductRepository {}

const _product = Product(
  id: 'p1',
  code: 'DN-001',
  name: 'Glazed Donut',
  priceMmk: 1500,
  isNew: true,
  discountPercent: 0,
  imageUrl: 'img.png',
  description: 'Classic glazed donut.',
);

ProductDetailBloc _buildBloc({ProductRepository? repository}) {
  final repo = repository ?? MockProductRepository();
  return ProductDetailBloc(getProductUseCase: GetProductUseCase(repo));
}

void main() {
  late MockProductRepository repo;

  setUp(() {
    repo = MockProductRepository();
    when(() => repo.getProduct('p1'))
        .thenAnswer((_) async => const Result.ok(_product));
  });

  blocTest<ProductDetailBloc, ProductDetailState>(
    'QuantityDecremented below 1 is a no-op',
    build: () => _buildBloc(repository: repo),
    seed: () => const ProductLoaded(_product, 1, 1500),
    act: (bloc) => bloc.add(const QuantityDecremented()),
    expect: () => <ProductDetailState>[],
  );

  blocTest<ProductDetailBloc, ProductDetailState>(
    'QuantityIncremented recomputes totalMmk',
    build: () => _buildBloc(repository: repo),
    seed: () => const ProductLoaded(_product, 1, 1500),
    act: (bloc) => bloc.add(const QuantityIncremented()),
    expect: () => [const ProductLoaded(_product, 2, 3000)],
  );

  blocTest<ProductDetailBloc, ProductDetailState>(
    'ProductRequested loads the product at quantity 1',
    build: () => _buildBloc(repository: repo),
    act: (bloc) => bloc.add(const ProductRequested('p1')),
    expect: () => [
      const ProductLoading(),
      const ProductLoaded(_product, 1, 1500),
    ],
  );
}
