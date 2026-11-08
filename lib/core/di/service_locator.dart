import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../data/local/daos/auth_dao.dart';
import '../../data/local/daos/home_dao.dart';
import '../../data/local/daos/member_dao.dart';
import '../../data/local/daos/product_dao.dart';
import '../../data/local/daos/rewards_dao.dart';
import '../../data/local/database.dart';
import '../../features/auth/auth_import.dart';
import '../../features/home/home_import.dart';
import '../../features/product/product_import.dart';
import '../core_import.dart';

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
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt()),
  );
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(getIt()),
  );
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(homeDao: getIt(), memberDao: getIt()),
  );
  getIt.registerLazySingleton<GetHomeUseCase>(
    () => GetHomeUseCase(getIt()),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt(),
      registerUseCase: getIt(),
      getSessionUseCase: getIt(),
      authRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(getHomeUseCase: getIt(), connectivity: getIt()),
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
}
