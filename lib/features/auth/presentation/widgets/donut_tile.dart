part of '../../auth_import.dart';

/// Circular donut photo that slides from [slideFrom] (fraction of its own
/// size) to rest while fading in, driven by [animation].
class DonutTile extends StatelessWidget {
  const DonutTile({
    super.key,
    required this.asset,
    required this.circleColor,
    required this.size,
    required this.animation,
    required this.slideFrom,
    this.shape = BoxShape.circle,
    this.width,
    this.radius,
  });

  final String asset;
  final Color circleColor;
  final double size;
  final Animation<double> animation;
  final Offset slideFrom;
  final BoxShape shape;

  /// Optional width for rectangles ([size] is then the height).
  final double? width;
  final double? radius;

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: slideFrom,
        end: Offset.zero,
      ).animate(animation),
      child: Container(
        width: width ?? size,
        height: size,
        decoration: BoxDecoration(
          color: circleColor,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle && radius != null
              ? BorderRadius.circular(radius!)
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    ),
  );
}
