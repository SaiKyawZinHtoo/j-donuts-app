part of '../../home_import.dart';

/// Nearby shops block (design spec §2 Home): cyan sky backdrop, title,
/// EXPLORE NOW pill and white shop cards.
class NearbyShopsRow extends StatelessWidget {
  final List<Shop> shops;

  const NearbyShopsRow({super.key, required this.shops});

  // Shop photos cycle by list index; the Shop entity carries no image.
  static const _photos = [
    'assets/images/seed/shop_1.png',
    'assets/images/seed/shop_2.png',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (shops.isEmpty) {
      return AppEmptyState(message: l10n.noNearbyShopsFound);
    }
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              image: DecorationImage(
                image: AssetImage('assets/images/seed/shops_backdrop.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  l10n.nearbyShopsTitle(shops.length),
                  style: AppTextStyles.h2.copyWith(color: AppColors.surface),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: FilledButton(
                  key: const Key('exploreNowButton'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.primary,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => AppSnackbar.showSuccess(
                    context,
                    l10n.comingSoon(l10n.exploreNow),
                  ),
                  child: Text(l10n.exploreNow.toUpperCase()),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                // shortcut: fixed height sized for text scale up to 1.3 (spec's max).
                height: 270,
                child: ListView.separated(
                  key: const Key('nearbyShopsRow'),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: shops.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final shop = shops[index];
                    return Container(
                      key: Key('shopCard_${shop.id}'),
                      width: 260,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            _photos[index % _photos.length],
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(shop.name,
                                      style: AppTextStyles.body,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  Text(shop.address,
                                      style: AppTextStyles.caption,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  const Spacer(),
                                  Text(
                                    l10n.orderOnline,
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
