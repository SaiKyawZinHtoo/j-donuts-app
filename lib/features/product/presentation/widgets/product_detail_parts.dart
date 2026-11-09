part of '../../product_import.dart';

/// Quantity pill and description row of [_ProductDetailScreenState].
const double _kDescriptionLabelWidth = 88;

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
    // Perf: no IntrinsicHeight (double layout) and no ShaderMask (a saveLayer
    // plus an on-demand Impeller pipeline compile, ~40ms on the first frame).
    // The divider is the text column's left border; the fade is a plain
    // gradient overlay.
    return InkWell(
      key: const Key('descriptionToggle'),
      onTap: _toggleDescription,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _kDescriptionLabelWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.help, color: AppColors.success),
                Text(l10n.whatsThis, style: AppTextStyles.bodyBold),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                final fade =
                    _descriptionExceeds(context, description, maxLines) &&
                    !_descriptionExpanded;
                return AnimatedSize(
                  duration: reduce
                      ? Duration.zero
                      : MotionTokens.kDescriptionExpand,
                  alignment: Alignment.topCenter,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: AppColors.border)),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.md),
                          child: Text(
                            description,
                            style: AppTextStyles.body,
                            maxLines: _descriptionExpanded ? null : maxLines,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                        if (fade)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.pageGrey.withValues(alpha: 0),
                                      AppColors.pageGrey,
                                    ],
                                    stops: const [0.55, 1],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Whether [description] overflows [maxLines]; measured once per
  /// (text, width, text scale) instead of on every rebuild (each +/- tap).
  bool _descriptionExceeds(
    BuildContext context,
    String description,
    int maxLines,
  ) {
    final width =
        MediaQuery.sizeOf(context).width -
        AppSpacing.md * 3 -
        _kDescriptionLabelWidth -
        1;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final key = '$description|$width|$scale';
    if (_descriptionMeasureKey == key) return _descriptionMeasured;
    final painter = TextPainter(
      text: TextSpan(text: description, style: AppTextStyles.body),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: maxLines,
    )..layout(maxWidth: width < 0 ? 0.0 : width);
    _descriptionMeasured = painter.didExceedMaxLines;
    _descriptionMeasureKey = key;
    painter.dispose();
    return _descriptionMeasured;
  }
}
