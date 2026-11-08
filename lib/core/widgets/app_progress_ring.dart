part of '../core_import.dart';

/// Circular progress ring driven by an externally-owned [AnimationController]
/// (e.g. points/loyalty progress), animating from 0 to [progress].
class AppProgressRing extends AnimatedWidget {
  final double progress;
  final AnimationController controller;

  const AppProgressRing({
    super.key,
    required this.progress,
    required this.controller,
  }) : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(
        AppSpacing.progressRingSize,
        AppSpacing.progressRingSize,
      ),
      painter: _ProgressRingPainter(
        value: controller.value * progress,
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double value;

  _ProgressRingPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius =
        size.shortestSide / 2 - AppSpacing.progressRingInset;

    final trackPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSpacing.progressRingStrokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSpacing.progressRingStrokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * value.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.value != value;
}
