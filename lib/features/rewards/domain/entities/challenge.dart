part of '../../rewards_import.dart';

/// A loyalty challenge/mission (design spec §6.3).
class Challenge {
  final String id;
  final String title;
  final int current;
  final int target;
  final int rewardPts;
  final String artType;

  const Challenge({
    required this.id,
    required this.title,
    required this.current,
    required this.target,
    required this.rewardPts,
    required this.artType,
  });

  bool get isComplete => current >= target;
}
