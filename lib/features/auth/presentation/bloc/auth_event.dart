part of '../../auth_import.dart';

/// Events driving the phone/OTP/registration auth flow.
sealed class AuthEvent {
  const AuthEvent();
}

final class PhoneSubmitted extends AuthEvent {
  final String raw;
  const PhoneSubmitted(this.raw);
}

final class OtpDigitEntered extends AuthEvent {
  final String code;
  const OtpDigitEntered(this.code);
}

final class OtpResendRequested extends AuthEvent {
  const OtpResendRequested();
}

final class NameSubmitted extends AuthEvent {
  final String first;
  final String? last;
  const NameSubmitted(this.first, this.last);
}

final class DobSubmitted extends AuthEvent {
  final DateTime dob;
  const DobSubmitted(this.dob);
}

final class SessionChecked extends AuthEvent {
  const SessionChecked();
}

final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

final class BackRequested extends AuthEvent {
  const BackRequested();
}

/// Internal, bloc-only: fired each timer tick to decrement the OTP countdown.
final class _OtpTick extends AuthEvent {
  const _OtpTick();
}
