part of '../../rewards_import.dart';

/// Rewards tab (design spec §6): animated points ring, tier ladder,
/// staggered challenge cards, earn/gift tab switcher.
class RewardsScreen extends StatefulWidget {
  /// Whether this tab is the one currently visible in the shell. The
  /// entrance animation starts the first time this turns true, not merely
  /// on first build -- an `IndexedStack` builds every tab up front, so
  /// "first build" alone would run the animation to completion before the
  /// user ever taps the Rewards tab.
  final bool isActive;

  const RewardsScreen({super.key, this.isActive = true});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _entranceStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.kPointsRingDuration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.isActive) _maybeStartEntrance();
  }

  @override
  void didUpdateWidget(RewardsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _maybeStartEntrance();
  }

  void _maybeStartEntrance() {
    if (_entranceStarted) return;
    _entranceStarted = true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('rewardsScreen'),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<RewardsBloc, RewardsState>(
          builder: (context, state) {
            switch (state) {
              case RewardsLoading():
                return const AppSkeleton(isLoading: true, child: SizedBox(height: 400));
              case RewardsError(message: final message):
                return AppErrorState(
                  message: message,
                  onRetry: () => context.read<RewardsBloc>().add(const RewardsRequested()),
                );
              case RewardsLoaded():
                return _RewardsContent(state: state, controller: _controller);
            }
          },
        ),
      ),
    );
  }
}

/// One-shot scale + fade entrance badge showing the number of open
/// challenges (design spec §6.2, "Rewards badge '3'").
class _RewardsBadge extends StatelessWidget {
  final int count;
  final AnimationController controller;

  const _RewardsBadge({required this.count, required this.controller});

  @override
  Widget build(BuildContext context) {
    final entrance = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack),
    );
    return Align(
      alignment: Alignment.centerRight,
      child: ScaleTransition(
        scale: entrance,
        child: FadeTransition(
          opacity: entrance,
          child: Container(
            key: const Key('rewardsBadge'),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(AppSpacing.lg),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.caption.copyWith(color: AppColors.surface),
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardsContent extends StatelessWidget {
  final RewardsLoaded state;
  final AnimationController controller;

  const _RewardsContent({required this.state, required this.controller});

  /// Per-index staggered start fraction, [kStaggerStep] apart, capped so the
  /// curve stays within 0..0.9 of the controller's timeline.
  double _staggerStart(int index) {
    final totalMs = MotionTokens.kPointsRingDuration.inMilliseconds;
    final stepMs = MotionTokens.kStaggerStep.inMilliseconds * index;
    return (stepMs / totalMs).clamp(0.0, 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final member = state.data.member;
    final challenges = state.data.challenges;

    // Ring sweep finishes in the first 60% of the timeline; tier-line fill
    // (see TierLadder) starts at 30% and runs to 100% -- staggered against
    // each other per design spec §6.2.
    final ringAnim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.6, curve: MotionTokens.kEmphasizedCurve),
    );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              AppProgressRing(
                progress: member.nextTierPoints == 0
                    ? 0
                    : member.points / member.nextTierPoints,
                controller: ringAnim,
              ),
              AnimatedBuilder(
                // Counts toward the same quantity the ring visualizes
                // (member.points, matching its numerator), on the same
                // curved timeline -- spec §6.2 "in sync off the same
                // AnimationController".
                animation: ringAnim,
                builder: (context, _) => Text(
                  '${(ringAnim.value * member.points).round()}',
                  style: AppTextStyles.h1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _RewardsBadge(
          count: challenges.where((c) => !c.isComplete).length,
          controller: controller,
        ),
        const SizedBox(height: AppSpacing.md),
        TierLadder(currentTier: member.tier, controller: controller),
        const SizedBox(height: AppSpacing.md),
        TabSwitcher(
          activeTab: state.activeTab,
          onChanged: (tab) => context.read<RewardsBloc>().add(TabChanged(tab)),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < challenges.length; i++)
          ChallengeCard(
            challenge: challenges[i],
            entrance: CurvedAnimation(
              parent: controller,
              curve: Interval(_staggerStart(i), 1.0, curve: Curves.easeOut),
            ),
            onEarnTap: () => context.read<RewardsBloc>().add(ChallengeTapped(challenges[i].id)),
          ),
      ],
    );
  }
}
