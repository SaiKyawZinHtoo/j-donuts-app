part of '../core_import.dart';

class AppOtpBox extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final String? errorText;

  const AppOtpBox({
    super.key,
    required this.length,
    required this.onCompleted,
    this.errorText,
  });

  @override
  State<AppOtpBox> createState() => _AppOtpBoxState();
}

class _AppOtpBoxState extends State<AppOtpBox> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _emitIfComplete() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length == widget.length) {
      widget.onCompleted(code);
    }
  }

  void _onChanged(int index, String value) {
    // Paste fill: a multi-char value lands in one box.
    if (value.length > 1) {
      final digits = value.split('').take(widget.length).toList();
      for (var i = 0; i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final nextIndex = digits.length.clamp(0, widget.length - 1);
      _focusNodes[nextIndex].requestFocus();
      _emitIfComplete();
      return;
    }
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    _emitIfComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.length, (index) {
            return SizedBox(
              width: 44,
              height: 52,
              child: KeyboardListener(
                focusNode: FocusNode(skipTraversal: true),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.backspace &&
                      _controllers[index].text.isEmpty &&
                      index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                },
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: widget.length,
                  style: AppTextStyles.h2,
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      borderSide: BorderSide(
                        color: widget.errorText != null
                            ? AppColors.error
                            : AppColors.border,
                      ),
                    ),
                  ),
                  onChanged: (value) => _onChanged(index, value),
                ),
              ),
            );
          }),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(widget.errorText!,
              style: AppTextStyles.caption.copyWith(color: AppColors.error)),
        ],
      ],
    );
  }
}
