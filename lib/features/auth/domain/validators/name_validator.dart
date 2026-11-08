part of '../../auth_import.dart';

final RegExp _namePattern = RegExp(r'^[a-zA-Zက-႟\s]+$');

/// First name: trimmed length 1-50, letters (incl. Myanmar) and spaces only.
ValidationResult validateFirstName(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.length > 50) {
    return const ValidationInvalid('First name must be 1-50 characters.');
  }
  if (!_namePattern.hasMatch(trimmed)) {
    return const ValidationInvalid('First name must contain only letters.');
  }
  return const ValidationValid();
}

/// Last name: same rules as first name, but empty is allowed.
ValidationResult validateLastName(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return const ValidationValid();
  }
  if (trimmed.length > 50) {
    return const ValidationInvalid('Last name must be at most 50 characters.');
  }
  if (!_namePattern.hasMatch(trimmed)) {
    return const ValidationInvalid('Last name must contain only letters.');
  }
  return const ValidationValid();
}
