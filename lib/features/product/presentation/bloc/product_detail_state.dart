part of '../../product_import.dart';

sealed class ProductDetailState {
  const ProductDetailState();
}

final class ProductLoading extends ProductDetailState {
  const ProductLoading();
}

final class ProductLoaded extends ProductDetailState {
  final Product product;
  final int quantity;
  final int totalMmk;

  /// One-shot flag: true for the single state emission right after
  /// [AddToCartPressed], so the screen can show a success snackbar via a
  /// `BlocListener` without the bloc re-emitting on its own.
  final bool addedToCart;

  const ProductLoaded(
    this.product,
    this.quantity,
    this.totalMmk, {
    this.addedToCart = false,
  });

  @override
  bool operator ==(Object other) =>
      other is ProductLoaded &&
      other.product == product &&
      other.quantity == quantity &&
      other.totalMmk == totalMmk &&
      other.addedToCart == addedToCart;

  @override
  int get hashCode => Object.hash(product, quantity, totalMmk, addedToCart);
}

final class ProductError extends ProductDetailState {
  final String message;
  const ProductError(this.message);
}
