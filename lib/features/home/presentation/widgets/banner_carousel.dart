part of '../../home_import.dart';

/// Auto-playing promo banner carousel (design spec §5.2).
/// Card backgrounds cycled by position (the artwork is a framed picture).
const _cardColors = [Color(0xFF6A5DAE), Color(0xFF55C3E8)];

class BannerCarousel extends StatefulWidget {
  final List<BannerItem> banners;

  const BannerCarousel({super.key, required this.banners});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _controller = PageController(
    viewportFraction: AppSpacing.bannerViewportFraction,
    // First banner aligns with the page gutter; the next one peeks on the right.
  );
  Timer? _timer;
  bool _autoplayDecided = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduce Motion: don't start the autoplay timer at all, rather than
    // running it with instant jumps — a banner that never moves on its own
    // is what the setting asks for. Decided once; re-evaluating on every
    // dependency change would restart/stop the timer mid-scroll.
    if (_autoplayDecided) return;
    _autoplayDecided = true;
    if (widget.banners.length > 1 &&
        !MediaQuery.of(context).disableAnimations) {
      _timer = Timer.periodic(MotionTokens.kBannerAutoplayInterval, (_) {
        if (!mounted || !_controller.hasClients) return;
        final next = (_controller.page?.round() ?? 0) + 1;
        _controller.animateToPage(
          next % widget.banners.length,
          duration: MotionTokens.kTabSwitchDuration,
          curve: MotionTokens.kEmphasizedCurve,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return AppEmptyState(
        message: AppLocalizations.of(context)!.noBannersRightNow,
      );
    }
    return SizedBox(
      key: const Key('bannerCarousel'),
      height: AppSpacing.bannerHeight,
      child: PageView.builder(
        controller: _controller,
        padEnds: false,
        itemCount: widget.banners.length,
        itemBuilder: (context, index) {
          final banner = widget.banners[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? AppSpacing.md : AppSpacing.xs,
              right: AppSpacing.xs,
            ),
            child: ClipRRect(
              // Square bottom: the header's rounded edge clips it.
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.cardRadius),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _cardColors[index % _cardColors.length],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Column(
                    children: [
                      if (banner.badge != null) AppBadge(label: banner.badge!),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Text(
                          banner.title,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bannerTitle,
                        ),
                      ),
                      // Framed picture at the bottom, cut by the header curve.
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl + AppSpacing.md,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppSpacing.md),
                              ),
                              border: Border.all(
                                color: AppColors.surface.withValues(alpha: 0.7),
                                width: AppSpacing.badgeBorder,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppSpacing.md),
                              ),
                              child: SizedBox.expand(
                                child: AppSmartImage(
                                  url: banner.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context) => const AppSkeleton(
                                    isLoading: true,
                                    child: SizedBox.expand(),
                                  ),
                                  errorWidget: (context) => Image.asset(
                                    'assets/images/seed/banner_seasonal.png',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
