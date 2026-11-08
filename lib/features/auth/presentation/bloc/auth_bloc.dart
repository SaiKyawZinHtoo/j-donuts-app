part of '../../auth_import.dart';

/// Drives the phone -> OTP -> (login | registration) flow.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GetSessionUseCase getSessionUseCase;
  final AuthRepository authRepository;

  int _attempts = 0;
  int _secondsLeft = 0;
  bool _phoneKnown = false;
  bool _phoneRequestInFlight = false;
  bool _dobRequestInFlight = false;
  Timer? _timer;
  RegistrationDraft _draft = const RegistrationDraft();

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.getSessionUseCase,
    required this.authRepository,
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
    }
    super.add(event);
  }

  Future<void> _onPhoneSubmitted(PhoneSubmitted event, Emitter<AuthState> emit) async {
    final result = validatePhone(event.raw);
    if (result is ValidationInvalid) {
      _phoneRequestInFlight = false;
      emit(PhoneInvalid(result.message, draft: _draft));
      return;
    }

    try {
      _draft = _draft.copyWith(phone: event.raw);
      emit(AuthLoading(draft: _draft));
      final checkResult = await authRepository.checkPhone(event.raw);
      if (checkResult is Err<bool>) {
        emit(AuthFailure(checkResult.message, draft: _draft));
        return;
      }
      _phoneKnown = (checkResult as Ok<bool>).value;
      if (!_phoneKnown) {
        emit(PhoneNeedsRegistration(draft: _draft));
      }
      _startOtpTimer(emit);
    } finally {
      _phoneRequestInFlight = false;
    }
  }

  void _startOtpTimer(Emitter<AuthState> emit) {
    _attempts = 0;
    _secondsLeft = kOtpResendSeconds;
    emit(OtpAwaiting(_secondsLeft, draft: _draft));
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
    emit(OtpAwaiting(_secondsLeft, draft: _draft));
  }

  Future<void> _onOtpDigitEntered(OtpDigitEntered event, Emitter<AuthState> emit) async {
    final result = validateOtp(event.code);
    if (result is ValidationValid) {
      _timer?.cancel();
      if (_phoneKnown) {
        final loginResult = await loginUseCase(_draft.phone!);
        if (loginResult is Ok<AuthUser>) {
          emit(AuthSuccess(loginResult.value, false, draft: _draft));
        } else {
          emit(AuthFailure((loginResult as Err<AuthUser>).message, draft: _draft));
        }
      } else {
        emit(PhoneNeedsRegistration(draft: _draft));
      }
      return;
    }

    _attempts += 1;
    if (_attempts >= kOtpMaxAttempts) {
      _timer?.cancel();
      emit(OtpLocked(draft: _draft));
    } else {
      emit(OtpInvalid(kOtpMaxAttempts - _attempts, draft: _draft));
    }
  }

  Future<void> _onOtpResendRequested(OtpResendRequested event, Emitter<AuthState> emit) async {
    if (_secondsLeft > 0) return;
    _attempts = 0;
    await authRepository.resendOtp(_draft.phone ?? '');
    _startOtpTimer(emit);
  }

  void _onNameSubmitted(NameSubmitted event, Emitter<AuthState> emit) {
    final firstResult = validateFirstName(event.first);
    if (firstResult is ValidationInvalid) {
      emit(RegistrationStepInvalid(firstResult.message, draft: _draft));
      return;
    }
    final lastResult = validateLastName(event.last ?? '');
    if (lastResult is ValidationInvalid) {
      emit(RegistrationStepInvalid(lastResult.message, draft: _draft));
      return;
    }
    _draft = _draft.copyWith(firstName: event.first, lastName: event.last);
  }

  Future<void> _onDobSubmitted(DobSubmitted event, Emitter<AuthState> emit) async {
    final result = validateDob(event.dob);
    if (result is ValidationInvalid) {
      _dobRequestInFlight = false;
      emit(RegistrationStepInvalid(result.message, draft: _draft));
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
        emit(AuthFailure((registerResult as Err<AuthUser>).message, draft: _draft));
      }
    } finally {
      _dobRequestInFlight = false;
    }
  }

  Future<void> _onSessionChecked(SessionChecked event, Emitter<AuthState> emit) async {
    final result = await getSessionUseCase();
    if (result is Ok<AuthUser?> && result.value != null) {
      emit(AuthSuccess(result.value!, false, draft: _draft));
    } else {
      emit(const AuthInitial());
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    _timer?.cancel();
    _draft = const RegistrationDraft();
    emit(const AuthInitial());
  }

  void _onBackRequested(BackRequested event, Emitter<AuthState> emit) {
    emit(AuthInitial(draft: _draft));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
