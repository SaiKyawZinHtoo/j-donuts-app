part of '../core_import.dart';

/// Shimmer-style skeleton loader. Shows [child] when not loading, otherwise
/// an animated placeholder overlay of the same shape.
class AppSkeleton extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const AppSkeleton({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Opacity(
          opacity: 0.4 + 0.3 * _controller.value,
          child: ColoredBox(
            color: AppColors.border,
            child: Opacity(opacity: 0, child: widget.child),
          ),
        );
      },
    );
  }
}
