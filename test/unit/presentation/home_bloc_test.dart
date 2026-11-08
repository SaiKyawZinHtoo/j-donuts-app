import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/features/home/home_import.dart';

class MockGetHomeUseCase extends Mock implements GetHomeUseCase {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockGetHomeUseCase mockGetHome;
  late MockConnectivityService mockConnectivity;

  final testBundle = HomeBundle(
    member: const Member(
      id: 'm1',
      name: 'Shan',
      photoUrl: 'https://example.com/photo.png',
      tier: 'Gold',
      points: 100,
      nextTierPoints: 200,
      totalPoints: 100,
    ),
    banners: const [],
    sections: const [],
    shops: const [],
  );

  setUp(() {
    mockGetHome = MockGetHomeUseCase();
    mockConnectivity = MockConnectivityService();
    when(() => mockConnectivity.onStatusChanged)
        .thenAnswer((_) => const Stream<bool>.empty());
    when(() => mockConnectivity.isOnline()).thenAnswer((_) async => true);
  });

  HomeBloc build() =>
      HomeBloc(getHomeUseCase: mockGetHome, connectivity: mockConnectivity);

  blocTest<HomeBloc, HomeState>(
    'emits HomeLoading then HomeLoaded on HomeRequested',
    setUp: () {
      when(() => mockGetHome.call())
          .thenAnswer((_) async => Result.ok(testBundle));
    },
    build: build,
    act: (bloc) => bloc.add(const HomeRequested()),
    expect: () => [isA<HomeLoading>(), isA<HomeLoaded>()],
  );

  blocTest<HomeBloc, HomeState>(
    'emits HomeLoading then HomeError when the use case fails',
    setUp: () {
      when(() => mockGetHome.call())
          .thenAnswer((_) async => const Result.err('boom'));
    },
    build: build,
    act: (bloc) => bloc.add(const HomeRequested()),
    expect: () => [isA<HomeLoading>(), isA<HomeError>()],
  );

  blocTest<HomeBloc, HomeState>(
    'HomeLoaded.isOffline is true when connectivity reports offline',
    setUp: () {
      when(() => mockConnectivity.isOnline()).thenAnswer((_) async => false);
      when(() => mockGetHome.call())
          .thenAnswer((_) async => Result.ok(testBundle));
    },
    build: build,
    act: (bloc) => bloc.add(const HomeRequested()),
    expect: () => [
      isA<HomeLoading>(),
      isA<HomeLoaded>().having((s) => s.isOffline, 'isOffline', true),
    ],
  );
}
