part of '../../auth_import.dart';

/// PDF screen 3: 6-digit OTP entry, countdown/resend, shake on wrong code,
/// locked state after 3 wrong attempts.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  int _clearSignal = 0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: MotionTokens.kShakeDuration);
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  String _format(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpInvalid) {
            setState(() => _clearSignal++);
            if (!MediaQuery.of(context).disableAnimations) {
              _shakeController.forward(from: 0);
            }
            return;
          }
          if (ModalRoute.of(context)?.isCurrent != true) return;
          if (state is AwaitingName) {
            context.push('/name');
          } else if (state is AuthSuccess) {
            context.go('/home');
          } else if (state is AuthInitial && context.canPop()) {
            context.pop();
          } else if (state is AuthFailure) {
            AppSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final locked = state is OtpLocked;
          final secondsLeft = state is OtpAwaiting ? state.secondsLeft : 0;
          final l10n = AppLocalizations.of(context)!;
          final errorText = state is OtpInvalid
              ? l10n.otpIncorrectCode(state.attemptsLeft)
              : locked
              ? l10n.otpLocked
              : null;
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.otpScreenTitle, style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.otpSubtitle(state.draft.phone ?? ''),
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.lg),
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  ),
                  child: IgnorePointer(
                    ignoring: locked,
                    child: Opacity(
                      opacity: locked ? 0.4 : 1,
                      child: AppOtpBox(
                        key: const Key('otpInput'),
                        length: 6,
                        errorText: errorText,
                        clearSignal: _clearSignal,
                        onCompleted: (code) =>
                            context.read<AuthBloc>().add(OtpDigitEntered(code)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.didntReceiveCode, style: AppTextStyles.caption),
                GestureDetector(
                  key: const Key('resendCodeButton'),
                  onTap: secondsLeft == 0
                      ? () => context.read<AuthBloc>().add(const OtpResendRequested())
                      : null,
                  child: Text(
                    secondsLeft == 0 ? l10n.resendCode : l10n.resendIn(_format(secondsLeft)),
                    style: AppTextStyles.caption.copyWith(
                      color: secondsLeft == 0 ? AppColors.accent : AppColors.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                AppLegalFooter(onTapTerms: () {}, onTapPrivacy: () {}),
              ],
            ),
          );
        },
      ),
    );
  }
}
