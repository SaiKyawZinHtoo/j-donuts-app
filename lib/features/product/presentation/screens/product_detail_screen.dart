part of '../../product_import.dart';

/// Product detail (design spec §5.3): code/name/New badge, image, MMK price,
/// quantity stepper, expandable description, add-to-cart button with live
/// total.
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _descriptionExpanded = false;
  static final _mmkFormat = NumberFormat.decimalPattern();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => GetIt.instance<ProductDetailBloc>()
        ..add(ProductRequested(widget.productId)),
      child: Scaffold(
        key: const Key('productDetailScreen'),
        appBar: AppAppBar(title: l10n.productAppBarTitle),
        body: BlocConsumer<ProductDetailBloc, ProductDetailState>(
          listener: (context, state) {
            if (state is ProductLoaded && state.addedToCart) {
              AppSnackbar.showSuccess(context, l10n.addedToCartMessage);
            }
          },
          builder: (context, state) {
            switch (state) {
              case ProductLoading():
                return const AppSkeleton(isLoading: true, child: SizedBox.expand());
              case ProductError(message: final message):
                return AppErrorState(message: message);
              case ProductLoaded():
                return _buildLoaded(context, state);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, ProductLoaded state) {
    final product = state.product;
    final bloc = context.read<ProductDetailBloc>();
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
              placeholder: (context, url) =>
                  const AppSkeleton(isLoading: true, child: SizedBox.expand()),
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/seed/product_placeholder.png',
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(product.code, style: AppTextStyles.caption),
              if (product.isNew) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Text(l10n.newBadge,
                      style: const TextStyle(color: AppColors.surface, fontSize: 12)),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(product.name, style: AppTextStyles.h1),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.priceMmk(_mmkFormat.format(product.priceMmk)), style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.whatsThis, style: AppTextStyles.body),
                Icon(_descriptionExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          if (_descriptionExpanded) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(product.description, style: AppTextStyles.body),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                key: const Key('quantityDecrement'),
                onPressed: () => bloc.add(const QuantityDecremented()),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('${state.quantity}', style: AppTextStyles.h2),
              IconButton(
                key: const Key('quantityIncrement'),
                onPressed: () => bloc.add(const QuantityIncremented()),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            key: const Key('addToCartButton'),
            label: l10n.addToCartButton(_mmkFormat.format(state.totalMmk)),
            onPressed: () => bloc.add(const AddToCartPressed()),
          ),
        ],
      ),
    );
  }
}
