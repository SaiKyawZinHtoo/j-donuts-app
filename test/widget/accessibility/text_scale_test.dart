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

class _MockGetHomeUseCase extends Mock implements GetHomeUseCase {}

class _MockConnectivityService extends Mock implements ConnectivityService {}

class _StubProductRepository implements ProductRepository {
  @override
  Future<Result<Product>> getProduct(String id) async => const Result.ok(
        Product(
          id: 'p1',
          code: 'DN-001',
          name: 'Glazed Donut',
          priceMmk: 1500,
          isNew: true,
          discountPercent: 10,
          imageUrl: 'https://example.com/img.png',
          description: 'Classic glazed donut.',
        ),
      );
}

Widget makeTestableWidget(Widget child) {
  final router = GoRouter(
    initialLocation: '/__test__',
    routes: [
      GoRoute(path: '/__test__', builder: (context, state) => child),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) => const SizedBox(),
      ),
    ],
  );
  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

void main() {
  testWidgets('HomeScreen renders without overflow at textScaleFactor 1.3', (tester) async {
    final mockGetHome = _MockGetHomeUseCase();
    final mockConnectivity = _MockConnectivityService();
    when(() => mockConnectivity.onStatusChanged).thenAnswer((_) => const Stream<bool>.empty());
    when(() => mockConnectivity.isOnline()).thenAnswer((_) async => true);
    when(() => mockGetHome.call()).thenAnswer(
      (_) async => Result.ok(
        HomeBundle(
          member: const Member(
            id: 'm1',
            name: 'Shan Lay',
            photoUrl: 'https://example.com/photo.png',
            tier: 'Gold',
            points: 100,
            nextTierPoints: 200,
            totalPoints: 100,
          ),
          banners: const [
            BannerItem(
                id: 'b1',
                title: 'Seasonal',
                imageUrl: 'https://example.com/banner.png',
                deepLinkTarget: ''),
          ],
          sections: const [
            ProductSection(
              id: 's1',
              title: 'Seasonal specials',
              products: [
                Product(
                  id: 'p1',
                  code: 'DN-001',
                  name: 'Glazed Donut With A Very Long Name Indeed',
                  priceMmk: 1000,
                  isNew: true,
                  discountPercent: 0,
                  imageUrl: 'https://example.com/img1.png',
                  description: '',
                ),
              ],
            ),
          ],
          shops: const [
            Shop(
              id: 'sh1',
              name: 'Downtown J Donuts',
              address: '123 Main Street, Yangon',
              distanceLabel: '1.2 km',
            ),
          ],
        ),
      ),
    );

    final bloc = HomeBloc(getHomeUseCase: mockGetHome, connectivity: mockConnectivity)
      ..add(const HomeRequested());

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: makeTestableWidget(
          BlocProvider<HomeBloc>.value(value: bloc, child: const HomeScreen()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });

  testWidgets('ProductDetailScreen renders without overflow at textScaleFactor 1.3',
      (tester) async {
    await GetIt.instance.reset();
    GetIt.instance.registerFactory<ProductDetailBloc>(
      () => ProductDetailBloc(getProductUseCase: GetProductUseCase(_StubProductRepository())),
    );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: makeTestableWidget(const ProductDetailScreen(productId: 'p1')),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);

    await GetIt.instance.reset();
  });
}
