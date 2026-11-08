part of '../core_import.dart';

/// Animation durations/curves shared across the app (spec §6.2).
class MotionTokens {
  MotionTokens._();

  static const Duration kPointsRingDuration = Duration(milliseconds: 800);
  static const Duration kTabSwitchDuration = Duration(milliseconds: 250);
  static const Duration kStaggerStep = Duration(milliseconds: 60);
  static const Curve kEmphasizedCurve = Curves.easeInOutCubicEmphasized;
}
