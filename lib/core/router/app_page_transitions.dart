import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:j_donuts_app/core/core_import.dart';

class AppPageTransitions {
  AppPageTransitions._();

  /// Fade + horizontal slide-in for auth steps (spec §10). Plain child when
  /// the user has animations disabled.
  static CustomTransitionPage<T> sharedAxisX<T>(
    GoRouterState state,
    Widget child, {
    bool reduceMotion = false,
  }) => CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: reduceMotion
        ? Duration.zero
        : MotionTokens.kStepTransitionDuration,
    reverseTransitionDuration: reduceMotion
        ? Duration.zero
        : MotionTokens.kStepTransitionDuration,
    transitionsBuilder: (context, animation, secondary, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      final curved = CurvedAnimation(
        parent: animation,
        curve: MotionTokens.kEmphasizedCurve,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(
              AppSpacing.stepSlideOffset / MediaQuery.sizeOf(context).width,
              0,
            ),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
