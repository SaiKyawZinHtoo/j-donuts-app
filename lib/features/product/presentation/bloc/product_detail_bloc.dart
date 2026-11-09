part of '../../product_import.dart';

/// Loads one product and tracks the quantity stepper / add-to-cart feedback.
class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final GetProductUseCase getProductUseCase;

  ProductDetailBloc({required this.getProductUseCase})
    : super(const ProductLoading()) {
    on<ProductRequested>(_onRequested);
    on<QuantityIncremented>(_onIncremented);
    on<QuantityDecremented>(_onDecremented);
    on<AddToCartPressed>(_onAddToCart);
  }

  Future<void> _onRequested(
    ProductRequested event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(const ProductLoading());
    final result = await getProductUseCase.call(event.id);
    if (result is Ok<Product>) {
      final product = result.value;
      emit(ProductLoaded(product, 1, product.priceMmk));
    } else {
      emit(ProductError((result as Err<Product>).message));
    }
  }

  void _onIncremented(
    QuantityIncremented event,
    Emitter<ProductDetailState> emit,
  ) {
    final current = state;
    if (current is! ProductLoaded) return;
    final quantity = current.quantity + 1;
    emit(
      ProductLoaded(
        current.product,
        quantity,
        quantity * current.product.priceMmk,
      ),
    );
  }

  void _onDecremented(
    QuantityDecremented event,
    Emitter<ProductDetailState> emit,
  ) {
    final current = state;
    if (current is! ProductLoaded) return;
    if (current.quantity <= 1) return; // quantity floor is 1 — no-op
    final quantity = current.quantity - 1;
    emit(
      ProductLoaded(
        current.product,
        quantity,
        quantity * current.product.priceMmk,
      ),
    );
  }

  void _onAddToCart(AddToCartPressed event, Emitter<ProductDetailState> emit) {
    final current = state;
    if (current is! ProductLoaded) return;
    emit(
      ProductLoaded(
        current.product,
        current.quantity,
        current.totalMmk,
        addedToCart: true,
      ),
    );
  }
}
