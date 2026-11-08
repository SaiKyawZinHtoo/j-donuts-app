part of '../../auth_import.dart';

/// Tile layout, all as fractions of screen width.
class _TileSpec {
  const _TileSpec(
    this.asset,
    this.color,
    this.size,
    this.left,
    this.top,
    this.slideFrom,
  );
  final String asset;
  final Color color;
  final double size;
  final double left;
  final double top;
  final Offset slideFrom;
}

const _tiles = [
  _TileSpec(
    'assets/images/seed/tile_1.png',
    AppColors.tileCyan,
    0.42,
    0.06,
    0.06,
    Offset(-0.5, -0.3),
  ),
  _TileSpec(
    'assets/images/seed/tile_2.png',
    AppColors.tileBeige,
    0.34,
    0.56,
    0.12,
    Offset(0.5, -0.3),
  ),
  _TileSpec(
    'assets/images/seed/tile_3.png',
    AppColors.tileBlue,
    0.38,
    0.10,
    0.50,
    Offset(-0.5, 0.3),
  ),
  _TileSpec(
    'assets/images/seed/donut_strawberry.png',
    AppColors.tilePurple,
    0.30,
    0.52,
    0.46,
    Offset(0.5, 0.3),
  ),
];

/// PDF screen 1: decorative art, title, primary CTA, log-in link, social
/// row (placeholders), Terms/Privacy (placeholder).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  static final _total =
      MotionTokens.kTileDriftDuration + MotionTokens.kStaggerStep * 3;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _total,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Sub-animation starting after [steps] stagger steps and lasting the drift duration.
  Animation<double> _stage(int steps) {
    final begin = MotionTokens.kStaggerStep * steps;
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(
        begin.inMicroseconds / _total.inMicroseconds,
        (begin + MotionTokens.kTileDriftDuration).inMicroseconds /
            _total.inMicroseconds,
        curve: MotionTokens.kEmphasizedCurve,
      ),
    );
  }

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
    final titleAnim = _stage(2);
    final buttonAnim = _stage(3);
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Stack(
              children: [
                for (var i = 0; i < _tiles.length; i++)
                  Positioned(
                    left: _tiles[i].left * w,
                    top: _tiles[i].top * w,
                    child: DonutTile(
                      asset: _tiles[i].asset,
                      circleColor: _tiles[i].color,
                      size: _tiles[i].size * w,
                      animation: _stage(i),
                      slideFrom: _tiles[i].slideFrom,
                    ),
                  ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: FadeTransition(
                      opacity: _controller,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment(
                              0,
                              1 - 2 * AppSpacing.onboardingTilesFraction,
                            ),
                            colors: [
                              AppColors.background,
                              AppColors.background.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, box) => SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: box.maxHeight - AppSpacing.lg * 2,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: AppSpacing.logoCircleSize,
                              height: AppSpacing.logoCircleSize,
                              padding: const EdgeInsets.all(
                                AppSpacing.logoCirclePadding,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                'assets/images/seed/brand_logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _Rise(
                              animation: titleAnim,
                              child: Text(
                                l10n.onboardingTitle,
                                style: AppTextStyles.h1,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            _Rise(
                              animation: buttonAnim,
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
                                Text(
                                  l10n.alreadyHaveAccount,
                                  style: AppTextStyles.body,
                                ),
                                GestureDetector(
                                  key: const Key('loginLinkButton'),
                                  onTap: () =>
                                      context.push('/phone', extra: 'login'),
                                  child: Text(
                                    l10n.loginLink,
                                    style: AppTextStyles.body.copyWith(
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
                                IconButton(
                                  key: const Key('googleSignInButton'),
                                  onPressed: () =>
                                      _socialPlaceholder(context, 'Google'),
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
                                  onPressed: () =>
                                      _socialPlaceholder(context, 'Apple'),
                                ),
                                IconButton(
                                  key: const Key('facebookSignInButton'),
                                  icon: const Icon(Icons.facebook),
                                  onPressed: () =>
                                      _socialPlaceholder(context, 'Facebook'),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppLegalFooter(
                              onTapTerms: () =>
                                  _legalPlaceholder(context, 'Terms of Use'),
                              onTapPrivacy: () =>
                                  _legalPlaceholder(context, 'Privacy Policy'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Fade + rise entrance driven by [animation].
class _Rise extends StatelessWidget {
  const _Rise({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, child) => Opacity(
      opacity: animation.value.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, AppSpacing.entranceRise * (1 - animation.value)),
        child: child,
      ),
    ),
    child: child,
  );
}
