import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'package:j_donuts_app/data/local/daos/auth_dao.dart';
import 'package:j_donuts_app/data/local/daos/home_dao.dart';
import 'package:j_donuts_app/data/local/daos/member_dao.dart';
import 'package:j_donuts_app/data/local/daos/product_dao.dart';
import 'package:j_donuts_app/data/local/daos/rewards_dao.dart';
import 'package:j_donuts_app/data/local/database.dart' hide AuthUser;
import 'package:j_donuts_app/data/remote/remote_data_source.dart';
import 'package:j_donuts_app/features/home/data/repositories/sync_repository_impl.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';
import 'package:j_donuts_app/features/home/home_import.dart';
import 'package:j_donuts_app/features/product/product_import.dart';
import 'package:j_donuts_app/features/rewards/rewards_import.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/core/result/result.dart';

/// Registers app-wide singletons. Each later feature task adds its own
/// repository/use-case registrations in its own file -- not here.
void setupServiceLocator() {
  final getIt = GetIt.instance;

  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  getIt.registerLazySingleton<ProductDao>(() => ProductDao(getIt()));
  getIt.registerLazySingleton<HomeDao>(() => HomeDao(getIt()));
  getIt.registerLazySingleton<MemberDao>(() => MemberDao(getIt()));
  getIt.registerLazySingleton<RewardsDao>(() => RewardsDao(getIt()));
  getIt.registerLazySingleton<AuthDao>(() => AuthDao(getIt()));

  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(getIt()),
  );
  getIt.registerLazySingleton<SessionDataSource>(
    () => SessionDataSource(getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => FakeAuthRepositoryImpl(
      localDataSource: getIt(),
      sessionDataSource: getIt(),
    ),
  );
  getIt.registerLazySingleton<GetSessionUseCase>(
    () => GetSessionUseCase(getIt()),
  );
  getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      homeDao: getIt(),
      memberDao: getIt(),
      rewardsDao: getIt(),
      readProfile: () async {
        final r = await getIt<GetSessionUseCase>().call();
        final u = r is Ok<AuthUser?> ? r.value : null;
        if (u == null) return null;
        final name = [
          u.firstName,
          u.lastName,
        ].whereType<String>().join(' ').trim();
        return (name: name, phone: u.phone);
      },
    ),
  );
  getIt.registerLazySingleton<GetHomeUseCase>(() => GetHomeUseCase(getIt()));

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt(),
      registerUseCase: getIt(),
      getSessionUseCase: getIt(),
      authRepository: getIt(),
      smsNotifier: getIt(),
    ),
  );

  getIt.registerLazySingleton<FakeSmsNotifier>(() => FakeSmsNotifier());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  if (kApiBaseUrl.isNotEmpty) {
    getIt.registerLazySingleton<SyncRepository>(
      () => SyncRepositoryImpl(
        remote: RemoteDataSource(buildDio(kApiBaseUrl)),
        db: getIt(),
      ),
    );
  }
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      getHomeUseCase: getIt(),
      connectivity: getIt(),
      syncRepository: getIt.isRegistered<SyncRepository>()
          ? getIt<SyncRepository>()
          : null,
    ),
  );

  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(productDao: getIt()),
  );
  getIt.registerLazySingleton<GetProductUseCase>(
    () => GetProductUseCase(getIt()),
  );
  getIt.registerFactory<ProductDetailBloc>(
    () => ProductDetailBloc(getProductUseCase: getIt()),
  );

  getIt.registerLazySingleton<RewardsRepository>(
    () => RewardsRepositoryImpl(rewardsDao: getIt(), memberDao: getIt()),
  );
  getIt.registerLazySingleton<GetRewardsUseCase>(
    () => GetRewardsUseCase(getIt()),
  );
  getIt.registerFactory<RewardsBloc>(
    () => RewardsBloc(getRewardsUseCase: getIt()),
  );
}
