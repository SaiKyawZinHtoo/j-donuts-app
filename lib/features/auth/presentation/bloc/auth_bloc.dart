part of '../../auth_import.dart';

/// Drives the phone -> OTP -> (login | registration) flow.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GetSessionUseCase getSessionUseCase;
  final AuthRepository authRepository;
  final FakeSmsNotifier? smsNotifier;

  int _attempts = 0;
  int _secondsLeft = 0;
  bool _phoneKnown = false;
  bool _phoneRequestInFlight = false;
  bool _otpRequestInFlight = false;
  bool _dobRequestInFlight = false;
  Timer? _timer;
  DateTime? _lastInvalidAt;
  RegistrationDraft _draft = const RegistrationDraft();
  RegistrationStep _currentStep = RegistrationStep.phone;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.getSessionUseCase,
    required this.authRepository,
    this.smsNotifier,
  }) : super(const AuthInitial()) {
    on<PhoneSubmitted>(_onPhoneSubmitted);
    on<OtpDigitEntered>(_onOtpDigitEntered);
    on<OtpResendRequested>(_onOtpResendRequested);
    on<NameSubmitted>(_onNameSubmitted);
    on<DobSubmitted>(_onDobSubmitted);
    on<SessionChecked>(_onSessionChecked);
    on<LogoutRequested>(_onLogoutRequested);
    on<BackRequested>(_onBackRequested);
    on<_OtpTick>(_onOtpTick);
  }

  // Flags a request as in-flight synchronously, at add()-time rather than
  // when the (possibly-queued) handler runs, so a rapid double-tap on
  // Continue -- two adds before the first handler even starts -- sends
  // exactly one request instead of queuing a second.
  @override
  void add(AuthEvent event) {
    if (event is PhoneSubmitted) {
      if (_phoneRequestInFlight) return;
      _phoneRequestInFlight = true;
    } else if (event is DobSubmitted) {
      if (_dobRequestInFlight) return;
      _dobRequestInFlight = true;
    } else if (event is OtpDigitEntered &&
        validateOtp(event.code) is ValidationValid) {
      // Only a *correct* code goes on to call the network (login/registration
      // step); a repeated wrong code (e.g. the 3-strike lockout flow) must
      // still be processed every time, so the guard only engages here.
      if (_otpRequestInFlight) return;
      _otpRequestInFlight = true;
    }
    super.add(event);
  }

  Future<void> _onPhoneSubmitted(
    PhoneSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final result = validatePhone(event.raw);
    if (result is ValidationInvalid) {
      _phoneRequestInFlight = false;
      emit(PhoneInvalid(result.message, draft: _draft));
      return;
    }

    final normalized = normalizePhone(event.raw);
    try {
      _draft = _draft.copyWith(phone: normalized);
      emit(AuthLoading(draft: _draft));
      final checkResult = await authRepository.checkPhone(normalized);
      if (checkResult is Err<bool>) {
        emit(AuthFailure(checkResult.message, draft: _draft));
        return;
      }
      _phoneKnown = (checkResult as Ok<bool>).value;
      if (!_phoneKnown) {
        emit(PhoneNeedsRegistration(draft: _draft));
        // Login mode + unknown number: stay on the Phone screen (spec §4.2)
        // instead of starting OTP for a number that isn't registered.
        if (event.isLogin) return;
      }
      _startOtpTimer(emit);
    } finally {
      _phoneRequestInFlight = false;
    }
  }

  void _startOtpTimer(Emitter<AuthState> emit) {
    _attempts = 0;
    _lastInvalidAt = null;
    _secondsLeft = kOtpResendSeconds;
    _currentStep = RegistrationStep.otp;
    emit(OtpAwaiting(_secondsLeft, draft: _draft));
    unawaited(smsNotifier?.showOtp(kFakeOtpCode));
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) add(const _OtpTick());
    });
  }

  void _onOtpTick(_OtpTick event, Emitter<AuthState> emit) {
    _secondsLeft -= 1;
    if (_secondsLeft <= 0) {
      _secondsLeft = 0;
      _timer?.cancel();
    }
    // Don't let the tick's OtpAwaiting overwrite a just-shown OtpInvalid
    // within the same attempt -- give the error a visible window first.
    final lastInvalid = _lastInvalidAt;
    if (lastInvalid != null &&
        DateTime.now().difference(lastInvalid) < MotionTokens.kOtpErrorHold) {
      return;
    }
    emit(OtpAwaiting(_secondsLeft, draft: _draft));
  }

  Future<void> _onOtpDigitEntered(
    OtpDigitEntered event,
    Emitter<AuthState> emit,
  ) async {
    final result = validateOtp(event.code);
    if (result is ValidationValid) {
      try {
        _timer?.cancel();
        if (_phoneKnown) {
          final loginResult = await loginUseCase(_draft.phone!);
          if (loginResult is Ok<AuthUser>) {
            emit(AuthSuccess(loginResult.value, false, draft: _draft));
          } else {
            emit(
              AuthFailure(
                (loginResult as Err<AuthUser>).message,
                draft: _draft,
              ),
            );
          }
        } else {
          _currentStep = RegistrationStep.name;
          emit(AwaitingName(draft: _draft));
        }
      } finally {
        _otpRequestInFlight = false;
      }
      return;
    }

    _attempts += 1;
    if (_attempts >= kOtpMaxAttempts) {
      _timer?.cancel();
      _secondsLeft = 0;
      emit(OtpLocked(draft: _draft));
    } else {
      _lastInvalidAt = DateTime.now();
      emit(OtpInvalid(kOtpMaxAttempts - _attempts, draft: _draft));
    }
  }

  Future<void> _onOtpResendRequested(
    OtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_secondsLeft > 0 && _attempts < kOtpMaxAttempts) return;
    _attempts = 0;
    await authRepository.resendOtp(_draft.phone ?? '');
    _startOtpTimer(emit);
  }

  void _onNameSubmitted(NameSubmitted event, Emitter<AuthState> emit) {
    final firstResult = validateFirstName(event.first);
    if (firstResult is ValidationInvalid) {
      emit(
        RegistrationStepInvalid(
          RegistrationStep.name,
          firstResult.message,
          draft: _draft,
        ),
      );
      return;
    }
    final lastResult = validateLastName(event.last ?? '');
    if (lastResult is ValidationInvalid) {
      emit(
        RegistrationStepInvalid(
          RegistrationStep.name,
          lastResult.message,
          draft: _draft,
        ),
      );
      return;
    }
    _draft = _draft.copyWith(firstName: event.first, lastName: event.last);
    _currentStep = RegistrationStep.dob;
    emit(AwaitingDob(draft: _draft));
  }

  Future<void> _onDobSubmitted(
    DobSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final result = validateDob(event.dob);
    if (result is ValidationInvalid) {
      _dobRequestInFlight = false;
      emit(
        RegistrationStepInvalid(
          RegistrationStep.dob,
          result.message,
          draft: _draft,
        ),
      );
      return;
    }
    _draft = _draft.copyWith(dob: event.dob);

    try {
      emit(AuthLoading(draft: _draft));
      final registerResult = await registerUseCase(
        phone: _draft.phone!,
        firstName: _draft.firstName!,
        lastName: _draft.lastName,
        dob: _draft.dob!,
      );
      if (registerResult is Ok<AuthUser>) {
        emit(AuthSuccess(registerResult.value, true, draft: _draft));
      } else {
        emit(
          AuthFailure((registerResult as Err<AuthUser>).message, draft: _draft),
        );
      }
    } finally {
      _dobRequestInFlight = false;
    }
  }

  Future<void> _onSessionChecked(
    SessionChecked event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getSessionUseCase();
    if (result is Ok<AuthUser?> && result.value != null) {
      emit(AuthSuccess(result.value!, false, draft: _draft));
    } else {
      emit(const AuthInitial());
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    _timer?.cancel();
    _draft = const RegistrationDraft();
    _currentStep = RegistrationStep.phone;
    emit(const AuthInitial());
  }

  // Steps back exactly one registration screen rather than resetting to the
  // start, mirroring _currentStep (advanced alongside each forward state).
  void _onBackRequested(BackRequested event, Emitter<AuthState> emit) {
    switch (_currentStep) {
      case RegistrationStep.dob:
        _currentStep = RegistrationStep.name;
        emit(AwaitingName(draft: _draft));
      case RegistrationStep.name:
        _currentStep = RegistrationStep.otp;
        emit(OtpAwaiting(_secondsLeft, draft: _draft));
      case RegistrationStep.otp:
        _currentStep = RegistrationStep.phone;
        _timer?.cancel();
        emit(AuthInitial(draft: _draft));
      case RegistrationStep.phone:
        emit(AuthInitial(draft: _draft));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
