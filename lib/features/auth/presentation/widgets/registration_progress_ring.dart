part of '../../auth_import.dart';

/// Donut progress for the registration flow (phone/otp/name/dob =
/// 25/50/75/100%): cyan ring with a pink arc from 12 o'clock. Morphs into a
/// pink disc with a check once [completed].
class RegistrationProgressRing extends StatelessWidget {
  final RegistrationStep step;
  final bool completed;

  const RegistrationProgressRing({
    super.key,
    required this.step,
    this.completed = false,
  });

  static double progressFor(RegistrationStep step) {
    switch (step) {
      case RegistrationStep.phone:
        return 0.25;
      case RegistrationStep.otp:
        return 0.5;
      case RegistrationStep.name:
        return 0.75;
      case RegistrationStep.dob:
        return 1.0;
    }
  }

  static double _previousProgress(RegistrationStep step) => step.index == 0
      ? 0
      : progressFor(RegistrationStep.values[step.index - 1]);

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final duration = reduce ? Duration.zero : MotionTokens.kRingStepDuration;
    final end = progressFor(step);
    final begin = reduce ? end : _previousProgress(step);

    final Widget child = completed
        ? Container(
            key: const ValueKey('ring-done'),
            decoration: const BoxDecoration(
              color: AppColors.ringPink,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.check, color: AppColors.surface),
          )
        : TweenAnimationBuilder<double>(
            key: const ValueKey('ring-progress'),
            tween: Tween<double>(begin: begin, end: end),
            duration: duration,
            builder: (_, value, _) =>
                CustomPaint(painter: RegistrationRingPainter(progress: value)),
          );

    return SizedBox.square(
      dimension: AppSpacing.ringSize,
      child: AnimatedSwitcher(
        duration: duration,
        transitionBuilder: (c, a) => FadeTransition(
          opacity: a,
          child: ScaleTransition(scale: a, child: c),
        ),
        child: child,
      ),
    );
  }
}

/// Paints the donut. Public so tests can read [progress].
@visibleForTesting
class RegistrationRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  const RegistrationRingPainter({
    required this.progress,
    this.trackColor = AppColors.ringCyan,
    this.progressColor = AppColors.ringPink,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * AppSpacing.ringStrokeRatio;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, 2 * math.pi, false, paint..color = trackColor);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint..color = progressColor,
    );
  }

  @override
  bool shouldRepaint(RegistrationRingPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor;
}
