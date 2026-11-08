part of '../../auth_import.dart';

/// Wraps [AuthDao], translating between Drift rows and the domain [AuthUser].
class AuthLocalDataSource {
  final AuthDao _dao;
  const AuthLocalDataSource(this._dao);

  Future<AuthUser?> findByPhone(String phone) async {
    final row = await _dao.findByPhone(phone);
    if (row == null) return null;
    return AuthUser(
      id: row.id,
      phone: row.phone,
      firstName: row.firstName,
      lastName: row.lastName.isEmpty ? null : row.lastName,
      dob: row.dob,
    );
  }

  Future<AuthUser> insertUser({
    required String phone,
    required String firstName,
    String? lastName,
    required DateTime dob,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _dao.insertUser(
      drift.AuthUsersCompanion.insert(
        id: id,
        phone: phone,
        firstName: firstName,
        lastName: lastName ?? '',
        dob: dob,
        createdAt: DateTime.now(),
      ),
    );
    return AuthUser(
      id: id,
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      dob: dob,
    );
  }
}
