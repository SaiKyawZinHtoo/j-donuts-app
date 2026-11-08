part of '../core_import.dart';

/// Renders [url] via [CachedNetworkImage] when it's a real network URL, or
/// via [Image.asset] when it's a local asset path (seed data ships local
/// asset paths, which CachedNetworkImage can never load).
class AppSmartImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext context)? placeholder;
  final Widget Function(BuildContext context)? errorWidget;

  const AppSmartImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  bool get _isNetwork => url.startsWith('http://') || url.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        width: width,
        height: height,
        placeholder: placeholder == null ? null : (context, _) => placeholder!(context),
        errorWidget: errorWidget == null ? null : (context, _, _) => errorWidget!(context),
      );
    }
    return Image.asset(
      url,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: errorWidget == null ? null : (context, _, _) => errorWidget!(context),
    );
  }
}
