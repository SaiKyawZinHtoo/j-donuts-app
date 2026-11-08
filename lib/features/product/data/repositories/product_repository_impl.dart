part of '../../product_import.dart';

/// Reads products from the local Drift database via [ProductDao].
class ProductRepositoryImpl implements ProductRepository {
  final drift.ProductDao _productDao;

  const ProductRepositoryImpl({required drift.ProductDao productDao})
      : _productDao = productDao;

  @override
  Future<Result<Product>> getProduct(String id) async {
    try {
      final row = await _productDao.getById(id);
      if (row == null) {
        return Result.err('Product not found: $id');
      }
      return Result.ok(mapProductRow(row));
    } catch (e) {
      return Result.err('Failed to load product: $e');
    }
  }
}

/// Maps a Drift `Product` row to the domain [Product] entity. Shared with
/// `HomeRepositoryImpl` so the home feature can reuse the same mapping for
/// its section tiles (see `home_repository_impl.dart`).
Product mapProductRow(drift.Product row) => Product(
      id: row.id,
      code: row.code,
      name: row.name,
      priceMmk: row.priceMmk,
      isNew: row.isNew,
      discountPercent: row.discountPercent,
      imageUrl: row.imageUrl,
      description: row.description,
    );
