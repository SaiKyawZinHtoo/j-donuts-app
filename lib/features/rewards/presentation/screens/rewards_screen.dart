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
    if (!widget.isActive && oldWidget.isActive) {
      // Replay the entrance next time the tab is shown.
      _entranceStarted = false;
      _controller.value = 0;
    }
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
