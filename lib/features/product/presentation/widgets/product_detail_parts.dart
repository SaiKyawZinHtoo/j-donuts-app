part of '../../product_import.dart';

/// Quantity pill and description row of [_ProductDetailScreenState].
extension _ProductDetailParts on _ProductDetailScreenState {
  Widget _quantityPill(
    ProductDetailBloc bloc,
    ProductLoaded state,
    bool reduce,
  ) {
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
          circle(
            const Key('quantityDecrement'),
            Icons.remove,
            () => bloc.add(const QuantityDecremented()),
          ),
          SizedBox(
            width: AppSpacing.iconSizeMd,
            child: AnimatedSwitcher(
              duration: reduce ? Duration.zero : MotionTokens.kQtyChange,
              child: Text(
                '${state.quantity}',
                key: ValueKey(state.quantity),
                textAlign: TextAlign.center,
                style: AppTextStyles.h2,
              ),
            ),
          ),
          circle(
            const Key('quantityIncrement'),
            Icons.add,
            () => bloc.add(const QuantityIncremented()),
          ),
        ],
      ),
    );
  }

  Widget _descriptionRow(
    AppLocalizations l10n,
    String description,
    bool reduce,
  ) {
    const maxLines = 4;
    return InkWell(
      key: const Key('descriptionToggle'),
      onTap: _toggleDescription,
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
                  Text(
                    l10n.whatsThis,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, color: AppColors.border),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Builder(
                builder: (context) {
                  // IntrinsicHeight forbids LayoutBuilder, so estimate the text width.
                  final textWidth =
                      MediaQuery.sizeOf(context).width -
                      AppSpacing.md * 3 -
                      88 -
                      1;
                  final w = textWidth < 0 ? 0.0 : textWidth;
                  final painter = TextPainter(
                    text: TextSpan(
                      text: description,
                      style: AppTextStyles.body,
                    ),
                    textDirection: Directionality.of(context),
                    textScaler: MediaQuery.textScalerOf(context),
                    maxLines: maxLines,
                  )..layout(maxWidth: w);
                  final exceeds = painter.didExceedMaxLines;
                  painter.dispose();
                  final fade = exceeds && !_descriptionExpanded;
                  return AnimatedSize(
                    duration: reduce
                        ? Duration.zero
                        : MotionTokens.kDescriptionExpand,
                    alignment: Alignment.topCenter,
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (r) => LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.surface,
                          AppColors.surface,
                          fade
                              ? AppColors.surface.withValues(alpha: 0.2)
                              : AppColors.surface,
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
