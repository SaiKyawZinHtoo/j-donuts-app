part of '../../rewards_import.dart';

/// Vertical tier timeline (reference screen 10): shield badges joined by a
/// line that fills toward the next tier, driven by the screen's [controller].
/// Shows three consecutive tiers starting at the current one (the last three
/// for the top tier).
class TierLadder extends AnimatedWidget {
  final String currentTier;
  final int points;
  final int nextTierPoints;
  final AnimationController controller;

  static const tiers = ['Bronze', 'Silver', 'Gold', 'Platinum'];
  static const _shown = 3;

  const TierLadder({
    super.key,
    required this.currentTier,
    required this.points,
    required this.nextTierPoints,
    required this.controller,
  }) : super(listenable: controller);

  static Color colorOf(String tier) => switch (tier) {
    'Bronze' => AppColors.tierBronze,
    'Silver' => AppColors.tierSilver,
    'Gold' => AppColors.tierGold,
    _ => AppColors.tierPlatinum,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final active = tiers.indexOf(currentTier).clamp(0, tiers.length - 1);
    final start = active.clamp(0, tiers.length - _shown);
    final fill = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.3, 1.0, curve: MotionTokens.kEmphasizedCurve),
    ).value;
    final progress = nextTierPoints == 0
        ? 0.0
        : (points / nextTierPoints).clamp(0.0, 1.0);
    const rowH = AppSpacing.tierRowHeight;
    const badge = AppSpacing.tierBadgeSize;

    String caption(int tierIndex) {
      if (tierIndex < active) return l10n.tierReached;
      if (tierIndex == active) return l10n.tierHereNow;
      if (tierIndex == active + 1) {
        return l10n.tierRemaining(
          (nextTierPoints - points).clamp(0, nextTierPoints),
          tiers[tierIndex],
        );
      }
      return l10n.tierSoon;
    }

    return SizedBox(
      height: rowH * _shown,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _TierLinePainter(
                badge: badge,
                rowHeight: rowH,
                rows: _shown,
                // Only the segment leaving the current tier fills (toward the next).
                fillFraction: active < tiers.length - 1 && start == active
                    ? progress * fill
                    : 0,
              ),
            ),
          ),
          Column(
            children: [
              for (var r = 0; r < _shown; r++)
                SizedBox(
                  height: rowH,
                  child: Row(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: TierBadge(
                            tier: tiers[start + r],
                            size: badge,
                            scale: start + r <= active ? fill : 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tiers[start + r],
                                style: AppTextStyles.bodyBold,
                              ),
                              Text(
                                caption(start + r),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shield badge with the tier initial and 0-3 stars (S/G/P as in the mock).
class TierBadge extends StatelessWidget {
  final String tier;
  final double size;
  final double scale;

  const TierBadge({
    super.key,
    required this.tier,
    required this.size,
    this.scale = 1,
  });

  @override
  Widget build(BuildContext context) {
    final stars = switch (tier) {
      'Silver' => 1,
      'Gold' => 2,
      'Platinum' => 3,
      _ => 0,
    };
    return Transform.scale(
      scale: 0.7 + 0.3 * scale,
      child: SizedBox(
        width: size,
        height: size * 1.15,
        child: CustomPaint(
          painter: _ShieldPainter(TierLadder.colorOf(tier)),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (stars > 0)
                    Text(
                      '★' * stars,
                      style: AppTextStyles.body.copyWith(
                        fontSize: size * 0.38,
                        height: 1,
                        color: AppColors.tierMark,
                      ),
                    ),
                  Text(
                    tier[0],
                    style: AppTextStyles.bodyBold
                        .copyWith(
                          fontSize: size * 0.42,
                          height: 1.1,
                          color: AppColors.tierMark,
                        )
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

class _ShieldPainter extends CustomPainter {
  final Color color;
  const _ShieldPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..quadraticBezierTo(w * 0.8, h * 0.12, w, h * 0.12)
      ..lineTo(w, h * 0.55)
      ..quadraticBezierTo(w, h * 0.85, w * 0.5, h)
      ..quadraticBezierTo(0, h * 0.85, 0, h * 0.55)
      ..lineTo(0, h * 0.12)
      ..quadraticBezierTo(w * 0.2, h * 0.12, w * 0.5, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.surface.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter old) => old.color != color;
}

class _TierLinePainter extends CustomPainter {
  final double badge;
  final double rowHeight;
  final int rows;
  final double fillFraction;

  const _TierLinePainter({
    required this.badge,
    required this.rowHeight,
    required this.rows,
    required this.fillFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final x = badge / 2;
    final top = badge * 1.15 + AppSpacing.xs + AppSpacing.xs;
    final bottom = rowHeight * (rows - 1) + AppSpacing.xs * 2;
    final track = Paint()
      ..color = AppColors.pageGrey
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, top), Offset(x, bottom), track);
    final gapEnd = rowHeight + AppSpacing.xs * 2;
    canvas.drawLine(
      Offset(x, top),
      Offset(x, top + (gapEnd - top) * fillFraction.clamp(0.0, 1.0)),
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _TierLinePainter old) =>
      old.fillFraction != fillFraction;
}
