part of '../../home_import.dart';

/// 4 display-only nearby shop cards (design spec §5.2): "There are N J'Donut
/// shops".
class NearbyShopsRow extends StatelessWidget {
  final List<Shop> shops;

  const NearbyShopsRow({super.key, required this.shops});

  @override
  Widget build(BuildContext context) {
    if (shops.isEmpty) {
      return AppEmptyState(message: AppLocalizations.of(context)!.noNearbyShopsFound);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(AppLocalizations.of(context)!.nearbyShopsTitle(shops.length),
              style: AppTextStyles.h2),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          // shortcut: fixed height sized for text scale up to 1.3 (spec's max).
          height: 104,
          child: ListView.separated(
            key: const Key('nearbyShopsRow'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: shops.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final shop = shops[index];
              return Container(
                key: Key('shopCard_${shop.id}'),
                width: 160,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(shop.name, style: AppTextStyles.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(shop.address, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(shop.distanceLabel, style: AppTextStyles.caption),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
