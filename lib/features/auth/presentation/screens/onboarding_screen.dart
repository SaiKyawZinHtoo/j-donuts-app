part of '../../auth_import.dart';

/// PDF screen 1: decorative art, title, primary CTA, log-in link, social
/// row (placeholders), Terms/Privacy (placeholder).
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _socialPlaceholder(BuildContext context, String provider) {
    AppDialog.show(
      context,
      title: provider,
      message: AppLocalizations.of(context)!.socialSignInUnavailableMessage(provider),
    );
  }

  void _legalPlaceholder(BuildContext context, String doc) {
    AppSnackbar.showSuccess(context, AppLocalizations.of(context)!.legalPlaceholderSuffix(doc));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.circle, size: AppSpacing.iconSizeMd, color: AppColors.primary),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.onboardingTitle, style: AppTextStyles.h1, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                key: const Key('getStartedButton'),
                label: l10n.getStartedButton,
                onPressed: () => context.push('/phone'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                key: const Key('loginLinkButton'),
                onPressed: () => context.push('/phone', extra: 'login'),
                child: Text(l10n.loginLink, style: AppTextStyles.body),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    key: const Key('googleSignInButton'),
                    icon: const Icon(Icons.g_mobiledata),
                    onPressed: () => _socialPlaceholder(context, 'Google'),
                  ),
                  IconButton(
                    key: const Key('appleSignInButton'),
                    icon: const Icon(Icons.apple),
                    onPressed: () => _socialPlaceholder(context, 'Apple'),
                  ),
                  IconButton(
                    key: const Key('facebookSignInButton'),
                    icon: const Icon(Icons.facebook),
                    onPressed: () => _socialPlaceholder(context, 'Facebook'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              GestureDetector(
                onTap: () => _legalPlaceholder(context, 'Terms & Privacy'),
                child: Text(l10n.termsPrivacy, style: AppTextStyles.caption),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
