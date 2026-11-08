part of '../../auth_import.dart';

/// Persists the logged-in user's session to secure storage as a JSON blob.
class SessionDataSource {
  static const _key = 'auth_session';

  final FlutterSecureStorage _storage;
  const SessionDataSource(this._storage);

  Future<void> saveSession(AuthUser user) => _storage.write(
        key: _key,
        value: jsonEncode({
          'id': user.id,
          'phone': user.phone,
          'firstName': user.firstName,
          'lastName': user.lastName,
          'dob': user.dob.toIso8601String(),
        }),
      );

  Future<AuthUser?> readSession() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return AuthUser(
      id: json['id'] as String,
      phone: json['phone'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      dob: DateTime.parse(json['dob'] as String),
    );
  }

  Future<void> clearSession() => _storage.delete(key: _key);
}
