part of '../../home_import.dart';

/// Everything the home screen needs in one call.
class HomeBundle {
  final Member member;
  final List<BannerItem> banners;
  final List<ProductSection> sections;
  final List<Shop> shops;

  const HomeBundle({
    required this.member,
    required this.banners,
    required this.sections,
    required this.shops,
  });
}

abstract class HomeRepository {
  Future<Result<HomeBundle>> getHome();
}
