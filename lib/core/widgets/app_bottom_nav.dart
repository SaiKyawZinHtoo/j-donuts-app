part of '../core_import.dart';

/// Default 5-slot row per design spec §7 / bottom-nav mock: Home, Rewards,
/// Explore, Wallet, Settings. Pass [items] to override.
const List<BottomNavigationBarItem> kDefaultBottomNavItems = [
  BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
  BottomNavigationBarItem(
    icon: Icon(Icons.workspace_premium_outlined),
    label: 'Rewards',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.radio_button_checked),
    label: 'Explore',
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
    // Side inset so the bar floats clear of the screen edges.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.navBar,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.navBarTopRadius),
          ),
          border: Border(top: BorderSide(color: AppColors.surface)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SizedBox(
              height: AppSpacing.navBarHeight,
              // One animated position `p` drives slot widths, pill and labels so
              // they can never disagree mid-transition.
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: currentIndex.toDouble()),
                duration: duration,
                curve: MotionTokens.kEmphasizedCurve,
                builder: (context, p, _) => LayoutBuilder(
                  builder: (context, constraints) =>
                      _buildBar(p, constraints.maxWidth),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBar(double p, double width) {
    final n = items.length;
    // 1 when p is on slot i, falling to 0 one slot away.
    final closeness = [
      for (var i = 0; i < n; i++) (1 - (i - p).abs()).clamp(0.0, 1.0),
    ];
    final weights = [
      for (final c in closeness) 1 + (AppSpacing.navSelectedFlex - 1) * c,
    ];
    final unit = width / (n - 1 + AppSpacing.navSelectedFlex);
    final lefts = <double>[];
    var x = 0.0;
    for (final w in weights) {
      lefts.add(x);
      x += w * unit;
    }
    return Stack(
      children: [
        Positioned(
          key: const Key('navPill'),
          // Linear in p (not derived from slot edges, which would wobble).
          left: p * unit + AppSpacing.xs,
          width: AppSpacing.navSelectedFlex * unit - 2 * AppSpacing.xs,
          top: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.navPill,
                borderRadius: BorderRadius.circular(AppSpacing.navBarHeight),
                border: Border.all(color: AppColors.surface),
              ),
            ),
          ),
        ),
        for (var i = 0; i < n; i++)
          Positioned(
            left: lefts[i],
            width: weights[i] * unit,
            top: 0,
            bottom: 0,
            child: _item(i, closeness[i]),
          ),
      ],
    );
  }

  Widget _item(int i, double c) {
    final label = items[i].label;
    const color = AppColors.surface;
    return Semantics(
      button: true,
      selected: i == currentIndex,
      label: label,
      excludeSemantics: true,
      onTap: () => _tap(i),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _tap(i),
        child: IconTheme(
          data: const IconThemeData(color: color, size: AppSpacing.navItemSize),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(scale: 1 + 0.1 * c, child: items[i].icon),
              if (label != null)
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(left: AppSpacing.sm * c),
                    child: Opacity(
                      opacity: c,
                      child: Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        style: AppTextStyles.captionBold
                            .copyWith(color: color)
                            .embolden(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _tap(int i) {
    if (i != currentIndex) HapticFeedback.selectionClick();
    onTap(i);
  }
}
