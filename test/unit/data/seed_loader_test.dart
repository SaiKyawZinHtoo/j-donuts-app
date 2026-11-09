import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donuts_app/data/local/database.dart';
import 'package:j_donuts_app/data/local/seed/seed_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('seedIfNeeded populates products table exactly once', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await SeedLoader(db).seedIfNeeded();
    final first = await db.select(db.products).get();
    await SeedLoader(db).seedIfNeeded(); // second call must not duplicate
    final second = await db.select(db.products).get();
    expect(first, isNotEmpty);
    expect(second.length, first.length);
  });

  test('seedIfNeeded populates member, sections, shops, and banners', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await SeedLoader(db).seedIfNeeded();

    final member = await db.select(db.member).getSingle();
    expect(member.tier, 'Bronze');
    expect(member.nextTierPoints - member.points, 500);

    final sections = await db.select(db.sections).get();
    expect(
      sections.map((s) => s.id),
      containsAll(<String>['seasonal_specials', 'popular', 'order_again']),
    );

    final shops = await db.select(db.shops).get();
    expect(shops.length, 4);

    final banners = await db.select(db.banners).get();
    expect(banners, isNotEmpty);

    final challenges = await db.select(db.challenges).get();
    expect(challenges.length, greaterThanOrEqualTo(3));
    expect(
      challenges.any((c) => c.current == c.target),
      isTrue,
      reason: 'expected at least one completed challenge (4/4 coco donuts)',
    );
  });

  test('home DAO joins sections, products, member and shops', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await SeedLoader(db).seedIfNeeded();

    final home = await db.homeDao.getHome();
    expect(home.member, isNotNull);
    expect(home.banners, isNotEmpty);
    expect(home.shops, isNotEmpty);
    expect(home.sections, isNotEmpty);
    expect(home.sections.first.products, isNotEmpty);
  });

  test(
    'old seed marker triggers wipe and reseed, keeping auth users',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db
          .into(db.meta)
          .insert(MetaCompanion.insert(key: 'seeded', value: 'true'));
      await db
          .into(db.products)
          .insert(
            ProductsCompanion.insert(
              id: 'p_stale',
              code: 'X',
              name: 'Stale',
              priceMmk: 1,
              imageUrl: 'x',
            ),
          );
      await db
          .into(db.authUsers)
          .insert(
            AuthUsersCompanion.insert(
              id: 'u1',
              phone: '0900',
              firstName: 'A',
              lastName: 'B',
              dob: DateTime(2000),
              createdAt: DateTime(2020),
            ),
          );

      await SeedLoader(db).seedIfNeeded();

      final ids = (await db.select(db.products).get()).map((p) => p.id);
      expect(ids, isNot(contains('p_stale')));
      expect(ids, contains('p_box_romance'));
      expect((await db.select(db.member).getSingle()).tier, 'Bronze');
      final marker = await (db.select(
        db.meta,
      )..where((m) => m.key.equals('seeded'))).getSingle();
      expect(marker.value, '5');
      expect(await db.select(db.authUsers).get(), hasLength(1));
    },
  );
}
