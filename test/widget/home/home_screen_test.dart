import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/features/home/home_import.dart';
import 'package:j_donuts_app/features/product/product_import.dart';
import 'package:j_donuts_app/features/shell/shell_import.dart';

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
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
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
      ProductSection(
        id: 's1',
        title: 'Popular',
        products: [
          Product(
            id: 'p1',
            code: 'DN-001',
            name: 'Glazed',
            priceMmk: 1000,
            isNew: false,
            discountPercent: 0,
            imageUrl: 'img1.png',
            description: '',
          ),
          Product(
            id: 'p2',
            code: 'DN-002',
            name: 'Chocolate',
            priceMmk: 1200,
            isNew: true,
            discountPercent: 0,
            imageUrl: 'img2.png',
            description: '',
          ),
          Product(
            id: 'p3',
            code: 'DN-003',
            name: 'Both',
            priceMmk: 900,
            isNew: true,
            discountPercent: 20,
            imageUrl: 'img3.png',
            description: '',
          ),
          Product(
            id: 'p4',
            code: 'DN-004',
            name: 'Box',
            priceMmk: 900,
            isNew: false,
            discountPercent: 50,
            imageUrl: 'img4.png',
            description: '',
          ),
        ],
      ),
      ProductSection(
        id: 'seasonal_specials',
        title: 'Seasonal',
        products: [
          Product(
            id: 'p5',
            code: 'DN-005',
            name: 'Romance',
            priceMmk: 900,
            isNew: false,
            discountPercent: 50,
            imageUrl: 'img5.png',
            description: '',
          ),
        ],
      ),
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

  testWidgets('badges: discount, new wins; card widths per mode', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    when(() => mockConnectivity.isOnline()).thenAnswer((_) async => true);
    when(() => mockGetHome.call()).thenAnswer((_) async => Result.ok(testBundle));
    final bloc = HomeBloc(getHomeUseCase: mockGetHome, connectivity: mockConnectivity)
      ..add(const HomeRequested());
    await tester.pumpWidget(makeTestableWidget(bloc));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('50% off'), findsWidgets);
    expect(find.text('New'), findsNWidgets(2));
    expect(find.text('20% off'), findsNothing);
    expect(tester.getSize(find.byKey(const Key('productTile_p1'))).width,
        AppSpacing.cardCutoutWidth);
    final seasonal = find.byKey(const Key('productTile_p5'));
    await tester.ensureVisible(seasonal);
    expect(tester.getSize(seasonal).width, AppSpacing.cardPhotoWidth);
  });

  testWidgets('MemberHeader shows name, tier, points chip and bell badge at 1.3x text', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: const MediaQueryData(size: Size(375, 812), textScaler: TextScaler.linear(1.3)),
        child: const Scaffold(
          body: MemberHeader(
            member: Member(
              id: 'm1',
              name: 'Hania',
              photoUrl: 'assets/images/seed/member_avatar.png',
              tier: 'Bronze',
              points: 710,
              nextTierPoints: 2000,
              totalPoints: 710,
            ),
          ),
        ),
      ),
    ));
    expect(find.text('Hania'), findsOneWidget);
    expect(find.text('Bronze member'), findsOneWidget);
    expect(find.descendant(
        of: find.byKey(const Key('memberHeader_pointsChip')),
        matching: find.text('1290 points left to become Gold Member')), findsOneWidget);
    expect(find.descendant(
        of: find.byKey(const Key('memberHeader_bellButton')), matching: find.text('2')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('BannerCarousel exposes key and no autoplay timer under Reduce Motion', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Scaffold(
          body: BannerCarousel(banners: [
            BannerItem(id: 'b1', imageUrl: 'assets/images/seed/banner_seasonal.png', title: 't', deepLinkTarget: ''),
            BannerItem(id: 'b2', imageUrl: 'assets/images/seed/banner_seasonal.png', title: 't', deepLinkTarget: ''),
          ]),
        ),
      ),
    ));
    expect(find.byKey(const Key('bannerCarousel')), findsOneWidget);
    await tester.pump(const Duration(minutes: 1));
  });

  testWidgets('shops block clears floating nav; grey page; explore + order texts', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    when(() => mockConnectivity.isOnline()).thenAnswer((_) async => true);
    when(() => mockGetHome.call()).thenAnswer((_) async => Result.ok(testBundle));
    final bloc = HomeBloc(getHomeUseCase: mockGetHome, connectivity: mockConnectivity)
      ..add(const HomeRequested());
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<HomeBloc>.value(
        value: bloc,
        child: AppShellScreen(
          homeTab: const HomeScreen(),
          rewardsTab: (_) => const SizedBox(),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    final scaffold = tester.widget<Scaffold>(find.byKey(const Key('homeScreen')));
    expect(scaffold.backgroundColor, AppColors.pageGrey);

    for (var k = 0; k < 4; k++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
      await tester.pumpAndSettle();
    }
    expect(find.byKey(const Key('nearbyShopsRow')), findsOneWidget);
    expect(find.text('EXPLORE NOW'), findsOneWidget);
    expect(find.text('Order Online'), findsOneWidget);
    final navTop = tester.getTopLeft(find.byType(AppBottomNav)).dy;
    expect(tester.getBottomLeft(find.byKey(const Key('shopCard_sh1'))).dy, lessThanOrEqualTo(navTop));
  });

  testWidgets('offline banner text clears the status bar inset', (tester) async {
    when(() => mockConnectivity.isOnline()).thenAnswer((_) async => false);
    when(() => mockGetHome.call()).thenAnswer((_) async => Result.ok(testBundle));
    final bloc = HomeBloc(getHomeUseCase: mockGetHome, connectivity: mockConnectivity)
      ..add(const HomeRequested());
    final router = GoRouter(
      initialLocation: '/',
      routes: [GoRoute(path: '/', builder: (context, state) => const HomeScreen())],
    );
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(padding: const EdgeInsets.only(top: 47)),
        child: BlocProvider<HomeBloc>.value(value: bloc, child: child!),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    final text = find.descendant(
        of: find.byKey(const Key('homeOfflineBanner')), matching: find.byType(Text));
    expect(tester.getTopLeft(text).dy, greaterThanOrEqualTo(47));
    final header = find.byKey(const Key('memberHeader_pointsChip'));
    expect(header, findsOneWidget);
  });
}
