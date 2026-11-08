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
    final valid = validatePhone(_national(_controller.text)) is ValidationValid;
    if (valid != _isValid || _serverError != null) {
      setState(() {
        _isValid = valid;
        _serverError = null;
      });
    }
  }

  /// Typed text minus any pasted leading `+95`; the prefix is display-only.
  String _national(String typed) {
    final t = typed.trim();
    return t.startsWith('+95') ? t.substring(3) : t;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is OtpAwaiting && previous is! OtpAwaiting,
      listener: (context, state) {
        if (state is PhoneInvalid) {
          setState(() => _serverError = state.message);
          return;
        }
        if (ModalRoute.of(context)?.isCurrent != true) return;
        if (state is OtpAwaiting) {
          context.push('/otp');
        } else if (state is AuthFailure) {
          AppSnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;
        final l10n = AppLocalizations.of(context)!;
        return AuthScaffold(
          trailing: widget.isLogin
              ? null
              : const RegistrationProgressRing(step: RegistrationStep.phone),
          onTapTerms: () {},
          onTapPrivacy: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isLogin ? l10n.loginScreenTitle : l10n.phoneScreenTitle,
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                key: const Key('phoneNumberField'),
                controller: _controller,
                prefix: Text(
                  l10n.phoneCountryCode,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                hintText: l10n.phoneHint,
                keyboardType: TextInputType.phone,
                errorText: _serverError,
              ),
              if (state is PhoneNeedsRegistration && widget.isLogin) ...[
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  key: const Key('registerInsteadLink'),
                  onTap: () => context.push('/phone'),
                  child: Text(
                    l10n.phoneNotFoundRegister,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                key: const Key('continueButton'),
                label: widget.isLogin ? l10n.loginButton : l10n.continueButton,
                loading: loading,
                onPressed: _isValid
                    ? () => context.read<AuthBloc>().add(
                        PhoneSubmitted(
                          _national(_controller.text),
                          isLogin: widget.isLogin,
                        ),
                      )
                    : null,
              ),
              if (widget.isLogin) ...[
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: IconButton(
                    key: const Key('fingerprintButton'),
                    icon: const Icon(Icons.fingerprint),
                    iconSize: AppSpacing.iconSizeMd,
                    style: IconButton.styleFrom(
                      shape: const CircleBorder(),
                      side: const BorderSide(color: AppColors.textSecondary),
                    ),
                    onPressed: () => AppSnackbar.showError(
                      context,
                      l10n.socialSignInUnavailableMessage('Fingerprint'),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
