part of '../../auth_import.dart';

/// PDF screen 5/6: date-of-birth entry (month/day/year fields), progress
/// ring morphs into a check icon once the date validates.
class DobScreen extends StatefulWidget {
  /// Test seam; production uses the platform picker.
  @visibleForTesting
  final Future<DateTime?> Function(BuildContext context, DateTime initial)?
  pickDate;

  const DobScreen({super.key, this.pickDate});

  @override
  State<DobScreen> createState() => _DobScreenState();
}

class _DobScreenState extends State<DobScreen> {
  static final _earliest = DateTime(1900);
  DateTime? _dob;

  ValidationResult? get _validation => _dob == null ? null : validateDob(_dob!);
  bool get _isValid => _validation is ValidationValid;

  DateTime get _initial {
    if (_dob != null) return _dob!;
    final now = DateTime.now();
    return DateTime(now.year - 18, now.month, now.day);
  }

  Future<void> _pick() async {
    final picked = widget.pickDate != null
        ? await widget.pickDate!(context, _initial)
        : Theme.of(context).platform == TargetPlatform.iOS
        ? await _pickCupertino()
        : await showDatePicker(
            context: context,
            initialDate: _initial,
            firstDate: _earliest,
            lastDate: DateTime.now(),
          );
    if (picked != null && mounted) setState(() => _dob = picked);
  }

  // Wheel picker in a bottom sheet (iOS); returns null when dismissed.
  Future<DateTime?> _pickCupertino() {
    var temp = _initial;
    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (sheet) => Container(
        height: AppSpacing.datePickerSheetHeight,
        color: AppColors.surface,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                key: const Key('dobPickerDone'),
                onPressed: () => Navigator.of(sheet).pop(temp),
                child: Text(
                  MaterialLocalizations.of(sheet).okButtonLabel,
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: temp,
                minimumYear: _earliest.year,
                maximumDate: DateTime.now(),
                onDateTimeChanged: (d) => temp = d,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    try {
      return DateFormat.MMM(locale).format(_dob!);
    } catch (_) {
      // intl date symbols may not be loaded for this locale.
      return DateFormat.MMM('en').format(_dob!);
    }
  }

  Widget _field(Key key, String label, String? value) {
    return Expanded(
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        onTap: _pick,
        child: InputDecorator(
          isEmpty: value == null,
          decoration: InputDecoration(labelText: label),
          child: Text(
            value ?? '',
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent != true) return;
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
        final v = _validation;
        final errorText = v is ValidationInvalid
            ? v.message
            : state is RegistrationStepInvalid &&
                  state.step == RegistrationStep.dob
            ? state.message
            : null;
        final l10n = AppLocalizations.of(context)!;
        return AuthScaffold(
          onBack: () => context.read<AuthBloc>().add(const BackRequested()),
          trailing: RegistrationProgressRing(
            step: RegistrationStep.dob,
            completed: _isValid,
          ),
          bottom: AppButton(
            key: const Key('continueButton'),
            label: l10n.continueButton,
            loading: loading,
            onPressed: _isValid
                ? () => context.read<AuthBloc>().add(DobSubmitted(_dob!))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.dobScreenTitle, style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  _field(
                    const Key('dobMonthField'),
                    l10n.dobMonthLabel,
                    _dob == null ? null : _monthName(context),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _field(
                    const Key('dobDayField'),
                    l10n.dobDayLabel,
                    _dob?.day.toString(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _field(
                    const Key('dobYearField'),
                    l10n.dobYearLabel,
                    _dob?.year.toString(),
                  ),
                ],
              ),
              if (errorText != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  errorText,
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
