part of '../../home_import.dart';

/// Home tab (design spec §5.2): member header, banner carousel, product
/// section lists, nearby shops row, wrapped in [AppSkeleton] while loading.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                return const AppSkeleton(isLoading: true, child: _HomeSkeletonShape());
              case HomeError(message: final message):
                return AppErrorState(
                  message: message,
                  onRetry: () => context.read<HomeBloc>().add(const HomeRequested()),
                );
              case HomeLoaded():
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<HomeBloc>().add(const HomeRefreshRequested());
                  },
                  child: _HomeContent(state: state),
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

  const _HomeContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final bundle = state.data;
    return ListView(
      children: [
        if (state.isOffline)
          Container(
            key: const Key('homeOfflineBanner'),
            width: double.infinity,
            color: AppColors.error,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
            child: Text(
              AppLocalizations.of(context)!.homeOfflineBanner,
              style: const TextStyle(color: AppColors.surface),
              textAlign: TextAlign.center,
            ),
          ),
        MemberHeader(member: bundle.member),
        BannerCarousel(banners: bundle.banners),
        const SizedBox(height: AppSpacing.md),
        for (final section in bundle.sections) ...[
          ProductSectionList(section: section, errorMessage: state.sectionErrors[section.id]),
          const SizedBox(height: AppSpacing.md),
        ],
        NearbyShopsRow(shops: bundle.shops),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
