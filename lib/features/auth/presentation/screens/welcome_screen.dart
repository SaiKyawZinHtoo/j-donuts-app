part of '../../auth_import.dart';

/// PDF screen 7: staggered donut-tile slide-in + title fade-up, then
/// "Let's explore" into Home.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

const _welcomeTiles = [
  ('assets/images/seed/tile_1.png', AppColors.tileBlue),
  ('assets/images/seed/tile_2.png', AppColors.tileBeige),
  ('assets/images/seed/tile_3.png', AppColors.tilePurple),
  ('assets/images/seed/donut_chocolate.png', AppColors.tileCyan),
];

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.kStaggerStep * 6,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
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

  Animation<double> _tileAnimation(int index) {
    final start =
        (index * MotionTokens.kStaggerStep.inMilliseconds) /
        _controller.duration!.inMilliseconds;
    final end = (start + 0.4).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: MotionTokens.kEmphasizedCurve),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AuthScaffold(
      showBack: false,
      showFooter: false,
      titleGap: false,
      // spaceBetween inside the scaffold's minHeight: group centered, button
      // at the bottom, no Spacer (unbounded max height).
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LayoutBuilder(
                builder: (context, c) {
                  // Width from the layout constraints (+ scaffold padding), height from
                  // MediaQuery (unbounded here); OverflowBox escapes the scaffold's
                  // horizontal padding so tiles bleed off both screen edges.
                  final screenW =
                      c.maxWidth + 2 * AppSpacing.authHorizontalPadding;
                  final screenH = MediaQuery.sizeOf(context).height;
                  final stackH = screenH * AppSpacing.welcomeStackFraction;
                  final tileW = screenW * AppSpacing.welcomeTileWidthFraction;
                  const off = AppSpacing.welcomeTileOffset;
                  // Reference aspect, capped so row 1 plus the visible part of
                  // row 2 (and one gap) fit in the stack before the fade.
                  const gap = AppSpacing.xl;
                  final tileH = math.max(
                    0.0,
                    math.min(
                      tileW * AppSpacing.welcomeTileAspect,
                      (stackH - gap) / (1 + AppSpacing.welcomeSecondRowVisible),
                    ),
                  );
                  final leftX = -tileW * AppSpacing.welcomeTileBleedFraction;
                  final rx = screenW * AppSpacing.welcomeRightColumnFraction;
                  Widget tile(int i, double left, double top) => Positioned(
                    left: left,
                    top: top,
                    child: DonutTile(
                      asset: _welcomeTiles[i].$1,
                      circleColor: _welcomeTiles[i].$2,
                      size: tileH,
                      width: tileW,
                      shape: BoxShape.rectangle,
                      radius: AppSpacing.welcomeTileRadius,
                      animation: _tileAnimation(i),
                      slideFrom: const Offset(0, 0.15),
                    ),
                  );
                  return SizedBox(
                    height: stackH,
                    child: OverflowBox(
                      minWidth: screenW,
                      maxWidth: screenW,
                      minHeight: stackH,
                      maxHeight: stackH,
                      child: SizedBox(
                        width: screenW,
                        height: stackH,
                        child: ClipRect(
                          // Fade the tiles themselves to transparent so the page
                          // gradient shows through (no mismatched overlay colour).
                          child: ShaderMask(
                            blendMode: BlendMode.dstIn,
                            shaderCallback: (rect) => LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0, 0.6, 1],
                              colors: [
                                AppColors.surface,
                                AppColors.surface,
                                AppColors.surface.withValues(alpha: 0),
                              ],
                            ).createShader(rect),
                            child: Stack(
                              children: [
                                tile(0, leftX, 0),
                                tile(1, rx, off),
                                tile(2, leftX, tileH + gap),
                                tile(3, rx, off + tileH + gap),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeTransition(
                opacity: _controller,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    l10n.welcomeTitle,
                    style: AppTextStyles.h1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          FractionallySizedBox(
            widthFactor: AppSpacing.welcomeButtonWidthFactor,
            child: AppButton(
              key: const Key('letsExploreButton'),
              label: l10n.letsExploreButton,
              onPressed: () => context.go('/home'),
            ),
          ),
        ],
      ),
    );
  }
}
