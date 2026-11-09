part of '../core_import.dart';

class AppOtpBox extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final String? errorText;

  /// Bump this value (e.g. from a parent's error-state listener) to clear
  /// all boxes and refocus the first one.
  final int clearSignal;

  const AppOtpBox({
    super.key,
    required this.length,
    required this.onCompleted,
    this.errorText,
    this.clearSignal = 0,
  });

  @override
  State<AppOtpBox> createState() => _AppOtpBoxState();
}

class _AppOtpBoxState extends State<AppOtpBox> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final List<FocusNode> _keyListenerNodes;
  late List<String> _prevValues;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _keyListenerNodes = List.generate(
      widget.length,
      (_) => FocusNode(skipTraversal: true),
    );
    _prevValues = List.generate(widget.length, (_) => '');
  }

  @override
  void didUpdateWidget(AppOtpBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.clearSignal != oldWidget.clearSignal) {
      for (final c in _controllers) {
        c.clear();
      }
      _prevValues = List.generate(widget.length, (_) => '');
      _focusNodes.first.requestFocus();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    for (final f in _keyListenerNodes) {
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
    final wasEmpty = _prevValues[index].isEmpty;
    _prevValues[index] = value;
    // Paste fill: a multi-char value landing in an EMPTY box. A box that
    // already held a digit and received another keystroke also reports a
    // multi-char value (old char + new one appended) -- that's not a
    // paste, so only keep the newly typed last character.
    if (value.length > 1 && wasEmpty) {
      final digits = value.split('').take(widget.length).toList();
      for (var i = 0; i < digits.length; i++) {
        _controllers[i].text = digits[i];
        _prevValues[i] = digits[i];
      }
      final nextIndex = digits.length.clamp(0, widget.length - 1);
      _focusNodes[nextIndex].requestFocus();
      _emitIfComplete();
      return;
    }
    if (value.length > 1) {
      final last = value[value.length - 1];
      _controllers[index].text = last;
      _prevValues[index] = last;
      value = last;
    }
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    _emitIfComplete();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final fieldDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : MotionTokens.kFieldStateDuration;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.length, (index) {
            return SizedBox(
              width: AppSpacing.otpBoxWidth,
              height: AppSpacing.otpBoxHeight,
              child: KeyboardListener(
                focusNode: _keyListenerNodes[index],
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.backspace &&
                      _controllers[index].text.isEmpty &&
                      index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                },
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(
                    end: hasError ? AppColors.error : AppColors.border,
                  ),
                  duration: fieldDuration,
                  builder: (context, animated, _) {
                    final borderColor = animated ?? AppColors.border;
                    return TextField(
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
                        border: _border(borderColor, AppColors.border),
                        enabledBorder: _border(borderColor, AppColors.border),
                        focusedBorder: _border(
                          hasError ? borderColor : AppColors.accent,
                          AppColors.accent,
                        ),
                      ),
                      onChanged: (value) => _onChanged(index, value),
                    );
                  },
                ),
              ),
            );
          }),
        ),
        if (fieldDuration == Duration.zero)
          hasError ? _errorText() : const SizedBox.shrink()
        else
          AnimatedSize(
            duration: fieldDuration,
            curve: MotionTokens.kEmphasizedCurve,
            alignment: Alignment.topLeft,
            child: AnimatedSwitcher(
              duration: fieldDuration,
              child: hasError
                  ? _errorText()
                  : const SizedBox(width: double.infinity),
            ),
          ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, Color _) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSpacing.sm),
    borderSide: BorderSide(color: color),
  );

  Widget _errorText() => Padding(
    key: ValueKey(widget.errorText),
    padding: const EdgeInsets.only(top: AppSpacing.xs),
    child: Text(
      widget.errorText!,
      style: AppTextStyles.caption.copyWith(color: AppColors.error),
    ),
  );
}
