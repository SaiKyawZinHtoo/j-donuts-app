part of '../../auth_import.dart';

/// Overlapping tile circle. [size] is a fraction of the cluster unit
/// (min of screen width and cluster height); [cx] a fraction of the screen
/// width and [cy] of the cluster height (circle centre). Listed in paint
/// order, so the hero is last.
class TileSpec {
  const TileSpec(
    this.asset,
    this.color,
    this.size,
    this.cx,
    this.cy,
    this.slideFrom,
  );
  final String asset;
  final Color color;
  final double size;
  final double cx;
  final double cy;
  final Offset slideFrom;
}

const kOnboardingTiles = [
  TileSpec(
    'assets/images/seed/tile_1.png',
    AppColors.tileCyan,
    0.62,
    0.08,
    0.30,
    Offset(-0.5, 0),
  ),
  TileSpec(
    'assets/images/seed/tile_2.png',
    AppColors.tileBlue,
    0.55,
    0.96,
    0.22,
    Offset(0.5, 0),
  ),
  TileSpec(
    'assets/images/seed/tile_3.png',
    AppColors.tilePurple,
    0.50,
    0.12,
    0.80,
    Offset(-0.5, 0.3),
  ),
  TileSpec(
    'assets/images/seed/donut_strawberry.png',
    AppColors.tileBeige,
    0.64,
    0.50,
    0.46,
    Offset(0, -0.4),
  ),
];

/// Height of the donut cluster for a screen of [maxHeight]; shared with the
/// splash so its last frame lines up with this screen.
double onboardingClusterHeight(double maxHeight) =>
    (maxHeight - AppSpacing.onboardingContentHeight).clamp(
      AppSpacing.onboardingTilesMinFraction * maxHeight,
      AppSpacing.onboardingTilesFraction * maxHeight,
    );
