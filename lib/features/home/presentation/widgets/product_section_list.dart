part of '../../home_import.dart';

/// Horizontal list for a home section (Seasonal specials / Popular / Order
/// again — design spec §5.2). Reused for every [ProductSection].
class ProductSectionList extends StatelessWidget {
  final ProductSection section;
  final String? errorMessage;

  const ProductSectionList({
    super.key,
    required this.section,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return AppErrorState(message: errorMessage!);
    }
    if (section.products.isEmpty) {
      return AppEmptyState(
        message: AppLocalizations.of(context)!.nothingHereYet,
      );
    }
    final l10n = AppLocalizations.of(context)!;
    final mode = switch (section.id) {
      'seasonal_specials' => ProductCardImageMode.photo,
      'order_again' => ProductCardImageMode.square,
      _ => ProductCardImageMode.cutout,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SectionHeader(title: section.title),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: ProductCard.heightFor(context, mode),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: section.products.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final product = section.products[index];
              final tag = heroTagFor(section.id, product.id);
              return KeyedSubtree(
                key: Key('productTile_${product.id}'),
                child: ProductCard(
                  imageUrl: product.imageUrl,
                  title: product.name,
                  mode: mode,
                  badgeLabel: product.isNew
                      ? l10n.newBadge
                      : product.discountPercent > 0
                      ? l10n.discountOff(product.discountPercent)
                      : null,
                  heroTag: tag,
                  onTap: () =>
                      context.push('/product/${product.id}', extra: tag),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
