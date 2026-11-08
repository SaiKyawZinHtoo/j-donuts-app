part of '../../home_import.dart';

/// Horizontal list for a home section (Seasonal specials / Popular / Order
/// again — design spec §5.2). Reused for every [ProductSection].
class ProductSectionList extends StatelessWidget {
  final ProductSection section;
  final String? errorMessage;

  const ProductSectionList({super.key, required this.section, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return AppErrorState(message: errorMessage!);
    }
    if (section.products.isEmpty) {
      return const AppEmptyState(message: 'Nothing here yet.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(section.title, style: AppTextStyles.h2),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: section.products.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final product = section.products[index];
              return GestureDetector(
                key: Key('productTile_${product.id}'),
                onTap: () => context.push('/product/${product.id}'),
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => const AppSkeleton(
                                isLoading: true, child: SizedBox.expand()),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/images/seed/product_placeholder.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(product.name,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Row(
                        children: [
                          Flexible(
                            child: Text('${product.priceMmk} MMK',
                                style: AppTextStyles.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (product.isNew) ...[
                            const SizedBox(width: 4),
                            const Text('New',
                                style: TextStyle(color: AppColors.primary, fontSize: 10)),
                          ] else if (product.discountPercent > 0) ...[
                            const SizedBox(width: 4),
                            Text('-${product.discountPercent}%',
                                style: const TextStyle(color: AppColors.error, fontSize: 10)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
