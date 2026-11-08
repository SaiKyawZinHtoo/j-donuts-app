import 'package:drift/drift.dart';

import 'package:j_donuts_app/data/local/database.dart';
import 'package:j_donuts_app/data/local/tables/products_table.dart';

part 'product_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(super.db);

  Stream<List<Product>> watchAll() => select(products).watch();

  Future<Product?> getById(String id) =>
      (select(products)..where((p) => p.id.equals(id))).getSingleOrNull();
}
