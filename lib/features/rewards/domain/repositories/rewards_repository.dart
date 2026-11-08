part of '../../rewards_import.dart';

/// Everything the rewards screen needs in one call.
class RewardsBundle {
  final Member member;
  final List<Challenge> challenges;

  const RewardsBundle({
    required this.member,
    required this.challenges,
  });
}

abstract class RewardsRepository {
  Future<Result<RewardsBundle>> getRewards();
}
