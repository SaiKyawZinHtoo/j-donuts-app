part of '../../home_import.dart';

/// Member name/photo/tier/points-to-next-tier plus a notification bell
/// (design spec §5.2).
class MemberHeader extends StatelessWidget {
  final Member member;
  final VoidCallback? onBellTap;

  const MemberHeader({super.key, required this.member, this.onBellTap});

  @override
  Widget build(BuildContext context) {
    final pointsToNext = (member.nextTierPoints - member.points).clamp(0, member.nextTierPoints);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: member.photoUrl,
              width: AppSpacing.iconSizeMd,
              height: AppSpacing.iconSizeMd,
              fit: BoxFit.cover,
              placeholder: (context, url) => const AppSkeleton(
                isLoading: true,
                child: SizedBox(width: AppSpacing.iconSizeMd, height: AppSpacing.iconSizeMd),
              ),
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/seed/member_avatar.png',
                width: AppSpacing.iconSizeMd,
                height: AppSpacing.iconSizeMd,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: AppTextStyles.h2),
                Text(
                  '${member.tier} tier · $pointsToNext pts to next tier',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('memberHeader_bellButton'),
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            onPressed: onBellTap,
          ),
        ],
      ),
    );
  }
}
