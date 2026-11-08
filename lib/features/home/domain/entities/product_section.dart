part of '../../home_import.dart';

/// A titled, ordered group of products shown on the home screen.
///
/// Forward-reference note (Task 7, to be reconciled by Task 9 Step 8): the
/// `Product` entity does not exist yet (it is defined in Task 9's
/// `product_import.dart`). Until then this holds the ordered product ids
/// only; Task 9 should replace [productIds] with `List<Product> products`
/// and update [HomeRepositoryImpl] to map full `Product` rows instead of
/// just their ids.
class ProductSection {
  final String id;
  final String title;
  final List<String> productIds;

  const ProductSection({
    required this.id,
    required this.title,
    required this.productIds,
  });
}
