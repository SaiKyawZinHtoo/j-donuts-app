part of '../../auth_import.dart';

/// Validates a one-time-password code against the fake OTP used in dev.
ValidationResult validateOtp(String code) {
  if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
    return const ValidationInvalid('OTP must be 6 digits.');
  }
  if (code != kFakeOtpCode) {
    return const ValidationInvalid('Incorrect OTP.');
  }
  return const ValidationValid();
}
