part of '../../home_import.dart';

/// Peach member header: avatar with arc ring, name, tier caption, points chip,
/// hexagon badge and an orange notification bell.
class MemberHeader extends StatelessWidget {
  final Member member;
  final VoidCallback? onBellTap;
  final int notificationCount;
  final String? phone;

  const MemberHeader({
    super.key,
    required this.member,
    this.onBellTap,
    this.notificationCount = 0,
    this.phone,
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
      // Extra bottom room: the banner overlaps this strip, never the points chip.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.headerPeach,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppSpacing.headerRadius),
        ),
      ),
      child: SafeArea(
        bottom: false,
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
                        errorWidget: (context) =>
                            const SizedBox(width: avatar, height: avatar),
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
                      if (phone != null)
                        Text(
                          phone!,
                          key: const Key('memberHeader_phone'),
                          style: AppTextStyles.caption,
                        ),
                      Text(
                        l10n.memberTierCaption(member.tier),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                ClipPath(
                  clipper: const _HexClipper(),
                  child: Container(
                    width: AppSpacing.headerBadgeSize,
                    height: AppSpacing.headerBadgeSize,
                    color: AppColors.pageGrey,
                    child: const Icon(
                      Icons.star,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Material(
                  color: AppColors.badge,
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  child: InkWell(
                    key: const Key('memberHeader_bellButton'),
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                    onTap: onBellTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
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
                              duration: MediaQuery.disableAnimationsOf(context)
                                  ? Duration.zero
                                  : MotionTokens.kQtyChange,
                              child: Container(
                                key: ValueKey(notificationCount),
                                padding: const EdgeInsets.all(AppSpacing.xs),
                                decoration: const BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$notificationCount',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.badge,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
                l10n.memberPointsLeft(pointsToNext, _nextTier(member.tier)),
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcRingPainter extends CustomPainter {
  const _ArcRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.badge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
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

class _HexClipper extends CustomClipper<Path> {
  const _HexClipper();

  @override
  Path getClip(Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final a = math.pi / 3 * i - math.pi / 2;
      final p = c + Offset(r * math.cos(a), r * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
