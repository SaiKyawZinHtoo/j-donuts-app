part of '../../auth_import.dart';

/// Normalizes and validates a Myanmar phone number.
///
/// Strips spaces/dashes and one leading 0, prefixes +95. The remaining
/// digits must start with a leading `9` followed by 7-9 more digits
/// (8-10 digits total after +95).
ValidationResult validatePhone(String raw) {
  final digits = _stripToLocalDigits(raw);
  if (!RegExp(r'^\d+$').hasMatch(digits)) {
    return const ValidationInvalid('Phone number must contain only digits.');
  }
  if (!digits.startsWith('9')) {
    return const ValidationInvalid(
      'Phone number must start with 9 after the prefix.',
    );
  }
  final afterNine = digits.length - 1;
  if (afterNine < 7 || afterNine > 9) {
    return const ValidationInvalid(
      'Phone number must have 7-9 digits after the leading 9.',
    );
  }
  return const ValidationValid();
}

/// Returns the canonical `+95...` form for an already-valid raw input
/// (call only after [validatePhone] returns [ValidationValid]).
String normalizePhone(String raw) => '+95${_stripToLocalDigits(raw)}';

/// Strips spaces/dashes, a leading `+95`/`95` or `0`, leaving the bare
/// local digits (e.g. "912345678").
String _stripToLocalDigits(String raw) {
  var digits = raw.replaceAll(RegExp(r'[\s-]'), '');
  if (digits.startsWith('+95')) {
    digits = digits.substring(3);
  } else if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  return digits;
}
