part of '../../shell_import.dart';

/// Brand splash (spec §9): logo scales/fades in, holds, fades out, then
/// hands off to `/` where the router decides home vs. onboarding.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _logo = MotionTokens.kSplashLogoDuration;
  static const _hold = MotionTokens.kSplashHoldDuration;
  static const _exit = MotionTokens.kSplashExitDuration;
  static final _total = _logo + _hold + _exit;

  // One timeline: logo in, hold, fade out. Completion triggers navigation.
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
      // Reduce motion: no animation, but still leave the splash.
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
    context.go('/');
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final total = _total.inMicroseconds;
    final inEnd = _logo.inMicroseconds / total;
    final outStart = (_logo.inMicroseconds + _hold.inMicroseconds) / total;
    final curve = CurvedAnimation(
      parent: _c,
      curve: Interval(0, inEnd, curve: MotionTokens.kEmphasizedCurve),
    );
    final out = CurvedAnimation(parent: _c, curve: Interval(outStart, 1));
    final logo = ExcludeSemantics(
      child: ClipOval(
        child: Image.asset(
          'assets/images/seed/brand_logo.png',
          width: AppSpacing.splashLogoSize,
          height: AppSpacing.splashLogoSize,
          fit: BoxFit.cover,
        ),
      ),
    );
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: reduce
            ? logo
            : FadeTransition(
                opacity: ReverseAnimation(out),
                child: FadeTransition(
                  opacity: curve,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.6, end: 1).animate(curve),
                    child: logo,
                  ),
                ),
              ),
      ),
    );
  }
}
