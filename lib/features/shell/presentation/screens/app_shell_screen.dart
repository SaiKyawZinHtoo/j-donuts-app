part of '../../shell_import.dart';

/// Bottom-nav shell, 5 tabs per design spec §7: Home and Rewards are real
/// (built feature-by-feature in later tasks); Explore, Wallet and Settings
/// are generic placeholders.
class AppShellScreen extends StatefulWidget {
  final Widget homeTab;
  final Widget rewardsTab;
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
    final tabs = [
      widget.homeTab,
      const PlaceholderTabScreen(label: 'Explore'),
      widget.rewardsTab,
      const PlaceholderTabScreen(label: 'Wallet'),
      const PlaceholderTabScreen(label: 'Settings'),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
