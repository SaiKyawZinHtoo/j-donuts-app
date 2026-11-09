part of '../../rewards_import.dart';

/// A single challenge card with staggered entrance and a per-card
/// `CustomPainter` driven by `challenge.current/target` (design spec §6.3).
///
/// The art's progress is held in a [ValueNotifier] and passed to
/// [CustomPaint]'s `repaint`, so the painter redraws on a progress change
/// without rebuilding this widget (or the surrounding list).
class ChallengeCard extends StatefulWidget {
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
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard> {
  late ValueNotifier<double> _progress;
  bool _pressed = false;

  double _progressOf(Challenge c) =>
      c.target == 0 ? 0.0 : (c.current / c.target).clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _progress = ValueNotifier(_progressOf(widget.challenge));
  }

  @override
  void didUpdateWidget(ChallengeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _progress.value = _progressOf(widget.challenge);
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;
    final entrance = widget.entrance;

    final l10n = AppLocalizations.of(context)!;
    return FadeTransition(
      opacity: entrance,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(entrance),
        child: Container(
          key: Key('challengeCard_${challenge.id}'),
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.rewardCardRadius),
          ),
          child: Row(
            children: [
              ValueListenableBuilder<double>(
                valueListenable: _progress,
                builder: (context, value, _) =>
                    _ChallengeArt(progress: value, artType: challenge.artType),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(challenge.title, style: AppTextStyles.h2),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${challenge.current}/${challenge.target}',
                      style: AppTextStyles.bodyBold,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        GestureDetector(
                          onTapDown: challenge.isComplete
                              ? (_) => setState(() => _pressed = true)
                              : null,
                          onTapUp: challenge.isComplete
                              ? (_) => setState(() => _pressed = false)
                              : null,
                          onTapCancel: challenge.isComplete
                              ? () => setState(() => _pressed = false)
                              : null,
                          child: AnimatedScale(
                            scale: _pressed ? 0.9 : 1.0,
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : MotionTokens.kTabSwitchDuration,
                            child: AppButton(
                              key: Key('challengeEarnButton_${challenge.id}'),
                              label: l10n.earnTab,
                              onPressed: challenge.isComplete
                                  ? widget.onEarnTap
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            l10n.pointsShort(challenge.rewardPts),
                            style: AppTextStyles.bodyBold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Progress art: a donut photo that regains color clockwise as progress grows,
/// or a drink with an orange arc over it ([artType] 'coffee').
class _ChallengeArt extends StatelessWidget {
  final double progress;
  final String artType;

  const _ChallengeArt({required this.progress, required this.artType});

  static const _grey = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    const size = AppSpacing.rewardArtSize;
    if (artType == 'coffee') {
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ArcPainter(progress),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Transform.scale(
              scale: 1.2,
              child: Image.asset(
                'assets/images/seed/coffee_latte.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      );
    }
    final img = Image.asset(
      'assets/images/seed/donut_strawberry.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          ColorFiltered(
            colorFilter: _grey,
            child: Opacity(opacity: 0.6, child: img),
          ),
          ClipPath(clipper: _WedgeClipper(progress), child: img),
        ],
      ),
    );
  }
}

class _WedgeClipper extends CustomClipper<Path> {
  final double progress;
  const _WedgeClipper(this.progress);

  @override
  Path getClip(Size size) {
    if (progress >= 1) return Path()..addRect(Offset.zero & size);
    return Path()
      ..moveTo(size.width / 2, size.height / 2)
      ..arcTo(
        Offset.zero & size,
        -pi / 2,
        2 * pi * progress.clamp(0.0, 1.0),
        false,
      )
      ..close();
  }

  @override
  bool shouldReclip(covariant _WedgeClipper old) => old.progress != progress;
}

class _ArcPainter extends CustomPainter {
  final double progress;
  const _ArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    // Half ring over the top of the cup.
    const start = pi;
    const span = pi;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, span, false, p..color = AppColors.pageGrey);
    canvas.drawArc(
      rect,
      start,
      span * progress.clamp(0.0, 1.0),
      false,
      p..color = AppColors.badge,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) => old.progress != progress;
}
