part of '../core_import.dart';

enum ProductCardImageMode { photo, cutout }

class ProductCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final ProductCardImageMode mode;
  final String? badgeLabel;
  final String? heroTag;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.mode,
    this.badgeLabel,
    this.heroTag,
    this.onTap,
  });

  static const double _pressedScale = 0.97;
  static const double _badgeInset = AppSpacing.sm;
  static const int _titleLines = 2;
  static const double _titleLineHeight = 1.25;
  static const double _shadowBlur = 16;
  static const double _shadowWidthFraction = 0.6;
  static const double _shadowHeight = 14;
  static const String _fallbackAsset =
      'assets/images/seed/product_placeholder.png';

  static TextStyle get _titleStyle =>
      AppTextStyles.bodyBold.copyWith(height: _titleLineHeight);

  static double widthFor(ProductCardImageMode m) =>
      m == ProductCardImageMode.photo
      ? AppSpacing.cardPhotoWidth
      : AppSpacing.cardCutoutWidth;

  static double _imageHeight(ProductCardImageMode m) =>
      widthFor(m) /
      (m == ProductCardImageMode.photo
          ? AppSpacing.cardPhotoAspect
          : AppSpacing.cardCutoutAspect);

  static double _titleHeight(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(_titleStyle.fontSize!) *
      _titleLineHeight *
      _titleLines;

  /// Image height plus gap and a 2-line title block at the current text scale.
  static double heightFor(BuildContext context, ProductCardImageMode m) =>
      _imageHeight(m) + AppSpacing.sm + _titleHeight(context);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  Widget _image() {
    final cutout = widget.mode == ProductCardImageMode.cutout;
    final img = AppSmartImage(
      url: widget.imageUrl,
      fit: cutout ? BoxFit.contain : BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_) =>
          const AppSkeleton(isLoading: true, child: SizedBox.expand()),
      errorWidget: (_) => Image.asset(
        ProductCard._fallbackAsset,
        fit: cutout ? BoxFit.contain : BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
    final radius = BorderRadius.circular(AppSpacing.cardRadius);
    Widget area;
    if (cutout) {
      area = DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  width:
                      ProductCard.widthFor(widget.mode) *
                      ProductCard._shadowWidthFraction,
                  height: ProductCard._shadowHeight,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.border,
                        blurRadius: ProductCard._shadowBlur,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: widget.heroTag == null
                  ? img
                  : Hero(tag: widget.heroTag!, child: img),
            ),
          ],
        ),
      );
    } else {
      area = ClipRRect(borderRadius: radius, child: img);
    }
    if (!cutout && widget.heroTag != null) {
      area = Hero(tag: widget.heroTag!, child: area);
    }
    return Stack(
      children: [
        Positioned.fill(child: area),
        if (widget.badgeLabel != null)
          Positioned(
            right: ProductCard._badgeInset,
            bottom: ProductCard._badgeInset,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.badge,
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Text(
                  widget.badgeLabel!,
                  style: AppTextStyles.captionBold.copyWith(
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _pressed && !reduce ? ProductCard._pressedScale : 1.0,
          duration: reduce ? Duration.zero : MotionTokens.kPressScaleDuration,
          curve: Curves.easeOut,
          child: SizedBox(
            width: ProductCard.widthFor(widget.mode),
            height: ProductCard.heightFor(context, widget.mode),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: ProductCard._imageHeight(widget.mode),
                  child: _image(),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.title,
                  style: ProductCard._titleStyle,
                  maxLines: ProductCard._titleLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
