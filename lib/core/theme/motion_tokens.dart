part of '../core_import.dart';

/// Animation durations/curves shared across the app (spec §6.2).
class MotionTokens {
  MotionTokens._();

  static const Duration kPointsRingDuration = Duration(milliseconds: 800);
  static const Duration kTabSwitchDuration = Duration(milliseconds: 250);
  static const Duration kStaggerStep = Duration(milliseconds: 60);
  static const Curve kEmphasizedCurve = Curves.easeInOutCubicEmphasized;

  static const Duration kShimmerDuration = Duration(milliseconds: 1200);
  static const double kShimmerOpacityBase = 0.4;
  static const double kShimmerOpacityRange = 0.3;

  static const Duration kShakeDuration = Duration(milliseconds: 400);

  static const Duration kBannerAutoplayInterval = Duration(seconds: 4);
  static const Duration kPressScaleDuration = Duration(milliseconds: 100);

  static const Duration kSplashLogoDuration = Duration(milliseconds: 900);
  static const Duration kSplashHoldDuration = Duration(milliseconds: 700);
  static const Duration kSplashExitDuration = Duration(milliseconds: 500);
  static const Duration kTileDriftDuration = Duration(milliseconds: 900);
  static const Duration kStepTransitionDuration = Duration(milliseconds: 350);
  static const Duration kRingStepDuration = Duration(milliseconds: 400);
  static const Duration kButtonMorphDuration = Duration(milliseconds: 250);
  static const Duration kHomeSectionStagger = Duration(milliseconds: 80);
  static const Duration kNavPillDuration = Duration(milliseconds: 250);
  static const Duration kHeroDuration = Duration(milliseconds: 350);
}
