part of '../../home_import.dart';

/// A titled, ordered group of products shown on the home screen.
class ProductSection {
  final String id;
  final String title;
  final List<Product> products;

  const ProductSection({
    required this.id,
    required this.title,
    required this.products,
  });
}
