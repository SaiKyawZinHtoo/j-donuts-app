part of '../../product_import.dart';

abstract class ProductRepository {
  Future<Result<Product>> getProduct(String id);
}
