part of '../../rewards_import.dart';

/// A single challenge card with staggered entrance and a per-card
/// `CustomPainter` driven by `challenge.current/target` (design spec §6.3).
class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final Animation<double> entrance;
  final VoidCallback? onEarnTap;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.entrance,
    this.onEarnTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = challenge.target == 0
        ? 0.0
        : (challenge.current / challenge.target).clamp(0.0, 1.0);

    return FadeTransition(
      opacity: entrance,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(entrance),
        child: Container(
          key: Key('challengeCard_${challenge.id}'),
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs, horizontal: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CustomPaint(
                size: const Size(40, 40),
                painter: _ChallengeArtPainter(
                  progress: progress,
                  artType: challenge.artType,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(challenge.title, style: AppTextStyles.body),
                    Text(
                      '${challenge.current}/${challenge.target} · +${challenge.rewardPts} pts',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              AnimatedScale(
                scale: challenge.isComplete ? 1.0 : 0.95,
                duration: MotionTokens.kTabSwitchDuration,
                child: AppButton(
                  key: Key('challengeEarnButton_${challenge.id}'),
                  label: 'Earn',
                  onPressed: challenge.isComplete ? onEarnTap : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Donut-quarters or coffee-arc art per [Challenge.artType].
class _ChallengeArtPainter extends CustomPainter {
  final double progress;
  final String artType;

  _ChallengeArtPainter({required this.progress, required this.artType});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final trackPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final fillPaint = Paint()
      ..color = AppColors.primary
      ..style = artType == 'coffee' ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, trackPaint);
    if (artType == 'coffee') {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress.clamp(0.0, 1.0),
        true,
        fillPaint,
      );
    } else {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress.clamp(0.0, 1.0),
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChallengeArtPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.artType != artType;
}
