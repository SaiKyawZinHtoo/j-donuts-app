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
  // Lives above the BlocBuilder so the entrance is not replayed when the
  // state is rebuilt (e.g. after a retry through HomeLoading).
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
      backgroundColor: AppColors.pageGrey,
      body: BlocBuilder<HomeBloc, HomeState>(
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
                edgeOffset: MediaQuery.paddingOf(context).top,
                onRefresh: () {
                  final done = Completer<void>();
                  context.read<HomeBloc>().add(
                    HomeRefreshRequested(done: done),
                  );
                  return done.future;
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
    );
  }
}

String _offlineText(BuildContext context, DateTime? syncedAt) {
  final l10n = AppLocalizations.of(context)!;
  if (syncedAt == null) return l10n.homeOfflineBanner;
  final minutes = DateTime.now().difference(syncedAt).inMinutes;
  return l10n.homeOfflineBannerUpdated(minutes < 0 ? 0 : minutes);
}

class _HomeSkeletonShape extends StatelessWidget {
  const _HomeSkeletonShape();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: AppSpacing.skeletonPlaceholderHeight);
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
      // ListView would otherwise inset the status bar itself; header paints under it.
      padding: EdgeInsets.zero,
      children: [
        if (state.isOffline)
          Container(
            key: const Key('homeOfflineBanner'),
            width: double.infinity,
            color: AppColors.error,
            // Banner is the topmost child, so it pads the status bar itself.
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm + MediaQuery.paddingOf(context).top,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              _offlineText(context, state.lastSyncedAt),
              style: const TextStyle(color: AppColors.surface),
              textAlign: TextAlign.center,
            ),
          ),
        _entry(
          i++,
          // Under the offline banner the status-bar inset is already consumed.
          MediaQuery.removePadding(
            context: context,
            removeTop: state.isOffline,
            child: MemberHeader(
              member: bundle.member,
              phone: bundle.phone,
              notificationCount: bundle.openChallenges,
              onBellTap: () => context.go('/rewards'),
            ),
          ),
        ),
        // Banners overlap the header's bottom edge.
        Transform.translate(
          offset: const Offset(0, -AppSpacing.lg),
          child: _entry(i++, BannerCarousel(banners: bundle.banners)),
        ),
        const SizedBox(height: AppSpacing.sectionGap - AppSpacing.lg),
        for (final section in bundle.sections) ...[
          _entry(
            i++,
            ProductSectionList(
              section: section,
              errorMessage: state.sectionErrors[section.id],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
        ],
        _entry(i++, NearbyShopsRow(shops: bundle.shops)),
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
