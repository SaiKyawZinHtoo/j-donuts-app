part of '../../shell_import.dart';

/// Settings tab: currently just exposes log out (spec has no further
/// settings UI yet — see README "Known gaps").
class SettingsTabScreen extends StatefulWidget {
  const SettingsTabScreen({super.key});

  @override
  State<SettingsTabScreen> createState() => _SettingsTabScreenState();
}

class _SettingsTabScreenState extends State<SettingsTabScreen> {
  bool _loggingOut = false;

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    await GetIt.instance<AuthRepository>().logout();
    if (!mounted) return;
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppAppBar(title: l10n.settingsTabLabel),
      body: ListTile(
        leading: const Icon(Icons.logout, color: AppColors.error),
        title: Text(l10n.logOut, style: AppTextStyles.body),
        onTap: _loggingOut ? null : _logout,
        trailing: _loggingOut
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
      ),
    );
  }
}
