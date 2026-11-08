import 'package:drift/drift.dart';

import 'package:j_donuts_app/data/local/database.dart';
import 'package:j_donuts_app/data/local/tables/challenges_table.dart';

part 'rewards_dao.g.dart';

@DriftAccessor(tables: [Challenges])
class RewardsDao extends DatabaseAccessor<AppDatabase> with _$RewardsDaoMixin {
  RewardsDao(super.db);

  Future<List<Challenge>> getChallenges() => select(challenges).get();
}
