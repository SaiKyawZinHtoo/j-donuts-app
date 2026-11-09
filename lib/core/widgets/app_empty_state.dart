part of '../core_import.dart';

class AppEmptyState extends StatelessWidget {
  final String message;

  const AppEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduce ? 1 : 0, end: 1),
      duration: reduce ? Duration.zero : MotionTokens.kEmptyStateEntrance,
      curve: MotionTokens.kEmphasizedCurve,
      builder: (context, t, child) => Opacity(opacity: t, child: child),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: AppSpacing.iconSizeMd,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
