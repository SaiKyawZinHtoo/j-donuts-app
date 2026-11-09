part of '../../auth_import.dart';

/// Validates a date of birth: must be a real calendar date, not in the
/// future, and at least [kMinAgeYears] years ago.
ValidationResult validateDob(DateTime value) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dob = DateTime(value.year, value.month, value.day);

  if (dob.isAfter(today)) {
    return const ValidationInvalid('Date of birth cannot be in the future.');
  }

  var age = today.year - dob.year;
  final hadBirthdayThisYear =
      (today.month > dob.month) ||
      (today.month == dob.month && today.day >= dob.day);
  if (!hadBirthdayThisYear) {
    age -= 1;
  }

  if (age < kMinAgeYears) {
    return ValidationInvalid('You must be at least $kMinAgeYears years old.');
  }

  return const ValidationValid();
}
