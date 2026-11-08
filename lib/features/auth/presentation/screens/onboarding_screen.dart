part of '../../auth_import.dart';

/// Overlapping tile circle. [size] is a fraction of the cluster unit
/// (min of screen width and cluster height); [cx] a fraction of the screen
/// width and [cy] of the cluster height (circle centre). Listed in paint
/// order, so the hero is last.
class _TileSpec {
  const _TileSpec(
    this.asset,
    this.color,
    this.size,
    this.cx,
    this.cy,
    this.slideFrom,
  );
  final String asset;
  final Color color;
  final double size;
  final double cx;
  final double cy;
  final Offset slideFrom;
}

const _tiles = [
  _TileSpec(
    'assets/images/seed/tile_1.png',
    AppColors.tileCyan,
    0.62,
    0.08,
    0.30,
    Offset(-0.5, 0),
  ),
  _TileSpec(
    'assets/images/seed/tile_2.png',
    AppColors.tileBlue,
    0.55,
    0.96,
    0.22,
    Offset(0.5, 0),
  ),
  _TileSpec(
    'assets/images/seed/tile_3.png',
    AppColors.tilePurple,
    0.50,
    0.12,
    0.80,
    Offset(-0.5, 0.3),
  ),
  _TileSpec(
    'assets/images/seed/donut_strawberry.png',
    AppColors.tileBeige,
    0.64,
    0.50,
    0.46,
    Offset(0, -0.4),
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
    for (final a in [..._tileAnims, _titleAnim, _buttonAnim]) {
      a.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  late final List<CurvedAnimation> _tileAnims = [
    for (var i = 0; i < _tiles.length; i++) _stage(i),
  ];
  late final CurvedAnimation _titleAnim = _stage(2);
  late final CurvedAnimation _buttonAnim = _stage(3);

  /// Sub-animation starting after [steps] stagger steps and lasting the drift duration.
  CurvedAnimation _stage(int steps) {
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
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final clusterH =
                (constraints.maxHeight - AppSpacing.onboardingContentHeight)
                    .clamp(
                      AppSpacing.onboardingTilesMinFraction *
                          constraints.maxHeight,
                      AppSpacing.onboardingTilesFraction *
                          constraints.maxHeight,
                    );
            final unit = math.min(w, clusterH);
            return Stack(
              children: [
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
                              1 - 2 * (1 - AppSpacing.onboardingTilesFraction),
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
                  top: false,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
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
                                        for (var i = 0; i < _tiles.length; i++)
                                          Positioned(
                                            left:
                                                _tiles[i].cx * w -
                                                _tiles[i].size * unit / 2,
                                            top:
                                                _tiles[i].cy * clusterH -
                                                _tiles[i].size * unit / 2,
                                            child: DonutTile(
                                              asset: _tiles[i].asset,
                                              circleColor: _tiles[i].color,
                                              size: _tiles[i].size * unit,
                                              animation: _tileAnims[i],
                                              slideFrom: _tiles[i].slideFrom,
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
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.logoCircleSize / 2 + AppSpacing.md,
                            AppSpacing.lg,
                            AppSpacing.lg,
                          ),
                          child: Column(
                            children: [
                              _Rise(
                                animation: _titleAnim,
                                child: Text(
                                  l10n.onboardingTitle,
                                  style: AppTextStyles.h1,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _Rise(
                                animation: _buttonAnim,
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
                                onTapPrivacy: () => _legalPlaceholder(
                                  context,
                                  'Privacy Policy',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
  Widget build(BuildContext context) => FadeTransition(
    opacity: animation,
    child: AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, AppSpacing.entranceRise * (1 - animation.value)),
        child: child,
      ),
      child: child,
    ),
  );
}
