// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewards_dao.dart';

// ignore_for_file: type=lint
mixin _$RewardsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChallengesTable get challenges => attachedDatabase.challenges;
  RewardsDaoManager get managers => RewardsDaoManager(this);
}

class RewardsDaoManager {
  final _$RewardsDaoMixin _db;
  RewardsDaoManager(this._db);
  $$ChallengesTableTableManager get challenges =>
      $$ChallengesTableTableManager(_db.attachedDatabase, _db.challenges);
}
