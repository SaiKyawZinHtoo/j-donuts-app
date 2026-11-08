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
    expect(sections.map((s) => s.id), containsAll(<String>[
      'seasonal_specials',
      'popular',
      'order_again',
    ]));

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
}
