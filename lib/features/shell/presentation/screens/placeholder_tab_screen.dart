part of '../../shell_import.dart';

/// Generic placeholder for bottom-nav tabs with no real screen yet
/// (design spec §7: only Home and Rewards get real logic).
class PlaceholderTabScreen extends StatelessWidget {
  final String label;

  const PlaceholderTabScreen({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.comingSoon(label),
          style: AppTextStyles.body,
        ),
      ),
    );
  }
}
