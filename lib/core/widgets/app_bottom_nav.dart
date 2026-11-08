part of '../core_import.dart';

/// Default 5-slot row per design spec §7 / bottom-nav mock: Home, Explore,
/// Rewards (center), Wallet, Settings. Pass [items] to override.
const List<BottomNavigationBarItem> kDefaultBottomNavItems = [
  BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
  BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explore'),
  BottomNavigationBarItem(
      icon: Icon(Icons.local_offer_outlined), label: 'Rewards'),
  BottomNavigationBarItem(
      icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
  BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
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
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textSecondary,
      backgroundColor: AppColors.surface,
      type: BottomNavigationBarType.fixed,
      items: items,
    );
  }
}
