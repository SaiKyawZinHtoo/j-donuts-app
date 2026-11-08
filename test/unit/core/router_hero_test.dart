import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/core/di/service_locator.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/core/router/app_router.dart';
import 'package:j_donuts_app/data/local/database.dart' hide AuthUser, Product;
import 'package:j_donuts_app/features/auth/auth_import.dart';
import 'package:j_donuts_app/features/product/product_import.dart';

class _Session extends GetSessionUseCase {
  _Session() : super(_NoRepo());
  @override
  Future<Result<AuthUser?>> call() async =>
      Ok(AuthUser(id: '1', phone: '1', firstName: 'A', dob: DateTime(2000)));
}

class _NoRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _FakeStorage extends FlutterSecureStoragePlatform {
  @override
  dynamic noSuchMethod(Invocation i) async => null;
}

class _PendingRepo implements ProductRepository {
  @override
  Future<Result<Product>> getProduct(String id) =>
      Completer<Result<Product>>().future;
}

void main() {
  tearDown(() async {
    if (GetIt.instance.isRegistered<AppDatabase>()) {
      await GetIt.instance<AppDatabase>().close();
    }
    await GetIt.instance.reset();
  });

  Future<GoRouter> boot(WidgetTester t) async {
    FlutterSecureStoragePlatform.instance = _FakeStorage();
    setupServiceLocator();
    GetIt.instance.unregister<AppDatabase>();
    GetIt.instance.registerLazySingleton<AppDatabase>(
      () => AppDatabase.forTesting(NativeDatabase.memory()),
    );
    GetIt.instance.unregister<GetSessionUseCase>();
    GetIt.instance.registerSingleton<GetSessionUseCase>(_Session());
    GetIt.instance.unregister<ProductDetailBloc>();
    GetIt.instance.registerFactory<ProductDetailBloc>(
      () => ProductDetailBloc(getProductUseCase: GetProductUseCase(_PendingRepo())),
    );
    final router = createAppRouter();
    await t.pumpWidget(MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    for (var i = 0; i < 200; i++) {
      await t.pump(const Duration(milliseconds: 20));
    }
    return router;
  }

  String? heroTag(WidgetTester t) =>
      t.widget<ProductDetailScreen>(find.byType(ProductDetailScreen)).heroTag;

  testWidgets('String extra becomes heroTag', (t) async {
    final router = await boot(t);
    router.push('/product/p1', extra: 'product-popular-p1');
    await t.pump();
    await t.pump(const Duration(seconds: 1));
    expect(heroTag(t), 'product-popular-p1');
  });

  testWidgets('/product/:id builds a CupertinoPage (edge-swipe back)', (t) async {
    final router = await boot(t);
    router.push('/product/p1');
    await t.pump();
    await t.pump(const Duration(seconds: 1));
    final route = ModalRoute.of(t.element(find.byType(ProductDetailScreen)))!;
    expect(route.settings, isA<CupertinoPage<void>>());
  });

  testWidgets('no extra / non-String extra: heroTag null, still renders', (t) async {
    final router = await boot(t);
    router.go('/product/p1');
    await t.pump();
    await t.pump(const Duration(seconds: 1));
    expect(heroTag(t), isNull);
    expect(find.byKey(const Key('productDetailScreen')), findsOneWidget);

    router.push('/product/p2', extra: 42);
    await t.pump();
    await t.pump(const Duration(seconds: 1));
    expect(heroTag(t), isNull);
    expect(find.byKey(const Key('productDetailScreen')), findsWidgets);
  });
}
