part of '../../auth_import.dart';

/// Shows registration progress (phone/otp/name/dob = 25/50/75/100%) as a
/// ring; morphs into a check icon once [completed] (DOB step valid).
class RegistrationProgressRing extends StatelessWidget {
  final RegistrationStep step;
  final bool completed;

  const RegistrationProgressRing({
    super.key,
    required this.step,
    this.completed = false,
  });

  double get _progress {
    switch (step) {
      case RegistrationStep.phone:
        return 0.25;
      case RegistrationStep.otp:
        return 0.5;
      case RegistrationStep.name:
        return 0.75;
      case RegistrationStep.dob:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.progressRingSize,
      height: AppSpacing.progressRingSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: AppSpacing.progressRingSize - AppSpacing.progressRingInset * 2,
            height: AppSpacing.progressRingSize - AppSpacing.progressRingInset * 2,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: AppSpacing.progressRingStrokeWidth,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          if (completed)
            const Icon(Icons.check, color: AppColors.accent)
          else
            Text(
              '${(_progress * 100).round()}%',
              style: AppTextStyles.caption,
            ),
        ],
      ),
    );
  }
}
