part of '../../auth_import.dart';

/// PDF screen 7: staggered donut-tile slide-in + title fade-up, then
/// "Let's explore" into Home.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.kStaggerStep * 6,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 1.0;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _tileAnimation(int index) {
    final start =
        (index * MotionTokens.kStaggerStep.inMilliseconds) /
        _controller.duration!.inMilliseconds;
    final end = (start + 0.4).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: MotionTokens.kEmphasizedCurve),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AuthScaffold(
      showBack: false,
      showFooter: false,
      // spaceBetween inside the scaffold's minHeight: group centered, button
      // at the bottom, no Spacer (unbounded max height).
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox.shrink(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                      child: Icon(
                        Icons.circle,
                        size: AppSpacing.iconSizeMd,
                        color: AppColors.accent,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeTransition(
                opacity: _controller,
                child: Text(l10n.welcomeTitle, style: AppTextStyles.h1),
              ),
            ],
          ),
          AppButton(
            key: const Key('letsExploreButton'),
            label: l10n.letsExploreButton,
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
    );
  }
}
