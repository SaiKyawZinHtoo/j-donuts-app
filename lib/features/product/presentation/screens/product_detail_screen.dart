part of '../../product_import.dart';

/// Product detail (design spec §5.3): code/name/New badge, image, MMK price,
/// quantity stepper, expandable description, add-to-cart button with live
/// total.
class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final String? heroTag;

  const ProductDetailScreen({super.key, required this.productId, this.heroTag});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _descriptionExpanded = false;
  static final _mmkFormat = NumberFormat.decimalPattern();

  // Memo for _descriptionExceeds (see product_detail_parts.dart).
  String? _descriptionMeasureKey;
  bool _descriptionMeasured = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) =>
          GetIt.instance<ProductDetailBloc>()
            ..add(ProductRequested(widget.productId)),
      child: Scaffold(
        key: const Key('productDetailScreen'),
        backgroundColor: AppColors.pageGrey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: BlocConsumer<ProductDetailBloc, ProductDetailState>(
          listener: (context, state) {
            if (state is ProductLoaded && state.addedToCart) {
              AppSnackbar.showSuccess(context, l10n.addedToCartMessage);
            }
          },
          builder: (context, state) {
            switch (state) {
              case ProductLoading():
                // Hero destination must exist on the first frame, at the same tree
                // position as in _buildLoaded so it stays one continuous Hero.
                if (widget.heroTag == null) {
                  return const AppSkeleton(
                    isLoading: true,
                    child: SizedBox.expand(),
                  );
                }
                return _buildLoaded(context, null);
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

  void _toggleDescription() =>
      setState(() => _descriptionExpanded = !_descriptionExpanded);

  Widget _maybeHero(Widget child) =>
      widget.heroTag == null ? child : Hero(tag: widget.heroTag!, child: child);

  Widget _buildLoaded(BuildContext context, ProductLoaded? state) {
    // Loading (state == null) shares this exact tree so the Hero survives the flip.
    final product = state?.product;
    final bloc = state == null ? null : context.read<ProductDetailBloc>();
    final l10n = AppLocalizations.of(context)!;
    final reduce = MediaQuery.disableAnimationsOf(context);
    const half = AppSpacing.qtyPillHeight / 2;

    final card = Container(
      key: const Key('productCard'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          product == null
              ? const SizedBox.shrink()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.code, style: AppTextStyles.caption),
                          Text(product.name, style: AppTextStyles.h1),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            l10n.priceMmk(_mmkFormat.format(product.priceMmk)),
                            style: AppTextStyles.h2,
                          ),
                        ],
                      ),
                    ),
                    if (product.isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.badge,
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                        ),
                        child: Text(
                          l10n.newBadge,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                  ],
                ),
          const SizedBox(height: AppSpacing.md),
          _maybeHero(
            SizedBox(
              height: 280,
              width: double.infinity,
              child: product == null
                  ? const AppSkeleton(isLoading: true, child: SizedBox.expand())
                  : AppSmartImage(
                      url: product.imageUrl,
                      fit: BoxFit.contain,
                      height: 280,
                      width: double.infinity,
                      placeholder: (context) => const AppSkeleton(
                        isLoading: true,
                        child: SizedBox.expand(),
                      ),
                      errorWidget: (context) => Image.asset(
                        'assets/images/seed/product_placeholder.png',
                        fit: BoxFit.contain,
                        height: 280,
                        width: double.infinity,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: half),
        ],
      ),
    );

    // Pill sits inside the Stack's bounds (card is padded by half the pill), so its
    // lower half still receives taps.
    final cardWithPill = Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: half),
          child: card,
        ),
        state == null
            ? const SizedBox.shrink()
            : _quantityPill(bloc!, state, reduce),
      ],
    );

    final body = Column(
      children: [
        cardWithPill,
        const SizedBox(height: AppSpacing.md),
        product == null
            ? const SizedBox.shrink()
            : _descriptionRow(l10n, product.description, reduce),
        const SizedBox(height: AppSpacing.md),
        state == null
            ? const SizedBox.shrink()
            : AppButton(
                key: const Key('addToCartButton'),
                label: l10n.addToCartLabel,
                trailingLabel: l10n.priceMmk(_mmkFormat.format(state.totalMmk)),
                onPressed: () => bloc!.add(const AddToCartPressed()),
              ),
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        AppSpacing.md,
      ).copyWith(bottom: AppSpacing.md + MediaQuery.paddingOf(context).bottom),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: reduce ? 1 : 0, end: 1),
        duration: reduce ? Duration.zero : MotionTokens.kDetailEntrance,
        curve: Curves.easeOut,
        builder: (context, t, child) => Opacity(
          key: const Key('detailEntrance'),
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * AppSpacing.lg),
            child: child,
          ),
        ),
        child: body,
      ),
    );
  }
}
