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
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.loading && widget.onPressed != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => _setPressed(true) : null,
      onTapUp: enabled ? (_) => _setPressed(false) : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: MotionTokens.kPressScaleDuration,
        curve: Curves.easeOut,
        child: SizedBox(
          height: AppSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: widget.loading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              // Theme's Size.fromHeight is infinite-width; unsafe inside Rows.
              minimumSize: const Size(0, AppSpacing.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
            ),
            child: widget.loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                    ),
                  )
                : Text(widget.label.toUpperCase(), style: AppTextStyles.button),
          ),
        ),
      ),
    );
  }
}
