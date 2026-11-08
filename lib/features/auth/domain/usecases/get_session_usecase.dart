part of '../../auth_import.dart';

class GetSessionUseCase {
  final AuthRepository _repository;
  const GetSessionUseCase(this._repository);

  Future<Result<AuthUser?>> call() => _repository.getSession();
}
