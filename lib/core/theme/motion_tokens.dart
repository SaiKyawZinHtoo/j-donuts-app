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
}
