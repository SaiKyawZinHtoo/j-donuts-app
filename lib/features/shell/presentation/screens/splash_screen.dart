part of '../../shell_import.dart';

/// One scattered donut of the splash burst. Fractions are of screen width/height
/// ([size] of width). The first four share an index with [kOnboardingTiles] and
/// settle into it; the rest drift off-screen during the rise.
class _Scatter {
  const _Scatter(
    this.asset,
    this.color,
    this.x,
    this.y,
    this.size,
    this.rot,
    this.delayMs,
  );
  final String asset;
  final Color color;
  final double x;
  final double y;
  final double size;
  final double rot;
  final int delayMs;
}

const _scatter = [
  _Scatter(
    'assets/images/seed/tile_1.png',
    AppColors.tileCyan,
    0.18,
    0.20,
    0.34,
    -0.35,
    0,
  ),
  _Scatter(
    'assets/images/seed/tile_2.png',
    AppColors.tileBlue,
    0.84,
    0.26,
    0.28,
    0.40,
    240,
  ),
  _Scatter(
    'assets/images/seed/tile_3.png',
    AppColors.tilePurple,
    0.22,
    0.76,
    0.30,
    0.30,
    100,
  ),
  _Scatter(
    'assets/images/seed/donut_strawberry.png',
    AppColors.tileBeige,
    0.72,
    0.70,
    0.38,
    -0.25,
    360,
  ),
  _Scatter(
    'assets/images/seed/donut_chocolate.png',
    AppColors.tileBeige,
    0.62,
    0.11,
    0.22,
    0.55,
    180,
  ),
  _Scatter(
    'assets/images/seed/donut_coconut.png',
    AppColors.tileCyan,
    0.09,
    0.48,
    0.24,
    -0.50,
    420,
  ),
  _Scatter(
    'assets/images/seed/tile_2.png',
    AppColors.tilePurple,
    0.90,
    0.50,
    0.20,
    0.35,
    60,
  ),
  _Scatter(
    'assets/images/seed/tile_1.png',
    AppColors.tileBeige,
    0.42,
    0.90,
    0.26,
    -0.40,
    300,
  ),
];

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
      const Duration(milliseconds: 420) +
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
    final bob = rise == 0 ? 1.0 : 0.0;
    final logoCy = lerpDouble(h / 2, clusterH, rise)!;
    final far = math.max(w, h);

    final tiles = <Widget>[];
    for (var i = 0; i < _scatter.length; i++) {
      final sp = _scatter[i];
      final appear = _t(
        _tilesStart + Duration(milliseconds: sp.delayMs),
        _tileDur,
        Curves.easeOutBack,
      );
      var cx = sp.x * w;
      var cy = sp.y * h;
      var size = sp.size * w;
      var rot = sp.rot;
      var fade = 1.0;
      if (i < kOnboardingTiles.length) {
        final spec = kOnboardingTiles[i];
        cx = lerpDouble(cx, spec.cx * w, rise)!;
        cy = lerpDouble(cy, spec.cy * clusterH, rise)!;
        size = lerpDouble(size, spec.size * unit, rise)!;
        rot = sp.rot * (1 - rise);
      } else {
        // Extras leave outward from the screen centre.
        final dx = cx - w / 2;
        final dy = cy - h / 2;
        final len = math.sqrt(dx * dx + dy * dy);
        cx += dx / len * far * rise;
        cy += dy / len * far * rise;
        fade = 1 - rise;
      }
      // Each donut drifts on its own phase/speed so nothing moves in lockstep.
      cx += bob * math.sin(_c.value * (11 + i) + i) * 4;
      cy += bob * math.cos(_c.value * (9 + i * 1.3) + i * 2) * 4;
      tiles.add(
        Positioned(
          left: cx - size / 2,
          top: cy - size / 2,
          child: Opacity(
            opacity: (appear * fade).clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: rot + (1 - appear) * -0.26,
              child: Transform.scale(
                scale: appear.clamp(0.0, 1.2),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: sp.color,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(sp.asset, fit: BoxFit.cover),
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
