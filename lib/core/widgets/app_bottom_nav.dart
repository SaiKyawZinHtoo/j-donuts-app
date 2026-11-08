part of '../core_import.dart';

/// Default 5-slot row per design spec §7 / bottom-nav mock: Home, Explore,
/// Rewards (center), Wallet, Settings. Pass [items] to override.
const List<BottomNavigationBarItem> kDefaultBottomNavItems = [
  BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
  BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explore'),
  BottomNavigationBarItem(
    icon: Icon(Icons.local_offer_outlined),
    label: 'Rewards',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.account_balance_wallet_outlined),
    label: 'Wallet',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.settings_outlined),
    label: 'Settings',
  ),
];

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = kDefaultBottomNavItems,
  });

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : MotionTokens.kNavPillDuration;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Container(
          height: AppSpacing.navBarHeight,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final slot = constraints.maxWidth / items.length;
              return Stack(
                children: [
                  AnimatedPositioned(
                    key: const Key('navPill'),
                    duration: duration,
                    curve: MotionTokens.kEmphasizedCurve,
                    left: currentIndex * slot,
                    top: 0,
                    bottom: 0,
                    width: slot,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.buttonRadius,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        Expanded(child: _item(i)),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _item(int i) {
    final selected = i == currentIndex;
    final label = items[i].label;
    final color = selected ? AppColors.surface : AppColors.navInactive;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: () => onTap(i),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(i),
        child: IconTheme(
          data: IconThemeData(color: color, size: AppSpacing.navItemSize),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              items[i].icon,
              if (selected && label != null)
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(color: color),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
