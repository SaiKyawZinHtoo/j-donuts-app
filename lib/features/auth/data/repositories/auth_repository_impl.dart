part of '../../auth_import.dart';

/// Fake implementation of [AuthRepository]: simulates network latency,
/// persists users to Drift, and keeps the session in secure storage — so a
/// real API-backed implementation can later replace it without touching the
/// UI layer.
class FakeAuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final SessionDataSource _sessionDataSource;

  const FakeAuthRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required SessionDataSource sessionDataSource,
  })  : _localDataSource = localDataSource,
        _sessionDataSource = sessionDataSource;

  @override
  Future<Result<bool>> checkPhone(String phone) async {
    await Future.delayed(kFakeNetworkDelay);
    final user = await _localDataSource.findByPhone(phone);
    return Result.ok(user != null);
  }

  @override
  Future<Result<void>> verifyOtp(String phone, String code) async {
    await Future.delayed(kFakeNetworkDelay);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> resendOtp(String phone) async {
    await Future.delayed(kFakeNetworkDelay);
    return const Result.ok(null);
  }

  @override
  Future<Result<AuthUser>> completeRegistration({
    required String phone,
    required String firstName,
    String? lastName,
    required DateTime dob,
  }) async {
    await Future.delayed(kFakeNetworkDelay);
    final user = await _localDataSource.insertUser(
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      dob: dob,
    );
    await _sessionDataSource.saveSession(user);
    return Result.ok(user);
  }

  @override
  Future<Result<AuthUser>> login(String phone) async {
    await Future.delayed(kFakeNetworkDelay);
    final user = await _localDataSource.findByPhone(phone);
    if (user == null) {
      return const Result.err('No account found for this phone number.');
    }
    await _sessionDataSource.saveSession(user);
    return Result.ok(user);
  }

  @override
  Future<Result<void>> logout() async {
    await Future.delayed(kFakeNetworkDelay);
    await _sessionDataSource.clearSession();
    return const Result.ok(null);
  }

  @override
  Future<Result<AuthUser?>> getSession() async {
    await Future.delayed(kFakeNetworkDelay);
    final user = await _sessionDataSource.readSession();
    return Result.ok(user);
  }
}
