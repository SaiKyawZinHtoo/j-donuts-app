part of '../../auth_import.dart';

/// Normalizes and validates a Myanmar phone number.
///
/// Strips spaces/dashes and one leading 0, prefixes +95, requires 7-9
/// remaining digits.
ValidationResult validatePhone(String raw) {
  var digits = raw.replaceAll(RegExp(r'[\s-]'), '');
  if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  if (!RegExp(r'^\d+$').hasMatch(digits)) {
    return const ValidationInvalid('Phone number must contain only digits.');
  }
  if (digits.length < 7 || digits.length > 10) {
    return const ValidationInvalid('Phone number must have 7-10 digits.');
  }
  return const ValidationValid();
}
