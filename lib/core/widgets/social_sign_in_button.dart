part of '../core_import.dart';

/// Icon-only social sign-in button (Google / Apple / Facebook). Renders an SVG
/// or a raster asset depending on the file extension; [label] is the
/// tooltip and the screen-reader label.
class SocialSignInButton extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback onPressed;

  const SocialSignInButton({
    super.key,
    required this.asset,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const size = AppSpacing.socialIconSize;
    final icon = asset.endsWith('.svg')
        ? SvgPicture.asset(
            asset,
            width: size,
            height: size,
            excludeFromSemantics: true,
          )
        : Image.asset(
            asset,
            width: size,
            height: size,
            excludeFromSemantics: true,
          );
    return IconButton(
      tooltip: label,
      onPressed: onPressed,
      iconSize: size,
      icon: icon,
    );
  }
}
