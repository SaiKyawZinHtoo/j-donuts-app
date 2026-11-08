import 'package:drift/drift.dart';

import 'package:j_donuts_app/data/local/database.dart';
import 'package:j_donuts_app/data/local/tables/member_table.dart';

part 'member_dao.g.dart';

@DriftAccessor(tables: [Member])
class MemberDao extends DatabaseAccessor<AppDatabase> with _$MemberDaoMixin {
  MemberDao(super.db);

  Stream<MemberData?> watchMember() => select(member).watchSingleOrNull();
}
