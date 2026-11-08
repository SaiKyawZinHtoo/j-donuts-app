part of '../../auth_import.dart';

class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<Result<AuthUser>> call(String phone) => _repository.login(phone);
}
