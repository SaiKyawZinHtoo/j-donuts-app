import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/features/home/home_import.dart';
import 'package:j_donuts_app/features/rewards/rewards_import.dart';

class MockGetRewardsUseCase extends Mock implements GetRewardsUseCase {}

void main() {
  late MockGetRewardsUseCase mockGetRewards;

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
      Challenge(id: 'c1', title: 'Buy 3', current: 3, target: 3, rewardPts: 50, artType: 'donut'),
    ],
  );

  setUp(() {
    mockGetRewards = MockGetRewardsUseCase();
  });

  RewardsBloc build() => RewardsBloc(getRewardsUseCase: mockGetRewards);

  blocTest<RewardsBloc, RewardsState>(
    'emits RewardsLoading then RewardsLoaded on RewardsRequested',
    setUp: () {
      when(() => mockGetRewards.call()).thenAnswer((_) async => Result.ok(testBundle));
    },
    build: build,
    act: (bloc) => bloc.add(const RewardsRequested()),
    expect: () => [isA<RewardsLoading>(), isA<RewardsLoaded>()],
  );

  blocTest<RewardsBloc, RewardsState>(
    'emits RewardsLoading then RewardsError when the use case fails',
    setUp: () {
      when(() => mockGetRewards.call()).thenAnswer((_) async => const Result.err('boom'));
    },
    build: build,
    act: (bloc) => bloc.add(const RewardsRequested()),
    expect: () => [isA<RewardsLoading>(), isA<RewardsError>()],
  );

  blocTest<RewardsBloc, RewardsState>(
    'TabChanged updates activeTab without refetching',
    setUp: () {
      when(() => mockGetRewards.call()).thenAnswer((_) async => Result.ok(testBundle));
    },
    build: build,
    act: (bloc) async {
      bloc.add(const RewardsRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const TabChanged(RewardsTab.gift));
    },
    verify: (bloc) {
      verify(() => mockGetRewards.call()).called(1);
    },
    expect: () => [
      isA<RewardsLoading>(),
      isA<RewardsLoaded>(),
      isA<RewardsLoaded>().having((s) => s.activeTab, 'activeTab', RewardsTab.gift),
    ],
  );
}
