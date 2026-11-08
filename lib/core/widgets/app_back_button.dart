part of '../core_import.dart';

/// White rounded-square back button. Default action pops only if possible.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
          onTap: onPressed ??
              () {
                if (context.canPop()) context.pop();
              },
          child: const SizedBox.square(
            dimension: AppSpacing.backButtonSize,
            child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
        ),
      );
}
