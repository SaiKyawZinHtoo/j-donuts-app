part of '../../product_import.dart';

/// A single menu item, shown on the home section tiles and the product
/// detail screen.
class Product {
  final String id;
  final String code;
  final String name;
  final int priceMmk;
  final bool isNew;
  final int discountPercent;
  final String imageUrl;
  final String description;

  const Product({
    required this.id,
    required this.code,
    required this.name,
    required this.priceMmk,
    required this.isNew,
    required this.discountPercent,
    required this.imageUrl,
    required this.description,
  });

  @override
  bool operator ==(Object other) =>
      other is Product &&
      other.id == id &&
      other.code == code &&
      other.name == name &&
      other.priceMmk == priceMmk &&
      other.isNew == isNew &&
      other.discountPercent == discountPercent &&
      other.imageUrl == imageUrl &&
      other.description == description;

  @override
  int get hashCode => Object.hash(
        id,
        code,
        name,
        priceMmk,
        isNew,
        discountPercent,
        imageUrl,
        description,
      );
}
