part of '../../home_import.dart';

/// Peach member header: avatar with arc ring, name, tier caption, points chip,
/// hexagon badge and an orange notification bell.
class MemberHeader extends StatelessWidget {
  final Member member;
  final VoidCallback? onBellTap;
  final int notificationCount;

  /// Placed inside the peach area, flush with its bottom edge (the banner).
  final Widget? footer;

  const MemberHeader({
    super.key,
    required this.member,
    this.onBellTap,
    this.notificationCount = 0,
    this.footer,
  });

  static String _nextTier(String tier) => switch (tier) {
    'Bronze' => 'Gold',
    _ => 'Platinum',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pointsToNext = (member.nextTierPoints - member.points).clamp(
      0,
      member.nextTierPoints,
    );
    const avatar = AppSpacing.iconSizeMd;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      decoration: const BoxDecoration(
        color: AppColors.headerPeach,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppSpacing.headerRadius),
        ),
      ),
      child: Stack(
        children: [
          // Large decorative hexagon behind the bell; clipped by the header.
          Positioned(
            top: AppSpacing.xl + AppSpacing.md,
            right: -AppSpacing.xl * 2.75,
            child: CustomPaint(
              size: const Size.square(AppSpacing.headerBadgeSize),
              painter: const _BigHexPainter(),
              child: const SizedBox.square(
                dimension: AppSpacing.headerBadgeSize,
                // Below the bell, like the reference.
                child: Align(
                  alignment: Alignment(-0.05, -0.15),
                  child: Icon(
                    Icons.star,
                    size: AppSpacing.headerBadgeSize / 6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomPaint(
                            painter: const _ArcRingPainter(),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              child: ClipOval(
                                child: AppSmartImage(
                                  url: member.photoUrl,
                                  width: avatar,
                                  height: avatar,
                                  fit: BoxFit.cover,
                                  errorWidget: (context) => const SizedBox(
                                    width: avatar,
                                    height: avatar,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name,
                                  style: AppTextStyles.h1,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  l10n.memberTierCaption(member.tier),
                                  style: AppTextStyles.bodyBold.copyWith(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Transform.translate(
                            // Flush with the screen's right edge.
                            offset: const Offset(AppSpacing.md, 0),
                            child: Material(
                              color: AppColors.badge,
                              shape: RoundedRectangleBorder(
                                borderRadius: _bellRadius,
                                side: const BorderSide(
                                  color: AppColors.surface,
                                  width: 2,
                                ),
                              ),
                              child: InkWell(
                                key: const Key('memberHeader_bellButton'),
                                borderRadius: _bellRadius,
                                onTap: onBellTap,
                                child: Padding(
                                  // Extra right room: the bar bleeds past the page padding.
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.md,
                                    AppSpacing.sm,
                                    AppSpacing.md + AppSpacing.md,
                                    AppSpacing.sm,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.notifications_none,
                                        color: AppColors.surface,
                                      ),
                                      if (notificationCount > 0)
                                        const SizedBox(width: AppSpacing.xs),
                                      if (notificationCount > 0)
                                        AnimatedSwitcher(
                                          duration:
                                              MediaQuery.disableAnimationsOf(
                                                context,
                                              )
                                              ? Duration.zero
                                              : MotionTokens.kQtyChange,
                                          child: Container(
                                            key: ValueKey(notificationCount),
                                            padding: const EdgeInsets.all(
                                              AppSpacing.xs,
                                            ),
                                            decoration: const BoxDecoration(
                                              color: AppColors.surface,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '$notificationCount',
                                              style: AppTextStyles.captionBold
                                                  .copyWith(
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        key: const Key('memberHeader_pointsChip'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                        ),
                        child: Text(
                          l10n.memberPointsLeft(
                            pointsToNext,
                            _nextTier(member.tier),
                          ),
                          style: AppTextStyles.bodyBold.copyWith(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                if (footer != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  footer!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _bellRadius = BorderRadius.horizontal(
  left: Radius.circular(AppSpacing.xl),
);

class _ArcRingPainter extends CustomPainter {
  const _ArcRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.avatarGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Offset.zero & size,
      -math.pi / 2,
      math.pi * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BigHexPainter extends CustomPainter {
  const _BigHexPainter();

  /// Hexagon with softly rounded corners.
  static Path _rounded(Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final v = [
      for (var i = 0; i < 6; i++)
        c +
            Offset(
              r * math.cos(math.pi / 3 * i - math.pi / 2),
              r * math.sin(math.pi / 3 * i - math.pi / 2),
            ),
    ];
    const t = 0.22;
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final prev = v[(i + 5) % 6], cur = v[i], next = v[(i + 1) % 6];
      final a = Offset.lerp(cur, prev, t)!, b = Offset.lerp(cur, next, t)!;
      i == 0 ? path.moveTo(a.dx, a.dy) : path.lineTo(a.dx, a.dy);
      path.quadraticBezierTo(cur.dx, cur.dy, b.dx, b.dy);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _rounded(size);
    final rect = Offset.zero & size;
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5DCC8), Color(0xFFEFDCCD)],
        ).createShader(rect),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.badge.withValues(alpha: 0.55),
            AppColors.badge.withValues(alpha: 0),
          ],
          stops: const [0.2, 0.7],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
