import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:j_donuts_app/core/core_import.dart';
import 'package:j_donuts_app/core/result/result.dart';
import 'package:j_donuts_app/features/auth/auth_import.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late LoginUseCase loginUseCase;
  late RegisterUseCase registerUseCase;
  late GetSessionUseCase getSessionUseCase;

  final user = AuthUser(
    id: '1',
    phone: '+959123456789',
    firstName: 'Shan',
    dob: DateTime(2000, 1, 1),
  );

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    loginUseCase = LoginUseCase(mockAuthRepo);
    registerUseCase = RegisterUseCase(mockAuthRepo);
    getSessionUseCase = GetSessionUseCase(mockAuthRepo);

    when(() => mockAuthRepo.resendOtp(any())).thenAnswer((_) async => const Result.ok(null));
  });

  AuthBloc build() => AuthBloc(
        loginUseCase: loginUseCase,
        registerUseCase: registerUseCase,
        getSessionUseCase: getSessionUseCase,
        authRepository: mockAuthRepo,
      );

  group('OTP lockout', () {
    blocTest<AuthBloc, AuthState>(
      'locks after 3 wrong OTP codes',
      setUp: () {
        when(() => mockAuthRepo.checkPhone(any())).thenAnswer((_) async => const Result.ok(true));
      },
      build: build,
      act: (bloc) => bloc
        ..add(const PhoneSubmitted('09123456789'))
        ..add(const OtpDigitEntered('000000'))
        ..add(const OtpDigitEntered('000000'))
        ..add(const OtpDigitEntered('000000')),
      skip: 2, // AuthLoading, then OtpAwaiting(kOtpResendSeconds)
      expect: () => [
        isA<OtpInvalid>().having((s) => s.attemptsLeft, 'attemptsLeft', 2),
        isA<OtpInvalid>().having((s) => s.attemptsLeft, 'attemptsLeft', 1),
        isA<OtpLocked>(),
      ],
    );
  });

  group('OTP resend', () {
    blocTest<AuthBloc, AuthState>(
      'OtpResendRequested before countdown reaches 0:00 is a no-op',
      setUp: () {
        when(() => mockAuthRepo.checkPhone(any())).thenAnswer((_) async => const Result.ok(true));
      },
      build: build,
      act: (bloc) async {
        bloc.add(const PhoneSubmitted('09123456789'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const OtpResendRequested());
        bloc.add(const OtpResendRequested());
      },
      skip: 2, // AuthLoading, OtpAwaiting(kOtpResendSeconds)
      expect: () => <dynamic>[],
      verify: (bloc) {
        verifyNever(() => mockAuthRepo.resendOtp(any()));
      },
    );
  });

  group('debounce', () {
    blocTest<AuthBloc, AuthState>(
      'rapid double-tap on PhoneSubmitted sends exactly one request',
      build: () {
        when(() => mockAuthRepo.checkPhone(any())).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return const Result.ok(true);
        });
        return build();
      },
      act: (bloc) => bloc
        ..add(const PhoneSubmitted('09123456789'))
        ..add(const PhoneSubmitted('09123456789')),
      wait: const Duration(milliseconds: 50),
      verify: (_) {
        verify(() => mockAuthRepo.checkPhone(any())).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'rapid double-tap on OtpDigitEntered sends exactly one login request',
      setUp: () {
        when(() => mockAuthRepo.checkPhone(any())).thenAnswer((_) async => const Result.ok(true));
        when(() => mockAuthRepo.login(any())).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return Result.ok(user);
        });
      },
      build: build,
      act: (bloc) async {
        bloc.add(const PhoneSubmitted('09123456789'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc
          ..add(const OtpDigitEntered(kFakeOtpCode))
          ..add(const OtpDigitEntered(kFakeOtpCode));
      },
      wait: const Duration(milliseconds: 50),
      verify: (_) {
        verify(() => mockAuthRepo.login(any())).called(1);
      },
    );
  });

  group('phone submit', () {
    blocTest<AuthBloc, AuthState>(
      'invalid phone emits PhoneInvalid',
      build: build,
      act: (bloc) => bloc.add(const PhoneSubmitted('123')),
      expect: () => [isA<PhoneInvalid>()],
    );

    blocTest<AuthBloc, AuthState>(
      'known phone logs in directly after OTP success',
      setUp: () {
        when(() => mockAuthRepo.checkPhone(any())).thenAnswer((_) async => const Result.ok(true));
        when(() => mockAuthRepo.login(any())).thenAnswer((_) async => Result.ok(user));
      },
      build: build,
      act: (bloc) => bloc
        ..add(const PhoneSubmitted('09123456789'))
        ..add(const OtpDigitEntered(kFakeOtpCode)),
      skip: 2,
      expect: () => [isA<AuthSuccess>().having((s) => s.isNewUser, 'isNewUser', false)],
    );

    blocTest<AuthBloc, AuthState>(
      'unknown phone proceeds to registration after OTP success',
      setUp: () {
        when(() => mockAuthRepo.checkPhone(any())).thenAnswer((_) async => const Result.ok(false));
      },
      build: build,
      act: (bloc) => bloc
        ..add(const PhoneSubmitted('09123456789'))
        ..add(const OtpDigitEntered(kFakeOtpCode)),
      skip: 3,
      expect: () => [isA<AwaitingName>()],
    );
  });

  group('registration step transitions', () {
    blocTest<AuthBloc, AuthState>(
      'NameSubmitted valid emits AwaitingDob; invalid emits a name-step RegistrationStepInvalid',
      setUp: () {
        when(() => mockAuthRepo.checkPhone(any())).thenAnswer((_) async => const Result.ok(false));
      },
      build: build,
      act: (bloc) => bloc
        ..add(const PhoneSubmitted('09123456789'))
        ..add(const OtpDigitEntered(kFakeOtpCode))
        ..add(const NameSubmitted('123', null)) // invalid: digits
        ..add(const NameSubmitted('Shan', 'Lay')), // valid
      skip: 4, // AuthLoading, PhoneNeedsRegistration, OtpAwaiting, AwaitingName
      expect: () => [
        isA<RegistrationStepInvalid>().having((s) => s.step, 'step', RegistrationStep.name),
        isA<AwaitingDob>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'DobSubmitted invalid emits a dob-step RegistrationStepInvalid distinct from the name step',
      setUp: () {
        when(() => mockAuthRepo.checkPhone(any())).thenAnswer((_) async => const Result.ok(false));
      },
      build: build,
      act: (bloc) => bloc
        ..add(const PhoneSubmitted('09123456789'))
        ..add(const OtpDigitEntered(kFakeOtpCode))
        ..add(const NameSubmitted('Shan', 'Lay'))
        ..add(DobSubmitted(DateTime.now())), // invalid: today, under min age
      skip: 5, // AuthLoading, PhoneNeedsRegistration, OtpAwaiting, AwaitingName, AwaitingDob
      expect: () => [
        isA<RegistrationStepInvalid>().having((s) => s.step, 'step', RegistrationStep.dob),
      ],
    );
  });

  group('back navigation', () {
    blocTest<AuthBloc, AuthState>(
      'BackRequested steps back one registration screen at a time, not to AuthInitial',
      setUp: () {
        when(() => mockAuthRepo.checkPhone(any())).thenAnswer((_) async => const Result.ok(false));
      },
      build: build,
      act: (bloc) => bloc
        ..add(const PhoneSubmitted('09123456789'))
        ..add(const OtpDigitEntered(kFakeOtpCode))
        ..add(const NameSubmitted('Shan', 'Lay'))
        ..add(const BackRequested()) // dob -> name
        ..add(const BackRequested()) // name -> otp
        ..add(const BackRequested()), // otp -> phone (AuthInitial)
      skip: 5, // AuthLoading, PhoneNeedsRegistration, OtpAwaiting, AwaitingName, AwaitingDob
      expect: () => [
        isA<AwaitingName>(),
        isA<OtpAwaiting>(),
        isA<AuthInitial>(),
      ],
    );
  });

  group('registration', () {
    blocTest<AuthBloc, AuthState>(
      'full registration flow completes with AuthSuccess',
      setUp: () {
        when(() => mockAuthRepo.checkPhone(any())).thenAnswer((_) async => const Result.ok(false));
        when(() => mockAuthRepo.completeRegistration(
              phone: any(named: 'phone'),
              firstName: any(named: 'firstName'),
              lastName: any(named: 'lastName'),
              dob: any(named: 'dob'),
            )).thenAnswer((_) async => Result.ok(user));
      },
      build: build,
      act: (bloc) => bloc
        ..add(const PhoneSubmitted('09123456789'))
        ..add(const OtpDigitEntered(kFakeOtpCode))
        ..add(const NameSubmitted('Shan', 'Lay'))
        ..add(DobSubmitted(DateTime(2000, 1, 1))),
      wait: const Duration(milliseconds: 50),
      skip: 3,
      expect: () => [
        isA<AwaitingName>(),
        isA<AwaitingDob>(),
        isA<AuthLoading>(),
        isA<AuthSuccess>().having((s) => s.isNewUser, 'isNewUser', true),
      ],
    );
  });

  group('session', () {
    blocTest<AuthBloc, AuthState>(
      'SessionChecked emits AuthSuccess when a session exists',
      setUp: () {
        when(() => mockAuthRepo.getSession()).thenAnswer((_) async => Result.ok(user));
      },
      build: build,
      act: (bloc) => bloc.add(const SessionChecked()),
      expect: () => [isA<AuthSuccess>()],
    );

    blocTest<AuthBloc, AuthState>(
      'SessionChecked emits AuthInitial when no session',
      setUp: () {
        when(() => mockAuthRepo.getSession()).thenAnswer((_) async => const Result.ok(null));
      },
      build: build,
      act: (bloc) => bloc.add(const SessionChecked()),
      expect: () => [isA<AuthInitial>()],
    );
  });

  group('logout', () {
    blocTest<AuthBloc, AuthState>(
      'LogoutRequested emits AuthInitial',
      setUp: () {
        when(() => mockAuthRepo.logout()).thenAnswer((_) async => const Result.ok(null));
      },
      build: build,
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [isA<AuthInitial>()],
    );
  });
}
