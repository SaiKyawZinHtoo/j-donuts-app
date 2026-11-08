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
  });

  final String asset;
  final Color circleColor;
  final double size;
  final Animation<double> animation;
  final Offset slideFrom;

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: slideFrom,
        end: Offset.zero,
      ).animate(animation),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    ),
  );
}
