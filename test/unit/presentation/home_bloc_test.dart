import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/features/home/home_import.dart';

class MockGetHomeUseCase extends Mock implements GetHomeUseCase {}

class MockSync extends Mock implements SyncRepository {}

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

  group('background sync', () {
    late MockSync sync;
    late StreamController<bool> online;

    setUp(() {
      sync = MockSync();
      online = StreamController<bool>();
      when(() => mockConnectivity.onStatusChanged).thenAnswer((_) => online.stream);
      when(() => mockGetHome.call()).thenAnswer((_) async => Result.ok(testBundle));
      when(() => sync.lastSyncedAt()).thenAnswer((_) async => null);
      when(() => sync.refresh()).thenAnswer((_) async => const Result.ok(SyncOutcome.updated));
    });
    tearDown(() => online.close());

    HomeBloc buildSync() => HomeBloc(
      getHomeUseCase: mockGetHome,
      connectivity: mockConnectivity,
      syncRepository: sync,
    );

    blocTest<HomeBloc, HomeState>(
      'launch: renders DB first, then a second HomeLoaded without HomeLoading',
      build: buildSync,
      act: (b) => b.add(const HomeRequested()),
      expect: () => [isA<HomeLoading>(), isA<HomeLoaded>(), isA<HomeLoaded>()],
      verify: (_) => verify(() => sync.refresh()).called(1),
    );

    blocTest<HomeBloc, HomeState>(
      'failed sync emits nothing extra and keeps data',
      setUp: () => when(() => sync.refresh()).thenAnswer((_) async => const Result.err('network')),
      build: buildSync,
      act: (b) => b.add(const HomeRequested()),
      expect: () => [isA<HomeLoading>(), isA<HomeLoaded>()],
    );

    blocTest<HomeBloc, HomeState>(
      'pull-to-refresh never emits HomeLoading and completes the callback',
      build: buildSync,
      seed: () => HomeLoaded(testBundle, false),
      act: (b) async {
        final done = Completer<void>();
        b.add(HomeRefreshRequested(done: done));
        await done.future;
      },
      expect: () => [isA<HomeLoaded>()],
    );

    blocTest<HomeBloc, HomeState>(
      'offline then online triggers exactly one refresh',
      build: buildSync,
      seed: () => HomeLoaded(testBundle, false),
      act: (b) async {
        online.add(false);
        await Future<void>.delayed(Duration.zero);
        online.add(true);
        await Future<void>.delayed(const Duration(milliseconds: 20));
      },
      verify: (_) => verify(() => sync.refresh()).called(1),
    );

    blocTest<HomeBloc, HomeState>(
      'null syncRepository behaves as before',
      build: build,
      act: (b) => b.add(const HomeRequested()),
      expect: () => [isA<HomeLoading>(), isA<HomeLoaded>()],
    );
  });
}
