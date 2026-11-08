part of '../../auth_import.dart';

/// Authenticated user entity.
class AuthUser {
  final String id;
  final String phone;
  final String firstName;
  final String? lastName;
  final DateTime dob;

  const AuthUser({
    required this.id,
    required this.phone,
    required this.firstName,
    this.lastName,
    required this.dob,
  });
}
