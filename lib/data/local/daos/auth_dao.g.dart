// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dao.dart';

// ignore_for_file: type=lint
mixin _$AuthDaoMixin on DatabaseAccessor<AppDatabase> {
  $AuthUsersTable get authUsers => attachedDatabase.authUsers;
  AuthDaoManager get managers => AuthDaoManager(this);
}

class AuthDaoManager {
  final _$AuthDaoMixin _db;
  AuthDaoManager(this._db);
  $$AuthUsersTableTableManager get authUsers =>
      $$AuthUsersTableTableManager(_db.attachedDatabase, _db.authUsers);
}
