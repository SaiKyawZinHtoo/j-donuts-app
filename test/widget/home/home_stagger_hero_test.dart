import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/features/home/home_import.dart';
import 'package:j_donuts_app/features/product/product_import.dart';

class _MockGetHome extends Mock implements GetHomeUseCase {}

class _MockConn extends Mock implements ConnectivityService {}

const _p1 = Product(
  id: 'p1',
  code: 'DN-001',
  name: 'Glazed',
  priceMmk: 1000,
  isNew: false,
  discountPercent: 0,
  imageUrl: 'img1.png',
  description: 'Classic.',
);

final _bundle = HomeBundle(
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
    ProductSection(id: 'seasonal', title: 'Seasonal', products: [_p1]),
    ProductSection(id: 'popular', title: 'Popular', products: [_p1]),
  ],
  shops: const [
    Shop(id: 'sh1', name: 'Downtown', address: '1 Main', distanceLabel: '1 km'),
  ],
);

class _StubRepo implements ProductRepository {
  @override
  Future<Result<Product>> getProduct(String id) async => const Result.ok(_p1);
}

class _PendingRepo implements ProductRepository {
  @override
  Future<Result<Product>> getProduct(String id) => Completer<Result<Product>>().future;
}

void main() {
  late _MockGetHome getHome;
  late _MockConn conn;
  Object? capturedExtra;

  setUp(() async {
    getHome = _MockGetHome();
    conn = _MockConn();
    capturedExtra = null;
    when(() => conn.onStatusChanged).thenAnswer((_) => const Stream<bool>.empty());
    when(() => conn.isOnline()).thenAnswer((_) async => true);
    when(() => getHome.call()).thenAnswer((_) async => Result.ok(_bundle));
    await GetIt.instance.reset();
    GetIt.instance.registerFactory<ProductDetailBloc>(
      () => ProductDetailBloc(getProductUseCase: GetProductUseCase(_StubRepo())),
    );
  });
  tearDown(() => GetIt.instance.reset());

  Widget app(HomeBloc bloc) => MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/h',
          routes: [
            GoRoute(path: '/h', builder: (context, state) => const HomeScreen()),
            GoRoute(
              path: '/product/:id',
              builder: (context, state) {
                capturedExtra = state.extra;
                return const Scaffold(body: Text('detail'));
              },
            ),
          ],
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) =>
            BlocProvider<HomeBloc>.value(value: bloc, child: child!),
      );

  HomeBloc makeBloc() =>
      HomeBloc(getHomeUseCase: getHome, connectivity: conn)..add(const HomeRequested());

  double sectionOpacity(WidgetTester t) => t
      .widget<FadeTransition>(find
          .ancestor(of: find.text('Seasonal'), matching: find.byType(FadeTransition))
          .first)
      .opacity
      .value;

  test('heroTagFor is section scoped', () {
    expect(heroTagFor('seasonal', 'p1'), isNot(heroTagFor('popular', 'p1')));
    expect(heroTagFor('seasonal', 'p1'), 'product-seasonal-p1');
  });

  testWidgets('same product in two sections: two distinct Heroes, no exception',
      (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(makeBloc()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    final heroes = tester.widgetList<Hero>(find.byType(Hero)).toList();
    expect(heroes.map((h) => h.tag).toSet(),
        {'product-seasonal-p1', 'product-popular-p1'});
    expect(heroes.length, 2);
  });

  testWidgets('tap tile in second section pushes that section tag', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(makeBloc()));
    await tester.pump(const Duration(seconds: 1)); // shimmer never settles
    final tile = find.descendant(
      of: find.ancestor(of: find.text('Popular'), matching: find.byType(Column)).first,
      matching: find.byKey(const Key('productTile_p1')),
    );
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await tester.pump(const Duration(seconds: 1)); // shimmer never settles
    expect(capturedExtra, 'product-popular-p1');
  });

  testWidgets('stagger plays once, not on refresh', (tester) async {
    final bloc = makeBloc();
    await tester.pumpWidget(app(bloc));
    await tester.pump();
    await tester.pump();
    expect(sectionOpacity(tester), 0);
    await tester.pump(const Duration(seconds: 1)); // shimmer never settles
    expect(sectionOpacity(tester), 1);
    bloc.add(const HomeRefreshRequested());
    await tester.pump();
    await tester.pump();
    expect(find.text('Seasonal'), findsOneWidget);
    expect(sectionOpacity(tester), 1);
  });

  testWidgets('reduce motion: fully visible on first frame', (tester) async {
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: app(makeBloc()),
    ));
    await tester.pump();
    await tester.pump();
    expect(sectionOpacity(tester), 1);
  });

  Future<void> pumpDetail(WidgetTester t, String? tag) async {
    await t.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ProductDetailScreen(productId: 'p1', heroTag: tag),
    ));
    await t.pump();
    await t.pump();
    await t.pump(const Duration(milliseconds: 50));
  }

  testWidgets('detail without heroTag has no Hero', (tester) async {
    await pumpDetail(tester, null);
    expect(find.byType(Hero), findsNothing);
  });

  testWidgets('detail with heroTag has exactly one Hero with that tag', (tester) async {
    await pumpDetail(tester, 'product-popular-p1');
    expect(tester.widget<Hero>(find.byType(Hero)).tag, 'product-popular-p1');
  });

  testWidgets('stagger: later section lags earlier one mid-animation', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(makeBloc()));
    await tester.pump();
    await tester.pump();
    await tester.pump(MotionTokens.kHomeSectionStagger * 3);
    double op(String t) => tester
        .widget<FadeTransition>(
            find.ancestor(of: find.text(t), matching: find.byType(FadeTransition)).first)
        .opacity
        .value;
    expect(op('Popular'), lessThan(op('Seasonal')));
    expect(op('Seasonal'), greaterThan(0));
  });

  testWidgets('refresh with more sections than first load: no exception, all visible',
      (tester) async {
    final bloc = makeBloc();
    await tester.pumpWidget(app(bloc));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final more = HomeBundle(
      member: _bundle.member,
      banners: const [],
      sections: [
        for (var i = 0; i < 5; i++)
          ProductSection(id: 's$i', title: 'Sec$i', products: const [_p1]),
      ],
      shops: _bundle.shops,
    );
    when(() => getHome.call()).thenAnswer((_) async => Result.ok(more));
    bloc.add(const HomeRefreshRequested());
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    final f = tester.widget<FadeTransition>(
        find.ancestor(of: find.text('Sec0'), matching: find.byType(FadeTransition)).first);
    expect(f.opacity.value, 1);
    expect(find.text('Sec0'), findsOneWidget);
  });

  testWidgets('detail in loading state has exactly one Hero when tagged', (tester) async {
    GetIt.instance.unregister<ProductDetailBloc>();
    GetIt.instance.registerFactory<ProductDetailBloc>(
      () => ProductDetailBloc(getProductUseCase: GetProductUseCase(_PendingRepo())),
    );
    for (final tag in <String?>['t', null]) {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProductDetailScreen(productId: 'p1', heroTag: tag),
      ));
      await tester.pump();
      expect(find.byType(ProductDetailScreen), findsOneWidget);
      if (tag == null) {
        expect(find.byType(Hero), findsNothing);
      } else {
        expect(tester.widget<Hero>(find.byType(Hero)).tag, 't');
      }
    }
  });
}
