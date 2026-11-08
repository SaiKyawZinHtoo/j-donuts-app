import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/auth_dao.dart';
import 'daos/home_dao.dart';
import 'daos/member_dao.dart';
import 'daos/product_dao.dart';
import 'daos/rewards_dao.dart';
import 'tables/auth_users_table.dart';
import 'tables/banners_table.dart';
import 'tables/challenges_table.dart';
import 'tables/member_table.dart';
import 'tables/meta_table.dart';
import 'tables/products_table.dart';
import 'tables/sections_table.dart';
import 'tables/shops_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Products,
    Banners,
    Sections,
    SectionsProducts,
    Shops,
    Member,
    Challenges,
    AuthUsers,
    Meta,
  ],
  daos: [ProductDao, HomeDao, MemberDao, RewardsDao, AuthDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
      );
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = p.join(dbFolder.path, 'j_donuts_app.sqlite');
    return NativeDatabase.createInBackground(File(file));
  });
}
