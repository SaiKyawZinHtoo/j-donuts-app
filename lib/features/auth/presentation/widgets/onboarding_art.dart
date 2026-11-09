part of '../../auth_import.dart';

/// Donut cluster plus the overlapping logo circle at its bottom edge.
class _OnboardingArt extends StatelessWidget {
  const _OnboardingArt({
    required this.width,
    required this.clusterHeight,
    required this.unit,
    required this.tileAnimation,
  });

  final double width;
  final double clusterHeight;
  final double unit;
  final Animation<double> Function(int) tileAnimation;

  @override
  Widget build(BuildContext context) {
    final w = width;
    final clusterH = clusterHeight;
    return SizedBox(
      height: clusterH,
      width: w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Extends below the cluster so circles are
          // clipped left/right/top only, not flat-cut.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: -unit,
            child: ExcludeSemantics(
              child: ClipRect(
                child: Stack(
                  children: [
                    for (var i = 0; i < kOnboardingTiles.length; i++)
                      Positioned(
                        left:
                            kOnboardingTiles[i].cx * w -
                            kOnboardingTiles[i].size * unit / 2,
                        top:
                            kOnboardingTiles[i].cy * clusterH -
                            kOnboardingTiles[i].size * unit / 2,
                        child: DonutTile(
                          asset: kOnboardingTiles[i].asset,
                          circleColor: kOnboardingTiles[i].color,
                          size: kOnboardingTiles[i].size * unit,
                          animation: tileAnimation(i),
                          slideFrom: kOnboardingTiles[i].slideFrom,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: (w - AppSpacing.logoCircleSize) / 2,
            bottom: -AppSpacing.logoCircleSize / 2,
            child: Container(
              width: AppSpacing.logoCircleSize,
              height: AppSpacing.logoCircleSize,
              padding: const EdgeInsets.all(AppSpacing.logoCirclePadding),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/seed/brand_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Title, CTA, log-in link, social row and legal footer.
class _OnboardingActions extends StatelessWidget {
  const _OnboardingActions({
    required this.titleAnimation,
    required this.buttonAnimation,
  });

  final Animation<double> titleAnimation;
  final Animation<double> buttonAnimation;

  void _socialPlaceholder(BuildContext context, String provider) {
    AppDialog.show(
      context,
      title: provider,
      message: AppLocalizations.of(context)!
          .socialSignInUnavailableMessage(provider),
    );
  }

  void _legalPlaceholder(BuildContext context, String doc) {
    AppSnackbar.showSuccess(
      context,
      AppLocalizations.of(context)!.legalPlaceholderSuffix(doc),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.logoCircleSize / 2 + AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        children: [
          _Rise(
            animation: titleAnimation,
            child: Text(
              l10n.onboardingTitle,
              style: AppTextStyles.h1,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _Rise(
            animation: buttonAnimation,
            child: AppButton(
              key: const Key('getStartedButton'),
              label: l10n.getStartedButton,
              onPressed: () => context.push('/phone'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
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
              SocialSignInButton(
                key: const Key('googleSignInButton'),
                asset: AppAssets.googleIcon,
                label: l10n.continueWithGoogle,
                onPressed: () => _socialPlaceholder(context, 'Google'),
              ),
              SocialSignInButton(
                key: const Key('appleSignInButton'),
                asset: AppAssets.appleIcon,
                label: l10n.continueWithApple,
                onPressed: () => _socialPlaceholder(context, 'Apple'),
              ),
              SocialSignInButton(
                key: const Key('facebookSignInButton'),
                asset: AppAssets.facebookIcon,
                label: l10n.continueWithFacebook,
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
    );
  }
}
