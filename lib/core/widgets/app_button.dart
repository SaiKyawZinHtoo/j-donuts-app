part of '../core_import.dart';

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  /// Optional text shown after a thin divider (e.g. a live total).
  final String? trailingLabel;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.trailingLabel,
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

  Widget _content(bool reduce) {
    final label = Text(
      widget.label.toUpperCase(),
      key: const ValueKey('label'),
      style: AppTextStyles.button,
    );
    final trailing = widget.trailingLabel;
    if (trailing == null) return label;
    return Row(
      key: const ValueKey('label'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(widget.label.toUpperCase(), style: AppTextStyles.button)),
        Container(
          width: 1,
          height: AppSpacing.md,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          color: AppColors.surface,
        ),
        AnimatedSwitcher(
          duration: reduce ? Duration.zero : MotionTokens.kQtyChange,
          child: Text(
            trailing.toUpperCase(),
            key: ValueKey(trailing),
            style: AppTextStyles.button,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.loading && widget.onPressed != null;
    final reduce = MediaQuery.disableAnimationsOf(context);
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
            // No-op while loading keeps the enabled (primary) look but ignores taps.
            onPressed: widget.loading ? () {} : widget.onPressed,
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
            child: Semantics(
              label: widget.trailingLabel == null
                  ? widget.label
                  : '${widget.label}, ${widget.trailingLabel}',
              excludeSemantics: true,
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
                    : _content(reduce),
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
