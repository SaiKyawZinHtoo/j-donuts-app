part of '../../auth_import.dart';

/// PDF screen 1: decorative art, title, primary CTA, log-in link, social
/// row (placeholders), Terms/Privacy (placeholder).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  /// Set by the splash, whose final frame already shows the tiles and logo.
  static bool skipTileEntrance = false;

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
  final bool _skipTiles = OnboardingScreen.skipTileEntrance;

  @override
  void initState() {
    super.initState();
    OnboardingScreen.skipTileEntrance = false;
  }

  Animation<double> _tile(int i) =>
      _skipTiles ? const AlwaysStoppedAnimation(1.0) : _tileAnims[i];

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
    for (var i = 0; i < kOnboardingTiles.length; i++) _stage(i),
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

  @override
  Widget build(BuildContext context) {
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final clusterH = onboardingClusterHeight(constraints.maxHeight);
            final unit = math.min(w, clusterH);
            return Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: FadeTransition(
                      opacity: _skipTiles
                          ? const AlwaysStoppedAnimation(1.0)
                          : _controller,
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
                        _OnboardingArt(
                          width: w,
                          clusterHeight: clusterH,
                          unit: unit,
                          tileAnimation: _tile,
                        ),
                        _OnboardingActions(
                          titleAnimation: _titleAnim,
                          buttonAnimation: _buttonAnim,
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
