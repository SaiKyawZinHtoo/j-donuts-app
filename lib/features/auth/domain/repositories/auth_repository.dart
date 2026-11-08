part of '../../auth_import.dart';

/// Contract for auth data operations, implemented by the data layer.
abstract class AuthRepository {
  Future<Result<bool>> checkPhone(String phone);
  Future<Result<void>> verifyOtp(String phone, String code);
  Future<Result<void>> resendOtp(String phone);
  Future<Result<AuthUser>> completeRegistration({
    required String phone,
    required String firstName,
    String? lastName,
    required DateTime dob,
  });
  Future<Result<AuthUser>> login(String phone);
  Future<Result<void>> logout();
  Future<Result<AuthUser?>> getSession();
}
