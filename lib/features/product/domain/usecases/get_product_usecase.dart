part of '../../product_import.dart';

class GetProductUseCase {
  final ProductRepository _repository;

  const GetProductUseCase(this._repository);

  Future<Result<Product>> call(String id) => _repository.getProduct(id);
}
