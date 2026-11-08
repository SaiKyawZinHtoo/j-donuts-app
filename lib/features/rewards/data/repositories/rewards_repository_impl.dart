part of '../../rewards_import.dart';

/// Reads the rewards bundle from the local Drift database via [RewardsDao]
/// and [MemberDao], mapping Drift rows to domain entities.
class RewardsRepositoryImpl implements RewardsRepository {
  final drift.RewardsDao _rewardsDao;
  final drift.MemberDao _memberDao;

  const RewardsRepositoryImpl({
    required drift.RewardsDao rewardsDao,
    required drift.MemberDao memberDao,
  })  : _rewardsDao = rewardsDao,
        _memberDao = memberDao;

  @override
  Future<Result<RewardsBundle>> getRewards() async {
    try {
      final memberRow = await _memberDao.watchMember().first;
      if (memberRow == null) {
        return const Result.err('No member profile found.');
      }
      final challengeRows = await _rewardsDao.getChallenges();

      return Result.ok(
        RewardsBundle(
          member: mapMemberRow(memberRow),
          challenges: challengeRows.map(_mapChallenge).toList(),
        ),
      );
    } catch (e) {
      return Result.err('Failed to load rewards data: $e');
    }
  }

  Challenge _mapChallenge(drift.Challenge row) => Challenge(
        id: row.id,
        title: row.title,
        current: row.current,
        target: row.target,
        rewardPts: row.rewardPts,
        artType: row.artType,
      );
}
