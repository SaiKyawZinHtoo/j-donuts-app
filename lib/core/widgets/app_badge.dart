part of '../core_import.dart';

/// Orange pill label ("New", "50% off", "New shop") with the app-wide 1px
/// white border. Every badge in the app goes through this widget.
class AppBadge extends StatelessWidget {
  final String label;

  /// Larger variant (product detail).
  final bool large;

  const AppBadge({super.key, required this.label, this.large = false});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.badge,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: AppColors.surface,
          width: AppSpacing.badgeBorder,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: large ? AppSpacing.lg : AppSpacing.md,
          vertical: large ? AppSpacing.sm : AppSpacing.xs + 2,
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyBold
              .copyWith(fontSize: large ? 20 : 14, color: AppColors.surface)
              .embolden(),
        ),
      ),
    );
  }
}
