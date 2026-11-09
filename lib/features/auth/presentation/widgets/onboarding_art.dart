part of '../../auth_import.dart';

/// Donut cluster that fades out into the page gradient at its bottom edge.
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
                // Fade the circles into the page gradient (no mismatched overlay
                // colour), as in the reference design.
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  // The mask rect also covers the overhang below the cluster, so
                  // the fade is measured against the cluster height itself.
                  shaderCallback: (rect) {
                    final end = (clusterH / rect.height).clamp(0.0, 1.0);
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, AppSpacing.onboardingFadeStart * end, end],
                      colors: [
                        AppColors.surface,
                        AppColors.surface,
                        AppColors.surface.withValues(alpha: 0),
                      ],
                    ).createShader(rect);
                  },
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
        AppSpacing.lg,
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
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.accent,
                  ),
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
            textStyle: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
            onTapTerms: () => _legalPlaceholder(context, 'Terms of Use'),
            onTapPrivacy: () => _legalPlaceholder(context, 'Privacy Policy'),
          ),
        ],
      ),
    );
  }
}
