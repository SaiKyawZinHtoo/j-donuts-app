part of '../../auth_import.dart';

/// PDF screen 5/6: date-of-birth entry (month/day/year fields), progress
/// ring morphs into a check icon once the date validates.
class DobScreen extends StatefulWidget {
  const DobScreen({super.key});

  @override
  State<DobScreen> createState() => _DobScreenState();
}

class _DobScreenState extends State<DobScreen> {
  final _monthController = TextEditingController();
  final _dayController = TextEditingController();
  final _yearController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_monthController, _dayController, _yearController]) {
      c.addListener(_revalidate);
    }
  }

  DateTime? get _dob {
    final month = int.tryParse(_monthController.text);
    final day = int.tryParse(_dayController.text);
    final year = int.tryParse(_yearController.text);
    if (month == null || day == null || year == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return DateTime(year, month, day);
  }

  void _revalidate() {
    final dob = _dob;
    final valid = dob != null && validateDob(dob) is ValidationValid;
    if (valid != _isValid) setState(() => _isValid = valid);
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: RegistrationProgressRing(
              step: RegistrationStep.dob,
              completed: _isValid,
            ),
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go('/welcome');
          } else if (state is AwaitingName && context.canPop()) {
            context.pop();
          } else if (state is AuthFailure) {
            AppSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          final errorText = state is RegistrationStepInvalid && state.step == RegistrationStep.dob
              ? state.message
              : null;
          final l10n = AppLocalizations.of(context)!;
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.dobScreenTitle, style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        key: const Key('dobMonthField'),
                        controller: _monthController,
                        labelText: l10n.dobMonthLabel,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppTextField(
                        key: const Key('dobDayField'),
                        controller: _dayController,
                        labelText: l10n.dobDayLabel,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppTextField(
                        key: const Key('dobYearField'),
                        controller: _yearController,
                        labelText: l10n.dobYearLabel,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                if (errorText != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(errorText, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
                ],
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  key: const Key('continueButton'),
                  label: l10n.continueButton,
                  loading: loading,
                  onPressed: _isValid
                      ? () => context.read<AuthBloc>().add(DobSubmitted(_dob!))
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
