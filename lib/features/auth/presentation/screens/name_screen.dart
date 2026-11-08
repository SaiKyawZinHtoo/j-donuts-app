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

  @override
  void initState() {
    super.initState();
    _firstController.addListener(_revalidate);
    _lastController.addListener(_revalidate);
  }

  void _revalidate() {
    final valid = validateFirstName(_firstController.text) is ValidationValid &&
        validateLastName(_lastController.text) is ValidationValid;
    if (valid != _isValid) setState(() => _isValid = valid);
  }

  @override
  void dispose() {
    _firstController.dispose();
    _lastController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<AuthBloc>().add(const BackRequested()),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: RegistrationProgressRing(step: RegistrationStep.name),
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
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
          if (state is RegistrationStepInvalid && state.step == RegistrationStep.name) {
            if (validateFirstName(_firstController.text) is ValidationInvalid) {
              firstError = state.message;
            } else {
              lastError = state.message;
            }
          }
          final l10n = AppLocalizations.of(context)!;
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.nameScreenTitle, style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  key: const Key('firstNameField'),
                  controller: _firstController,
                  labelText: l10n.firstNameLabel,
                  errorText: firstError,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  key: const Key('lastNameField'),
                  controller: _lastController,
                  labelText: l10n.lastNameLabel,
                  errorText: lastError,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  key: const Key('continueButton'),
                  label: l10n.continueButton,
                  onPressed: _isValid
                      ? () => context.read<AuthBloc>().add(
                          NameSubmitted(
                            _firstController.text,
                            _lastController.text.isEmpty ? null : _lastController.text,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
