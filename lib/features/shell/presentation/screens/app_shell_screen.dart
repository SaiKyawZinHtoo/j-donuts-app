part of '../../shell_import.dart';

/// Bottom-nav shell, 5 tabs per design spec §7: Home and Rewards are real
/// (built feature-by-feature in later tasks); Explore, Wallet and Settings
/// are generic placeholders.
class AppShellScreen extends StatefulWidget {
  final Widget homeTab;
  final Widget Function(bool isActive) rewardsTab;
  final int initialIndex;

  static const int homeIndex = 0;
  static const int rewardsIndex = 2;

  const AppShellScreen({
    super.key,
    required this.homeTab,
    required this.rewardsTab,
    this.initialIndex = homeIndex,
  });

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  late int _currentIndex = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [
      widget.homeTab,
      PlaceholderTabScreen(label: l10n.exploreTabLabel),
      widget.rewardsTab(_currentIndex == AppShellScreen.rewardsIndex),
      PlaceholderTabScreen(label: l10n.walletTabLabel),
      const SettingsTabScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined), label: l10n.homeTabLabel),
          BottomNavigationBarItem(
              icon: const Icon(Icons.explore_outlined), label: l10n.exploreTabLabel),
          BottomNavigationBarItem(
              icon: const Icon(Icons.local_offer_outlined), label: l10n.rewardsTabLabel),
          BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: l10n.walletTabLabel),
          BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined), label: l10n.settingsTabLabel),
        ],
      ),
    );
  }
}
