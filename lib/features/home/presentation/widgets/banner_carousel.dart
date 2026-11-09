part of '../../home_import.dart';

/// Auto-playing promo banner carousel (design spec §5.2).
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppSmartImage(
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
                  if (banner.badge != null)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: AppBadge(label: banner.badge!),
                      ),
                    ),
                  // Artwork keeps its left half empty for this headline.
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.45,
                        child: Text(
                          banner.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bannerTitle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
