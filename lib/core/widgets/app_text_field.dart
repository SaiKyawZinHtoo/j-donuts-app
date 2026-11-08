part of '../core_import.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? prefix;

  const AppTextField({
    super.key,
    required this.controller,
    this.errorText,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefix: prefix,
        errorText: errorText,
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}
