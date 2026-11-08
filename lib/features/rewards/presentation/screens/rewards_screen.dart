part of '../../rewards_import.dart';

/// Rewards tab (design spec §6): animated points ring, tier ladder,
/// staggered challenge cards, earn/gift tab switcher.
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

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
                controller: controller,
              ),
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) => Text(
                  '${(controller.value * member.totalPoints).round()}',
                  style: AppTextStyles.h1,
                ),
              ),
            ],
          ),
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
