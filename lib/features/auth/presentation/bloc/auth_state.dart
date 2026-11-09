part of '../../auth_import.dart';

/// Carries entered registration values across states so back-navigation
/// does not lose what the user already typed.
class RegistrationDraft {
  final String? phone;
  final String? firstName;
  final String? lastName;
  final DateTime? dob;

  const RegistrationDraft({
    this.phone,
    this.firstName,
    this.lastName,
    this.dob,
  });

  RegistrationDraft copyWith({
    String? phone,
    String? firstName,
    String? lastName,
    DateTime? dob,
  }) {
    return RegistrationDraft(
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dob: dob ?? this.dob,
    );
  }
}

/// Which registration-flow screen the UI should be on. Lets a BlocBuilder
/// distinguish otp-for-registration vs name vs dob, and lets `BackRequested`
/// step back exactly one screen instead of resetting to the start.
enum RegistrationStep { phone, otp, name, dob }

sealed class AuthState {
  final RegistrationDraft draft;
  const AuthState({this.draft = const RegistrationDraft()});
}

final class AuthInitial extends AuthState {
  const AuthInitial({super.draft});
}

final class AuthLoading extends AuthState {
  const AuthLoading({super.draft});
}

final class PhoneInvalid extends AuthState {
  final String message;
  const PhoneInvalid(this.message, {super.draft});
}

final class PhoneNeedsRegistration extends AuthState {
  const PhoneNeedsRegistration({super.draft});
}

final class OtpAwaiting extends AuthState {
  final int secondsLeft;
  const OtpAwaiting(this.secondsLeft, {super.draft});
}

final class OtpInvalid extends AuthState {
  final int attemptsLeft;
  const OtpInvalid(this.attemptsLeft, {super.draft});
}

final class OtpLocked extends AuthState {
  const OtpLocked({super.draft});
}

final class AwaitingName extends AuthState {
  const AwaitingName({super.draft});
}

final class AwaitingDob extends AuthState {
  const AwaitingDob({super.draft});
}

final class RegistrationStepInvalid extends AuthState {
  final RegistrationStep step;
  final String message;
  const RegistrationStepInvalid(this.step, this.message, {super.draft});
}

final class AuthSuccess extends AuthState {
  final AuthUser user;
  final bool isNewUser;
  const AuthSuccess(this.user, this.isNewUser, {super.draft});
}

final class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message, {super.draft});
}
