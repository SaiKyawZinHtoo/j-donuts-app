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
            Navigator.of(context).pushNamed('/dob');
          }
        },
        builder: (context, state) {
          final errorText = state is RegistrationStepInvalid && state.step == RegistrationStep.name
              ? state.message
              : null;
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What is your name?', style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  key: const Key('firstNameField'),
                  controller: _firstController,
                  labelText: 'First name',
                  errorText: errorText,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  key: const Key('lastNameField'),
                  controller: _lastController,
                  labelText: 'Last name',
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  key: const Key('continueButton'),
                  label: 'Continue',
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
