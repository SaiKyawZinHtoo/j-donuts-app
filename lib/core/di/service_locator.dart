import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../data/local/daos/auth_dao.dart';
import '../../data/local/daos/home_dao.dart';
import '../../data/local/daos/member_dao.dart';
import '../../data/local/daos/product_dao.dart';
import '../../data/local/daos/rewards_dao.dart';
import '../../data/local/database.dart';
import '../../features/auth/auth_import.dart';

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
}
