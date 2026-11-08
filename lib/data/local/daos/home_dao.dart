import 'package:drift/drift.dart';

import 'package:j_donuts_app/data/local/database.dart';
import 'package:j_donuts_app/data/local/tables/banners_table.dart';
import 'package:j_donuts_app/data/local/tables/member_table.dart';
import 'package:j_donuts_app/data/local/tables/sections_table.dart';
import 'package:j_donuts_app/data/local/tables/shops_table.dart';
import 'package:j_donuts_app/data/local/tables/products_table.dart';

part 'home_dao.g.dart';

/// A section plus its ordered products, as returned by [HomeDao.getHome].
class SectionWithProducts {
  final Section section;
  final List<Product> products;

  SectionWithProducts(this.section, this.products);
}

/// Everything the home screen needs in a single DAO call.
class HomeBundle {
  final MemberData? member;
  final List<Banner> banners;
  final List<SectionWithProducts> sections;
  final List<Shop> shops;

  HomeBundle({
    required this.member,
    required this.banners,
    required this.sections,
    required this.shops,
  });
}

@DriftAccessor(tables: [Member, Banners, Sections, SectionsProducts, Products, Shops])
class HomeDao extends DatabaseAccessor<AppDatabase> with _$HomeDaoMixin {
  HomeDao(super.db);

  Future<HomeBundle> getHome() async {
    final memberRow = await select(member).getSingleOrNull();
    final bannerRows = await select(banners).get();
    final shopRows = await select(shops).get();

    final sectionRows = await select(sections).get();
    final sectionsWithProducts = <SectionWithProducts>[];
    for (final section in sectionRows) {
      final query = select(products).join([
        innerJoin(
          sectionsProducts,
          sectionsProducts.productId.equalsExp(products.id),
        ),
      ])
        ..where(sectionsProducts.sectionId.equals(section.id))
        ..orderBy([OrderingTerm.asc(sectionsProducts.sortOrder)]);
      final rows = await query.get();
      final sectionProducts = rows.map((r) => r.readTable(products)).toList();
      sectionsWithProducts.add(SectionWithProducts(section, sectionProducts));
    }

    return HomeBundle(
      member: memberRow,
      banners: bannerRows,
      sections: sectionsWithProducts,
      shops: shopRows,
    );
  }
}
