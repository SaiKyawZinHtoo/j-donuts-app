part of '../../shell_import.dart';

/// Brand splash: the logo pops in, donuts burst out around it, hold, then the
/// whole cluster rises into the Onboarding layout and hands off to `/`.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _logoIn = MotionTokens.kSplashLogoDuration;
  static const _tilesStart = MotionTokens.kSplashTilesStart;
  static const _tileDur = MotionTokens.kSplashTileDuration;
  static const _rise = MotionTokens.kSplashRiseDuration;
  static final _riseStart =
      _tilesStart +
      MotionTokens.kStaggerStep * (kOnboardingTiles.length - 1) +
      _tileDur +
      MotionTokens.kSplashHoldDuration;
  static final _total = _riseStart + _rise;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: _total,
  );
  bool _started = false;
  bool _navigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      Future.microtask(_finish);
      return;
    }
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) _finish();
    });
    _c.forward();
  }

  void _finish() {
    if (!mounted || _navigated) return;
    _navigated = true;
    OnboardingScreen.skipTileEntrance = true;
    context.go('/');
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// 0..1 progress of the window [start, start + len] on the shared timeline.
  double _t(Duration start, Duration len, Curve curve) {
    final now = _c.value * _total.inMicroseconds;
    final v = ((now - start.inMicroseconds) / len.inMicroseconds).clamp(
      0.0,
      1.0,
    );
    return curve.transform(v);
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: reduce
            ? const SizedBox.shrink()
            : LayoutBuilder(
                builder: (context, box) => AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) => _scene(box.maxWidth, box.maxHeight),
                ),
              ),
      ),
    );
  }

  Widget _scene(double w, double h) {
    final clusterH = onboardingClusterHeight(h);
    final unit = math.min(w, clusterH);
    final rise = _t(_riseStart, _rise, MotionTokens.kEmphasizedCurve);
    final logoIn = _t(Duration.zero, _logoIn, Curves.easeOutBack);
    const logoSize = AppSpacing.logoCircleSize;
    final ringR = math.min(w, h) * 0.30;
    final ringSize = w * 0.30;
    const angles = [-2.35, -0.78, 2.35, 0.78]; // diagonal burst around logo
    final bob = rise == 0 ? math.sin(_c.value * 14) * 3 : 0.0;
    final logoCy = lerpDouble(h / 2, clusterH, rise)!;

    final tiles = <Widget>[];
    for (var i = 0; i < kOnboardingTiles.length; i++) {
      final spec = kOnboardingTiles[i];
      final appear = _t(
        _tilesStart + MotionTokens.kStaggerStep * i,
        _tileDur,
        Curves.easeOutBack,
      );
      final ringCx = w / 2 + ringR * math.cos(angles[i]);
      final ringCy = h / 2 + ringR * math.sin(angles[i]);
      final cx = lerpDouble(ringCx, spec.cx * w, rise)!;
      final cy =
          lerpDouble(ringCy, spec.cy * clusterH, rise)! +
          bob * (i.isEven ? 1 : -1);
      final size = lerpDouble(ringSize, spec.size * unit, rise)!;
      tiles.add(
        Positioned(
          left: cx - size / 2,
          top: cy - size / 2,
          child: Opacity(
            opacity: appear.clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: (1 - appear) * -0.26,
              child: Transform.scale(
                scale: appear,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: spec.color,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(spec.asset, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return ExcludeSemantics(
      child: ClipRect(
        child: Stack(
          children: [
            ...tiles,
            Positioned(
              left: (w - logoSize) / 2,
              top: logoCy - logoSize / 2,
              child: Opacity(
                opacity: logoIn.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.6 + 0.4 * logoIn,
                  child: Container(
                    width: logoSize,
                    height: logoSize,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
