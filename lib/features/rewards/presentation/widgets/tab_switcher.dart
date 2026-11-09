part of '../../rewards_import.dart';

/// Earn/Gift pills (reference screen 10): the active pill is cyan, the other
/// light grey, both with a white outline. Colors cross-fade on switch.
class TabSwitcher extends StatelessWidget {
  final RewardsTab activeTab;
  final ValueChanged<RewardsTab> onChanged;

  const TabSwitcher({
    super.key,
    required this.activeTab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : MotionTokens.kTabSwitchDuration;
    Widget pill(RewardsTab tab, String label) {
      final active = activeTab == tab;
      return GestureDetector(
        key: Key('rewardsTab_${tab.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(tab),
        child: AnimatedContainer(
          duration: duration,
          curve: MotionTokens.kEmphasizedCurve,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: active ? AppColors.navBar : AppColors.pageGrey,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            border: Border.all(color: AppColors.surface, width: 3),
          ),
          child: AnimatedDefaultTextStyle(
            duration: duration,
            style: (active ? AppTextStyles.bodyBold : AppTextStyles.body)
                .copyWith(
                  color: active ? AppColors.surface : AppColors.textSecondary,
                ),
            child: Text(label),
          ),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.xs,
      children: [
        pill(RewardsTab.earn, l10n.earnMoreTab),
        pill(RewardsTab.gift, l10n.giftTab),
      ],
    );
  }
}
