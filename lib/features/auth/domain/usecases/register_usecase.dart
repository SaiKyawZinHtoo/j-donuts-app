part of '../../auth_import.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<Result<AuthUser>> call({
    required String phone,
    required String firstName,
    String? lastName,
    required DateTime dob,
  }) => _repository.completeRegistration(
    phone: phone,
    firstName: firstName,
    lastName: lastName,
    dob: dob,
  );
}
