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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => GetIt.instance<ProductDetailBloc>()
        ..add(ProductRequested(widget.productId)),
      child: Scaffold(
        key: const Key('productDetailScreen'),
        backgroundColor: AppColors.pageGrey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) context.pop();
              },
            ),
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
                  return const AppSkeleton(isLoading: true, child: SizedBox.expand());
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _maybeHero(
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                          child: const AppSkeleton(
                            isLoading: true,
                            child: SizedBox(height: 200, width: double.infinity),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
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

  Widget _maybeHero(Widget child) =>
      widget.heroTag == null ? child : Hero(tag: widget.heroTag!, child: child);

  Widget _buildLoaded(BuildContext context, ProductLoaded state) {
    final product = state.product;
    final bloc = context.read<ProductDetailBloc>();
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.code, style: AppTextStyles.caption),
                    Text(product.name, style: AppTextStyles.h1),
                    const SizedBox(height: AppSpacing.xs),
                    Text(l10n.priceMmk(_mmkFormat.format(product.priceMmk)),
                        style: AppTextStyles.h2),
                  ],
                ),
              ),
              if (product.isNew)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.badge,
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Text(l10n.newBadge,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.surface)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _maybeHero(
            AppSmartImage(
              url: product.imageUrl,
              fit: BoxFit.contain,
              height: 280,
              width: double.infinity,
              placeholder: (context) =>
                  const AppSkeleton(isLoading: true, child: SizedBox.expand()),
              errorWidget: (context) => Image.asset(
                'assets/images/seed/product_placeholder.png',
                fit: BoxFit.contain,
                height: 280,
                width: double.infinity,
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
        Padding(padding: const EdgeInsets.only(bottom: half), child: card),
        _quantityPill(bloc, state, reduce),
      ],
    );

    final body = Column(
      children: [
        cardWithPill,
        const SizedBox(height: AppSpacing.md),
        _descriptionRow(l10n, product.description, reduce),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          key: const Key('addToCartButton'),
          label: l10n.addToCartLabel,
          trailingLabel: l10n.priceMmk(_mmkFormat.format(state.totalMmk)),
          onPressed: () => bloc.add(const AddToCartPressed()),
        ),
      ],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
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

  Widget _quantityPill(
      ProductDetailBloc bloc, ProductLoaded state, bool reduce) {
    Widget circle(Key key, IconData icon, VoidCallback onTap) => Material(
          color: AppColors.primary,
          shape: const CircleBorder(),
          child: InkWell(
            key: key,
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: AppSpacing.chevronButtonSize,
              height: AppSpacing.chevronButtonSize,
              child: Icon(icon, color: AppColors.surface),
            ),
          ),
        );
    return Container(
      key: const Key('quantityPill'),
      height: AppSpacing.qtyPillHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.qtyPillHeight / 2),
        border: Border.all(color: AppColors.pageGrey, width: AppSpacing.sm / 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          circle(const Key('quantityDecrement'), Icons.remove,
              () => bloc.add(const QuantityDecremented())),
          SizedBox(
            width: AppSpacing.iconSizeMd,
            child: AnimatedSwitcher(
              duration: reduce ? Duration.zero : MotionTokens.kQtyChange,
              child: Text('${state.quantity}',
                  key: ValueKey(state.quantity),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2),
            ),
          ),
          circle(const Key('quantityIncrement'), Icons.add,
              () => bloc.add(const QuantityIncremented())),
        ],
      ),
    );
  }

  Widget _descriptionRow(
      AppLocalizations l10n, String description, bool reduce) {
    const maxLines = 4;
    return InkWell(
      key: const Key('descriptionToggle'),
      onTap: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 88,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.help, color: AppColors.success),
                  Text(l10n.whatsThis,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Container(width: 1, color: AppColors.border),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Builder(builder: (context) {
                // IntrinsicHeight forbids LayoutBuilder, so estimate the text width.
                final textWidth = MediaQuery.sizeOf(context).width -
                    AppSpacing.md * 4 - 88 - 1;
                final w = textWidth < 0 ? 0.0 : textWidth;
                final painter = TextPainter(
                  text: TextSpan(
                      text: description,
                      style: AppTextStyles.body),
                  textDirection: Directionality.of(context),
                  textScaler: MediaQuery.textScalerOf(context),
                  maxLines: maxLines,
                )..layout(maxWidth: w);
                final fade = painter.didExceedMaxLines && !_descriptionExpanded;
                return AnimatedSize(
                  duration:
                      reduce ? Duration.zero : MotionTokens.kDescriptionExpand,
                  alignment: Alignment.topCenter,
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (r) => LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.surface,
                        AppColors.surface,
                        fade ? AppColors.surface.withValues(alpha: 0.2) : AppColors.surface,
                      ],
                      stops: const [0, 0.7, 1],
                    ).createShader(r),
                    child: Text(
                      description,
                      style: AppTextStyles.body,
                      maxLines: _descriptionExpanded ? null : maxLines,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
