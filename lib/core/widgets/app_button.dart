part of '../core_import.dart';

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  static const double _pressedScale = 0.97;
  static const double _spinnerSize = 20;
  static const double _spinnerStroke = 2;

  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.loading && widget.onPressed != null;
    final reduce = MediaQuery.of(context).disableAnimations;
    final scaleDuration = reduce
        ? Duration.zero
        : MotionTokens.kPressScaleDuration;
    final morphDuration = reduce
        ? Duration.zero
        : MotionTokens.kButtonMorphDuration;

    final button = Listener(
      // Listener, not GestureDetector: the inner ElevatedButton wins the tap arena.
      onPointerDown: enabled ? (_) => _setPressed(true) : null,
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? _pressedScale : 1.0,
        duration: scaleDuration,
        curve: Curves.easeOut,
        child: SizedBox(
          height: AppSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: widget.loading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              disabledBackgroundColor: AppColors.primaryDisabled,
              disabledForegroundColor: AppColors.surface,
              minimumSize: const Size(0, AppSpacing.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
              ),
            ),
            child: AnimatedSwitcher(
              duration: morphDuration,
              child: widget.loading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      height: _spinnerSize,
                      width: _spinnerSize,
                      child: CircularProgressIndicator(
                        strokeWidth: _spinnerStroke,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.surface,
                        ),
                      ),
                    )
                  : Text(
                      widget.label.toUpperCase(),
                      key: const ValueKey('label'),
                      style: AppTextStyles.button,
                    ),
            ),
          ),
        ),
      ),
    );

    // Fill bounded width; in a Row (unbounded) fall back to natural width.
    return LayoutBuilder(
      builder: (context, constraints) => constraints.hasBoundedWidth
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}
