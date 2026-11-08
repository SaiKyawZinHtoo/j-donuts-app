part of '../core_import.dart';

/// Vertical pink-to-white brand gradient behind a screen.
class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.gradientColors,
            stops: AppColors.gradientStops,
          ),
        ),
        child: child,
      );
}
