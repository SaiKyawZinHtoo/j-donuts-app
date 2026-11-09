part of '../../rewards_import.dart';

/// Big pink sprinkled donut ring with the total points in its hole
/// (reference screen 10). [animation] sweeps the arc and counts the number up.
class PointsDonut extends StatelessWidget {
  final double size;
  final double progress;
  final int totalPoints;
  final Animation<double> animation;

  const PointsDonut({
    super.key,
    required this.size,
    required this.progress,
    required this.totalPoints,
    required this.animation,
  });

  static String _format(int n) => n.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      key: const Key('pointsDonut'),
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) => CustomPaint(
          painter: _DonutPainter(progress: progress * animation.value),
          child: Padding(
            padding: EdgeInsets.all(size * 0.30),
            child: FittedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.totalPointsLabel,
                    style: AppTextStyles.bodyBold
                        .copyWith(color: AppColors.ringPink)
                        .embolden(),
                  ),
                  Text(
                    _format((animation.value * totalPoints).round()),
                    style: AppTextStyles.h1
                        .copyWith(color: AppColors.ringPink)
                        .embolden(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress;
  const _DonutPainter({required this.progress});

  static const _sprinkles = 28;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.22;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    canvas.drawArc(
      rect,
      0,
      2 * pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.pageGrey,
    );
    final sweep = 2 * pi * progress.clamp(0.0, 1.0);
    if (sweep <= 0) return;
    canvas.drawArc(
      rect,
      -pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        // Lighter pink that deepens around the ring.
        ..shader = SweepGradient(
          transform: const GradientRotation(-pi / 2),
          colors: [
            AppColors.ringPinkLight,
            AppColors.ringPinkMid,
            AppColors.ringPinkLight,
          ],
        ).createShader(rect),
    );
    // Sprinkles: seeded so the pattern is stable frame to frame.
    final rnd = Random(7);
    final center = size.center(Offset.zero);
    final r = rect.width / 2;
    final paint = Paint()
      ..color = AppColors.surface.withValues(alpha: 0.5)
      ..strokeWidth = size.width * 0.012 + 1.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < _sprinkles; i++) {
      final a = -pi / 2 + sweep * (i + rnd.nextDouble()) / _sprinkles;
      final rr = r + (rnd.nextDouble() - 0.5) * stroke * 0.6;
      final p = center + Offset(cos(a), sin(a)) * rr;
      final tilt = a + (rnd.nextDouble() - 0.5) * 2;
      final d = Offset(cos(tilt), sin(tilt)) * stroke * 0.14;
      canvas.drawLine(p - d, p + d, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.progress != progress;
}
