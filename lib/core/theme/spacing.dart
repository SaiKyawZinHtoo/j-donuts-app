part of '../core_import.dart';

/// Spacing scale. Widgets must read from here, never literal values.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  // Widget sizing tokens.
  static const double buttonHeight = 56;
  static const double buttonRadius = 28;
  static const double fieldRadius = 12;
  static const double backButtonSize = 44;
  static const double authHorizontalPadding = 24;
  static const double ringSize = 40;
  static const double ringStrokeRatio = 0.3;
  static const double appBarHeight = 56;
  static const double otpBoxWidth = 44;
  static const double otpBoxHeight = 52;
  static const double iconSizeMd = 48;
  static const double progressRingSize = 64;
  static const double progressRingInset = 4;
  static const double progressRingStrokeWidth = 6;
  static const double splashLogoSize = 160;
  static const double stepSlideOffset = 30;
  static const double entranceRise = 16;
  static const double logoCircleSize = 72;
  // Welcome tile grid: right column drop, tile radius, stack height fraction.
  static const double welcomeTileOffset = 48;
  static const double welcomeTileRadius = 28;
  static const double welcomeStackFraction = 0.6;
  // Tile width and right-column x as screen-width fractions; left bleed as tile-width fraction.
  static const double welcomeTileWidthFraction = 0.53;
  static const double welcomeRightColumnFraction = 0.62;
  static const double welcomeTileBleedFraction = 0;
  // Reference tile height / width, and how much of the 2nd row shows before the fade.
  static const double welcomeTileAspect = 1.46;
  static const double welcomeSecondRowVisible = 0.82;
  static const double logoCirclePadding = 12;
  static const double onboardingTilesFraction = 0.55;
  static const double onboardingTilesMinFraction = 0.45;
  static const double onboardingContentHeight = 520;
  static const double navBarHeight = 64;
  static const double navItemSize = 24;
  static const double navSelectedFlex =
      2.3; // selected slot width vs 1 for others
  static const double bannerViewportFraction = 0.88; // next banner peeks
  static const double headerBadgeSize = 56;
  static const double rewardCardRadius = 28;
  static const double rewardArtSize = 96;
  static const double tierRowHeight = 96;
  static const double tierBadgeSize = 44;
  static const double navBarTopRadius = 32;
  static const double authTitleTopGap = 24;
  static const double cardRadius = 20;
  static const double sectionGap = 24;
  static const double headerRadius = 32;
  static const double qtyPillHeight = 56;
  static const double cardPhotoWidth = 320;
  static const double cardCutoutWidth = 215;
  static const double cardPhotoAspect = 1.5; // w/h
  static const double cardCutoutAspect = 0.67; // w/h
  static const double chevronButtonSize = 40;

  // Fixed content sizes (were literals in widgets).
  static const double productImageHeight = 280;
  static const double shopsListHeight = 270;
  static const double shopCardWidth = 260;
  static const double shopCardImageHeight = 120;
  static const double bannerHeight = 160;
  static const double datePickerSheetHeight = 300;
  static const double skeletonPlaceholderHeight = 400;
  static const double inlineSpinnerSize = 20;
  static const double socialIconSize = 28;
  // Where the Onboarding donut cluster starts fading out (0..1 of its height).
  static const double onboardingFadeStart = 0.6;
  // Gap between the status bar and the auth header row (back button / ring).
  static const double authHeaderTopGap = 16;
  // Share of the available width the Welcome button takes.
  static const double welcomeButtonWidthFactor = 0.8;
}
