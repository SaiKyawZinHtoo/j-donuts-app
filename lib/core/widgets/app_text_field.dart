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
      style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.hint),
        // prefixIcon (not prefix): InputDecoration.prefix hides when unfocused+empty.
        prefixIcon: prefix == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.sm,
                ),
                child: prefix,
              ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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
