import 'package:drift/drift.dart';

import 'package:j_donuts_app/data/local/database.dart';
import 'package:j_donuts_app/data/local/tables/auth_users_table.dart';

part 'auth_dao.g.dart';

@DriftAccessor(tables: [AuthUsers])
class AuthDao extends DatabaseAccessor<AppDatabase> with _$AuthDaoMixin {
  AuthDao(super.db);

  Future<AuthUser?> findByPhone(String phone) =>
      (select(authUsers)..where((u) => u.phone.equals(phone)))
          .getSingleOrNull();

  Future<int> insertUser(AuthUsersCompanion user) =>
      into(authUsers).insert(user);
}
