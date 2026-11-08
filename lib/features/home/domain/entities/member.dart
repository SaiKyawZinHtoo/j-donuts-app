part of '../../home_import.dart';

/// The current member's profile and loyalty state (design spec §3.2).
class Member {
  final String id;
  final String name;
  final String photoUrl;
  final String tier;
  final int points;
  final int nextTierPoints;
  final int totalPoints;

  const Member({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.tier,
    required this.points,
    required this.nextTierPoints,
    required this.totalPoints,
  });
}
