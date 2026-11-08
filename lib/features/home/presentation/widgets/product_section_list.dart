part of '../../home_import.dart';

/// Horizontal list for a home section (Seasonal specials / Popular / Order
/// again — design spec §5.2). Reused for every [ProductSection].
///
/// Shortcut: [ProductSection.productIds] is a `List<String>` only (Task 7
/// forward-reference, see product_section.dart) — there is no `Product`
/// entity yet, so each tile renders just its id as a placeholder. Task 9
/// Step 8 is expected to swap this for real product tiles (name/price/image).
class ProductSectionList extends StatelessWidget {
  final ProductSection section;
  final String? errorMessage;

  const ProductSectionList({super.key, required this.section, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return AppErrorState(message: errorMessage!);
    }
    if (section.productIds.isEmpty) {
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
            itemCount: section.productIds.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final productId = section.productIds[index];
              return GestureDetector(
                key: Key('productTile_$productId'),
                onTap: () => context.push('/product/$productId'),
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  // to be enriched by Task 9 with real product data/tiles.
                  child: Text(productId, style: AppTextStyles.caption, textAlign: TextAlign.center),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
