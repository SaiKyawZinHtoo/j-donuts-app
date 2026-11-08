part of '../../auth_import.dart';

/// Result of a pure validation check.
sealed class ValidationResult {
  const ValidationResult();
}

final class ValidationValid extends ValidationResult {
  const ValidationValid();
}

final class ValidationInvalid extends ValidationResult {
  final String message;
  const ValidationInvalid(this.message);
}
