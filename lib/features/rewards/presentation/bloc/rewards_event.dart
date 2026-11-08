part of '../../rewards_import.dart';

enum RewardsTab { earn, gift }

sealed class RewardsEvent {
  const RewardsEvent();
}

final class RewardsRequested extends RewardsEvent {
  const RewardsRequested();
}

final class TabChanged extends RewardsEvent {
  final RewardsTab tab;
  const TabChanged(this.tab);
}

final class ChallengeTapped extends RewardsEvent {
  final String id;
  const ChallengeTapped(this.id);
}
