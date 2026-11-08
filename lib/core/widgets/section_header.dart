part of '../core_import.dart';

/// Section title with a white circular chevron button; inert when [onTap] is null.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const SectionHeader({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.h2)),
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: const SizedBox(
              width: AppSpacing.chevronButtonSize,
              height: AppSpacing.chevronButtonSize,
              child: Icon(Icons.chevron_right, color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
