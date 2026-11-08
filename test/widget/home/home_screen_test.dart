import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/features/home/home_import.dart';

class MockGetHomeUseCase extends Mock implements GetHomeUseCase {}

class MockConnectivityService extends Mock implements ConnectivityService {}

Widget makeTestableWidget(HomeBloc bloc) {
  final router = GoRouter(
    initialLocation: '/__test__',
    routes: [
      GoRoute(path: '/__test__', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) => Scaffold(body: Text('Product ${state.pathParameters['id']}')),
      ),
    ],
  );
  return MaterialApp.router(
    routerConfig: router,
    builder: (context, child) => BlocProvider<HomeBloc>.value(value: bloc, child: child!),
  );
}

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
    sections: const [
      ProductSection(id: 's1', title: 'Popular', productIds: ['p1', 'p2']),
    ],
    shops: const [
      Shop(id: 'sh1', name: 'Downtown', address: '123 Main St', distanceLabel: '1.2 km'),
    ],
  );

  setUp(() {
    mockGetHome = MockGetHomeUseCase();
    mockConnectivity = MockConnectivityService();
    when(() => mockConnectivity.onStatusChanged).thenAnswer((_) => const Stream<bool>.empty());
  });

  testWidgets('shows offline banner when HomeLoaded.isOffline is true', (tester) async {
    when(() => mockConnectivity.isOnline()).thenAnswer((_) async => false);
    when(() => mockGetHome.call()).thenAnswer((_) async => Result.ok(testBundle));

    final bloc = HomeBloc(getHomeUseCase: mockGetHome, connectivity: mockConnectivity)
      ..add(const HomeRequested());

    await tester.pumpWidget(makeTestableWidget(bloc));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('homeOfflineBanner')), findsOneWidget);
  });

  testWidgets('does not show offline banner when HomeLoaded.isOffline is false', (tester) async {
    when(() => mockConnectivity.isOnline()).thenAnswer((_) async => true);
    when(() => mockGetHome.call()).thenAnswer((_) async => Result.ok(testBundle));

    final bloc = HomeBloc(getHomeUseCase: mockGetHome, connectivity: mockConnectivity)
      ..add(const HomeRequested());

    await tester.pumpWidget(makeTestableWidget(bloc));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('homeOfflineBanner')), findsNothing);
  });

  testWidgets('tapping a product tile navigates to /product/:id', (tester) async {
    when(() => mockConnectivity.isOnline()).thenAnswer((_) async => true);
    when(() => mockGetHome.call()).thenAnswer((_) async => Result.ok(testBundle));

    final bloc = HomeBloc(getHomeUseCase: mockGetHome, connectivity: mockConnectivity)
      ..add(const HomeRequested());

    await tester.pumpWidget(makeTestableWidget(bloc));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('productTile_p1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Product p1'), findsOneWidget);
  });
}
