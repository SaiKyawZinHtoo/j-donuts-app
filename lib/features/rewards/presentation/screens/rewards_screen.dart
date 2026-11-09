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

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
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
      backgroundColor: AppColors.pageGrey,
      body: BlocBuilder<RewardsBloc, RewardsState>(
        builder: (context, state) {
          switch (state) {
            case RewardsLoading():
              return const AppSkeleton(
                isLoading: true,
                child: SizedBox(height: 400),
              );
            case RewardsError(message: final message):
              return AppErrorState(
                message: message,
                onRetry: () =>
                    context.read<RewardsBloc>().add(const RewardsRequested()),
              );
            case RewardsLoaded():
              return _RewardsContent(state: state, controller: _controller);
          }
        },
      ),
    );
  }
}

/// One-shot scale + fade entrance pill: "Rewards" plus the number of open
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
    return ScaleTransition(
      scale: entrance,
      alignment: Alignment.centerRight,
      child: FadeTransition(
        opacity: entrance,
        child: Container(
          key: const Key('rewardsBadge'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          decoration: const BoxDecoration(
            color: AppColors.badge,
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(AppSpacing.buttonRadius),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.rewardsBadgeLabel,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.badge,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
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

    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final ringSize = width * 0.55;
    const ladderHeight = AppSpacing.tierRowHeight * 3;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Top block: white, runs under the status bar.
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Text(l10n.rewardsTitle, style: AppTextStyles.h1),
                    ),
                  ),
                  _RewardsBadge(
                    count: challenges.where((c) => !c.isComplete).length,
                    controller: controller,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: ladderHeight,
                child: ClipRect(
                  child: Stack(
                    children: [
                      Positioned(
                        left: AppSpacing.md,
                        top: 0,
                        width: width * 0.47,
                        child: TierLadder(
                          currentTier: member.tier,
                          points: member.points,
                          nextTierPoints: member.nextTierPoints,
                          controller: controller,
                        ),
                      ),
                      // Ring bleeds slightly past the right edge, as in the mock.
                      Positioned(
                        left: width * 0.77 - ringSize / 2,
                        top: (ladderHeight - ringSize) / 2,
                        child: PointsDonut(
                          size: ringSize,
                          progress: member.nextTierPoints == 0
                              ? 0
                              : (member.points / member.nextTierPoints).clamp(
                                  0.0,
                                  1.0,
                                ),
                          totalPoints: member.totalPoints,
                          animation: ringAnim,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
        // Tabs straddle the white/grey boundary.
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.5, 0.5],
              colors: [AppColors.surface, AppColors.pageGrey],
            ),
          ),
          child: Center(
            child: TabSwitcher(
              activeTab: state.activeTab,
              onChanged: (tab) =>
                  context.read<RewardsBloc>().add(TabChanged(tab)),
            ),
          ),
        ),
        Padding(
          // Bottom room so the last card clears the floating nav.
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            120,
          ),
          child: Column(
            children: [
              for (var i = 0; i < challenges.length; i++)
                ChallengeCard(
                  challenge: challenges[i],
                  entrance: CurvedAnimation(
                    parent: controller,
                    curve: Interval(
                      _staggerStart(i),
                      1.0,
                      curve: Curves.easeOut,
                    ),
                  ),
                  onEarnTap: () => context.read<RewardsBloc>().add(
                    ChallengeTapped(challenges[i].id),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
