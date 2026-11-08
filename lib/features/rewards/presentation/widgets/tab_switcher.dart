part of '../../rewards_import.dart';

/// Earn/Gift tab switcher: a sliding pill behind the active label, with an
/// [AnimatedSwitcher] content swap (design spec §6.3).
class TabSwitcher extends StatelessWidget {
  final RewardsTab activeTab;
  final ValueChanged<RewardsTab> onChanged;

  const TabSwitcher({super.key, required this.activeTab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = constraints.maxWidth / 2;
        final duration = _duration(context);
        return Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: duration,
                curve: MotionTokens.kEmphasizedCurve,
                left: activeTab == RewardsTab.earn ? 0 : tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                ),
              ),
              Row(
                children: [
                  _tabButton(context, RewardsTab.earn, AppLocalizations.of(context)!.earnTab),
                  _tabButton(context, RewardsTab.gift, AppLocalizations.of(context)!.giftTab),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Duration _duration(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : MotionTokens.kTabSwitchDuration;

  Widget _tabButton(BuildContext context, RewardsTab tab, String label) {
    return Expanded(
      child: GestureDetector(
        key: Key('rewardsTab_${tab.name}'),
        onTap: () => onChanged(tab),
        child: Center(
          child: AnimatedSwitcher(
            duration: _duration(context),
            child: Text(
              label,
              key: ValueKey(activeTab == tab),
              style: AppTextStyles.body.copyWith(
                color: activeTab == tab ? AppColors.surface : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
