import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/features/home/home_import.dart';
import 'package:j_donuts_app/features/rewards/rewards_import.dart';

class MockRewardsRepository extends Mock implements RewardsRepository {}

void main() {
  test('GetRewardsUseCase returns Ok with member and challenges', () async {
    final repo = MockRewardsRepository();
    final testBundle = RewardsBundle(
      member: const Member(
        id: 'm1',
        name: 'Shan',
        photoUrl: '',
        tier: 'Silver',
        points: 100,
        nextTierPoints: 500,
        totalPoints: 100,
      ),
      challenges: const [
        Challenge(
          id: 'c1',
          title: 'Buy 3 donuts',
          current: 1,
          target: 3,
          rewardPts: 50,
          artType: 'donut',
        ),
      ],
    );
    when(() => repo.getRewards()).thenAnswer((_) async => Result.ok(testBundle));

    final result = await GetRewardsUseCase(repo).call();

    expect(result, isA<Ok<RewardsBundle>>());
  });
}
