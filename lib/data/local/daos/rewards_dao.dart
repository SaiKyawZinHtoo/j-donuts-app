import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/challenges_table.dart';

part 'rewards_dao.g.dart';

@DriftAccessor(tables: [Challenges])
class RewardsDao extends DatabaseAccessor<AppDatabase> with _$RewardsDaoMixin {
  RewardsDao(super.db);

  Future<List<Challenge>> getChallenges() => select(challenges).get();
}
