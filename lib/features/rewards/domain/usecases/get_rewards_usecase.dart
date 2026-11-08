part of '../../rewards_import.dart';

class GetRewardsUseCase {
  final RewardsRepository _repository;

  const GetRewardsUseCase(this._repository);

  Future<Result<RewardsBundle>> call() => _repository.getRewards();
}
