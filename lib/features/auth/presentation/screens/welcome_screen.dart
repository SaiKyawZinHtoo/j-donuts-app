part of '../../auth_import.dart';

/// PDF screen 7: staggered donut-tile slide-in + title fade-up, then
/// "Let's explore" into Home.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.kStaggerStep * 6,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _tileAnimation(int index) {
    final start = (index * MotionTokens.kStaggerStep.inMilliseconds) /
        _controller.duration!.inMilliseconds;
    final end = (start + 0.4).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: MotionTokens.kEmphasizedCurve),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final animation = _tileAnimation(index);
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) => Opacity(
                      opacity: animation.value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - animation.value) * 24),
                        child: child,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      child: Icon(Icons.circle, size: AppSpacing.iconSizeMd, color: AppColors.accent),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeTransition(
                opacity: _controller,
                child: Text('Welcome!', style: AppTextStyles.h1),
              ),
              const Spacer(),
              AppButton(
                key: const Key('letsExploreButton'),
                label: "Let's explore",
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
