part of '../../product_import.dart';

sealed class ProductDetailEvent {
  const ProductDetailEvent();
}

final class ProductRequested extends ProductDetailEvent {
  final String id;
  const ProductRequested(this.id);
}

final class QuantityIncremented extends ProductDetailEvent {
  const QuantityIncremented();
}

final class QuantityDecremented extends ProductDetailEvent {
  const QuantityDecremented();
}

final class AddToCartPressed extends ProductDetailEvent {
  const AddToCartPressed();
}
