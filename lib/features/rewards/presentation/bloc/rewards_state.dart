part of '../../rewards_import.dart';

sealed class RewardsState {
  const RewardsState();
}

final class RewardsLoading extends RewardsState {
  const RewardsLoading();
}

final class RewardsLoaded extends RewardsState {
  final RewardsBundle data;
  final RewardsTab activeTab;

  const RewardsLoaded(this.data, this.activeTab);
}

final class RewardsError extends RewardsState {
  final String message;
  const RewardsError(this.message);
}
