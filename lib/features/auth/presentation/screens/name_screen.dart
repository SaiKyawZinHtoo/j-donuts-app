part of '../../auth_import.dart';

/// PDF screen 4: first/last name entry, with [RegistrationProgressRing] in
/// the app bar at the "name" step (75%).
class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _firstController = TextEditingController();
  final _lastController = TextEditingController();
  bool _isValid = false;
  final _firstFocus = FocusNode();
  final _lastFocus = FocusNode();
  String? _firstBlur;
  String? _lastBlur;

  @override
  void initState() {
    super.initState();
    _firstController.addListener(_revalidate);
    _lastController.addListener(_revalidate);
    _firstFocus.addListener(() {
      if (_firstFocus.hasFocus || _firstController.text.isEmpty) return;
      final r = validateFirstName(_firstController.text);
      setState(() => _firstBlur = r is ValidationInvalid ? r.message : null);
    });
    _lastFocus.addListener(() {
      if (_lastFocus.hasFocus) return;
      final r = validateLastName(_lastController.text);
      setState(() => _lastBlur = r is ValidationInvalid ? r.message : null);
    });
  }

  void _revalidate() {
    final valid =
        validateFirstName(_firstController.text) is ValidationValid &&
        validateLastName(_lastController.text) is ValidationValid;
    setState(() {
      _isValid = valid;
      if (validateFirstName(_firstController.text) is ValidationValid) {
        _firstBlur = null;
      }
      if (validateLastName(_lastController.text) is ValidationValid) {
        _lastBlur = null;
      }
    });
  }

  @override
  void dispose() {
    _firstController.dispose();
    _lastController.dispose();
    _firstFocus.dispose();
    _lastFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent != true) return;
        if (state is AwaitingDob) {
          context.push('/dob');
        } else if (state is OtpAwaiting && context.canPop()) {
          context.pop();
        }
      },
      builder: (context, state) {
        // RegistrationStepInvalid carries one message with no field-level
        // detail, so attribute it by re-running the same validators the
        // bloc used: whichever field they flag is where the message shows.
        String? firstError;
        String? lastError;
        if (state is RegistrationStepInvalid &&
            state.step == RegistrationStep.name) {
          if (validateFirstName(_firstController.text) is ValidationInvalid) {
            firstError = state.message;
          } else {
            lastError = state.message;
          }
        }
        final l10n = AppLocalizations.of(context)!;
        return AuthScaffold(
          onBack: () => context.read<AuthBloc>().add(const BackRequested()),
          trailing: const RegistrationProgressRing(step: RegistrationStep.name),
          bottom: AppButton(
            key: const Key('continueButton'),
            label: l10n.continueButton,
            onPressed: _isValid
                ? () => context.read<AuthBloc>().add(
                    NameSubmitted(
                      _firstController.text,
                      _lastController.text.isEmpty
                          ? null
                          : _lastController.text,
                    ),
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.nameScreenTitle, style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                key: const Key('firstNameField'),
                controller: _firstController,
                focusNode: _firstFocus,
                labelText: l10n.firstNameLabel,
                errorText: firstError ?? _firstBlur,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                key: const Key('lastNameField'),
                controller: _lastController,
                focusNode: _lastFocus,
                labelText: l10n.lastNameLabel,
                errorText: lastError ?? _lastBlur,
              ),
            ],
          ),
        );
      },
    );
  }
}
