part of '../../home_import.dart';

/// A home-screen promo banner.
class BannerItem {
  final String id;
  final String imageUrl;
  final String title;
  final String deepLinkTarget;
  final String? badge;

  const BannerItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.deepLinkTarget,
    this.badge,
  });
}
