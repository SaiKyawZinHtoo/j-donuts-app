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
              const Icon(Icons.circle, size: AppSpacing.iconSizeMd, color: AppColors.accent),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.onboardingTitle, style: AppTextStyles.h1, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                key: const Key('getStartedButton'),
                label: l10n.getStartedButton,
                onPressed: () => context.push('/phone'),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.alreadyHaveAccount, style: AppTextStyles.body),
                  GestureDetector(
                    key: const Key('loginLinkButton'),
                    onTap: () => context.push('/phone', extra: 'login'),
                    child: Text(
                      l10n.loginLink,
                      style: AppTextStyles.body.copyWith(color: AppColors.accent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    key: const Key('googleSignInButton'),
                    onPressed: () => _socialPlaceholder(context, 'Google'),
                    icon: const Text(
                      'G',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
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
              AppLegalFooter(
                onTapTerms: () => _legalPlaceholder(context, 'Terms of Use'),
                onTapPrivacy: () => _legalPlaceholder(context, 'Privacy Policy'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
