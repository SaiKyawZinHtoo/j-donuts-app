part of '../../home_import.dart';

/// Home tab (design spec §5.2): member header, banner carousel, product
/// section lists, nearby shops row, wrapped in [AppSkeleton] while loading.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Lives above the BlocBuilder: a refresh passes through HomeLoading, which
  // would dispose any controller owned by _HomeContent and replay the entrance.
  late final AnimationController _entrance = AnimationController(vsync: this);
  Duration _total = Duration.zero;
  bool _started = false;

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _startOnce(BuildContext context, int count) {
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
      return;
    }
    _total =
        MotionTokens.kHomeSectionStagger * (count - 1) +
        MotionTokens.kStepTransitionDuration;
    _entrance.duration = _total;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _entrance.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('homeScreen'),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            switch (state) {
              case HomeLoading():
                return const AppSkeleton(
                  isLoading: true,
                  child: _HomeSkeletonShape(),
                );
              case HomeError(message: final message):
                return AppErrorState(
                  message: message,
                  onRetry: () =>
                      context.read<HomeBloc>().add(const HomeRequested()),
                );
              case HomeLoaded():
                _startOnce(context, state.data.sections.length + 3);
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<HomeBloc>().add(const HomeRefreshRequested());
                  },
                  child: _HomeContent(
                    state: state,
                    entrance: _entrance,
                    total: _total,
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}

class _HomeSkeletonShape extends StatelessWidget {
  const _HomeSkeletonShape();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 400);
  }
}

class _HomeContent extends StatelessWidget {
  final HomeLoaded state;
  final Animation<double> entrance;
  final Duration total;

  const _HomeContent({
    required this.state,
    required this.entrance,
    required this.total,
  });

  Widget _entry(int index, Widget child) => _SectionEntrance(
    controller: entrance,
    index: index,
    total: total,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final bundle = state.data;
    var i = 0;
    return ListView(
      children: [
        if (state.isOffline)
          Container(
            key: const Key('homeOfflineBanner'),
            width: double.infinity,
            color: AppColors.error,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: AppSpacing.md,
            ),
            child: Text(
              AppLocalizations.of(context)!.homeOfflineBanner,
              style: const TextStyle(color: AppColors.surface),
              textAlign: TextAlign.center,
            ),
          ),
        _entry(i++, MemberHeader(member: bundle.member)),
        _entry(i++, BannerCarousel(banners: bundle.banners)),
        const SizedBox(height: AppSpacing.md),
        for (final section in bundle.sections) ...[
          _entry(
            i++,
            ProductSectionList(
              section: section,
              errorMessage: state.sectionErrors[section.id],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        _entry(i++, NearbyShopsRow(shops: bundle.shops)),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

/// Fade + rise for one Home section, delayed by `index * kHomeSectionStagger`
/// within the shared one-shot [controller].
class _SectionEntrance extends StatelessWidget {
  final Animation<double> controller;
  final int index;
  final Duration total;
  final Widget child;

  const _SectionEntrance({
    required this.controller,
    required this.index,
    required this.total,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // total is zero under Reduce Motion (controller already at 1).
    final totalMs = total.inMilliseconds;
    final delay = MotionTokens.kHomeSectionStagger * index;
    // Clamped: a refresh may bring more sections than `total` was sized for.
    final t = totalMs == 0
        ? controller
        : controller.drive(
            CurveTween(
              curve: Interval(
                (delay.inMilliseconds / totalMs).clamp(0.0, 1.0),
                ((delay + MotionTokens.kStepTransitionDuration).inMilliseconds /
                        totalMs)
                    .clamp(0.0, 1.0),
                curve: MotionTokens.kEmphasizedCurve,
              ),
            ),
          );
    return FadeTransition(
      opacity: t,
      child: AnimatedBuilder(
        animation: t,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, AppSpacing.entranceRise * (1 - t.value)),
          child: child,
        ),
        child: child,
      ),
    );
  }
}
