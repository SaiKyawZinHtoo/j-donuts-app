part of '../../auth_import.dart';

/// PDF screen 2: phone entry with +95 prefix. Continue stays disabled until
/// [validatePhone] passes, giving instant feedback ahead of the bloc call.
class PhoneScreen extends StatefulWidget {
  final bool isLogin;

  const PhoneScreen({super.key, this.isLogin = false});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _controller = TextEditingController();
  bool _isValid = false;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    final valid = validatePhone(_controller.text) is ValidationValid;
    if (valid != _isValid || _serverError != null) {
      setState(() {
        _isValid = valid;
        _serverError = null;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PhoneInvalid) {
            setState(() => _serverError = state.message);
          } else if (state is OtpAwaiting) {
            Navigator.of(context).pushNamed('/otp');
          } else if (state is AuthFailure) {
            AppSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter your phone number', style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  key: const Key('phoneNumberField'),
                  controller: _controller,
                  labelText: '+95',
                  hintText: '9xxxxxxxx',
                  keyboardType: TextInputType.phone,
                  errorText: _serverError,
                ),
                if (state is PhoneNeedsRegistration && widget.isLogin) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    "We couldn't find this number. Register instead?",
                    style: AppTextStyles.caption.copyWith(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  key: const Key('continueButton'),
                  label: 'Continue',
                  loading: loading,
                  onPressed: _isValid
                      ? () => context.read<AuthBloc>().add(PhoneSubmitted(_controller.text))
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
