part of '../core_import.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.controller,
    this.errorText,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
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
        errorText: errorText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
