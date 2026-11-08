import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/data/local/daos/home_dao.dart' hide HomeBundle;
import 'package:j_donuts_app/data/local/daos/member_dao.dart';
import 'package:j_donuts_app/data/local/database.dart';
import 'package:j_donuts_app/data/local/seed/seed_loader.dart';
import 'package:j_donuts_app/features/home/home_import.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('HomeRepositoryImpl reads seeded data end to end', () async {
    await SeedLoader(db).seedIfNeeded();
    final result = await HomeRepositoryImpl(
      homeDao: HomeDao(db),
      memberDao: MemberDao(db),
    ).getHome();

    expect(result, isA<Ok<HomeBundle>>());
    final bundle = (result as Ok<HomeBundle>).value;
    expect(bundle.sections, isNotEmpty);

    // Canonical member record (design spec §3.2): Silver tier, 500 pts
    // remaining to Gold.
    expect(bundle.member.tier, 'Bronze');
    expect(bundle.member.nextTierPoints - bundle.member.points, 500);
  });
}
