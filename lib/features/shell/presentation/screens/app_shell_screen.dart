part of '../../shell_import.dart';

/// Bottom-nav shell. Home and Rewards are real tabs (built feature-by-feature
/// in later tasks); the other two are generic placeholders per design spec §7.
class AppShellScreen extends StatefulWidget {
  final Widget homeTab;
  final Widget rewardsTab;

  const AppShellScreen({
    super.key,
    required this.homeTab,
    required this.rewardsTab,
  });

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      widget.homeTab,
      widget.rewardsTab,
      const PlaceholderTabScreen(label: 'Orders'),
      const PlaceholderTabScreen(label: 'Profile'),
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
