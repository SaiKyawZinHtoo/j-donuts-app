part of '../../home_import.dart';

/// Auto-playing promo banner carousel (design spec §5.2).
class BannerCarousel extends StatefulWidget {
  final List<BannerItem> banners;

  const BannerCarousel({super.key, required this.banners});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _controller = PageController();
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
    if (widget.banners.length > 1 && !MediaQuery.of(context).disableAnimations) {
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
      return AppEmptyState(message: AppLocalizations.of(context)!.noBannersRightNow);
    }
    return SizedBox(
      key: const Key('bannerCarousel'),
      height: 160,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.banners.length,
        itemBuilder: (context, index) {
          final banner = widget.banners[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              child: CachedNetworkImage(
                imageUrl: banner.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) =>
                    const AppSkeleton(isLoading: true, child: SizedBox.expand()),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/seed/banner_seasonal.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
