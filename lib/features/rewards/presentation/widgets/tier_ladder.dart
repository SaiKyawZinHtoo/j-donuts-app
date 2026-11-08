part of '../../rewards_import.dart';

/// Tier ladder: a connecting line that fills alongside tier icons that
/// scale/color-tween in, driven by a screen-owned [controller] (design spec
/// §6.3).
class TierLadder extends AnimatedWidget {
  final String currentTier;
  final AnimationController controller;

  static const _tiers = ['Bronze', 'Silver', 'Gold', 'Platinum'];

  const TierLadder({
    super.key,
    required this.currentTier,
    required this.controller,
  }) : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    final fillAnim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.3, 1.0, curve: MotionTokens.kEmphasizedCurve),
    );
    final activeIndex = _tiers.indexOf(currentTier).clamp(0, _tiers.length - 1);

    return SizedBox(
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _TierLinePainter(
                fillFraction: fillAnim.value * (activeIndex / (_tiers.length - 1)),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < _tiers.length; i++)
                _TierIcon(
                  label: _tiers[i],
                  active: i <= activeIndex,
                  scale: i <= activeIndex ? fillAnim.value : 1.0,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TierIcon extends StatelessWidget {
  final String label;
  final bool active;
  final double scale;

  const _TierIcon({required this.label, required this.active, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Transform.scale(
          scale: 0.7 + (0.3 * scale),
          child: Icon(
            Icons.emoji_events,
            color: Color.lerp(AppColors.border, AppColors.accent, active ? scale : 0),
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _TierLinePainter extends CustomPainter {
  final double fillFraction;

  _TierLinePainter({required this.fillFraction});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final trackPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 2;
    final fillPaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2;

    canvas.drawLine(Offset(0, y), Offset(size.width, y), trackPaint);
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width * fillFraction.clamp(0.0, 1.0), y),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TierLinePainter oldDelegate) =>
      oldDelegate.fillFraction != fillFraction;
}
