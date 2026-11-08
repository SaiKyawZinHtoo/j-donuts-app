part of '../../home_import.dart';

/// Reads the home bundle from the local Drift database via [HomeDao] and
/// [MemberDao], mapping Drift rows to domain entities.
class HomeRepositoryImpl implements HomeRepository {
  final drift.HomeDao _homeDao;
  final drift.MemberDao _memberDao;

  const HomeRepositoryImpl({
    required drift.HomeDao homeDao,
    required drift.MemberDao memberDao,
  })  : _homeDao = homeDao,
        _memberDao = memberDao;

  @override
  Future<Result<HomeBundle>> getHome() async {
    try {
      final bundle = await _homeDao.getHome();
      final memberRow = bundle.member ?? await _memberDao.watchMember().first;
      if (memberRow == null) {
        return const Result.err('No member profile found.');
      }

      return Result.ok(
        HomeBundle(
          member: mapMemberRow(memberRow),
          banners: bundle.banners.map(_mapBanner).toList(),
          sections: bundle.sections.map(_mapSection).toList(),
          shops: bundle.shops.map(_mapShop).toList(),
        ),
      );
    } catch (e) {
      return Result.err('Failed to load home data: $e');
    }
  }

  BannerItem _mapBanner(drift.Banner row) => BannerItem(
        id: row.id,
        imageUrl: row.imageUrl,
        title: row.title,
        deepLinkTarget: row.deepLinkTarget,
      );

  ProductSection _mapSection(drift.SectionWithProducts row) => ProductSection(
        id: row.section.id,
        title: row.section.title,
        products: row.products.map(mapProductRow).toList(),
      );

  Shop _mapShop(drift.Shop row) => Shop(
        id: row.id,
        name: row.name,
        address: row.address,
        distanceLabel: row.distanceLabel,
      );
}

/// Shared with [RewardsRepositoryImpl], which also reads [MemberDao] rows.
Member mapMemberRow(drift.MemberData row) => Member(
      id: row.id,
      name: row.name,
      photoUrl: row.photoUrl,
      tier: row.tier,
      points: row.points,
      nextTierPoints: row.nextTierPoints,
      totalPoints: row.totalPoints,
    );
