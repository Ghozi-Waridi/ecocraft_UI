import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart';
import '../utils/constants.dart';

class LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const LeaderboardCard({
    super.key,
    required this.entry,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: isCurrentUser
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            // Rank Badge
            _buildRankBadge(),
            const SizedBox(width: AppConstants.paddingMedium),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.fullName,
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 18,
                      color: isCurrentUser ? AppColors.primary : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${entry.username}',
                    style: AppTextStyles.body2,
                  ),
                ],
              ),
            ),
            
            // Bottle Count
            _buildBottleCount(),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    Color badgeColor;
    String rankText;

    if (entry.rank == 1) {
      badgeColor = AppColors.gold;
      rankText = entry.medal ?? '#1';
    } else if (entry.rank == 2) {
      badgeColor = AppColors.silver;
      rankText = entry.medal ?? '#2';
    } else if (entry.rank == 3) {
      badgeColor = AppColors.bronze;
      rankText = entry.medal ?? '#3';
    } else {
      badgeColor = AppColors.textSecondary;
      rankText = '#${entry.rank}';
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: badgeColor, width: 2),
      ),
      child: Center(
        child: Text(
          rankText,
          style: TextStyle(
            fontSize: entry.isTopThree ? 24 : 18,
            fontWeight: FontWeight.bold,
            color: badgeColor,
          ),
        ),
      ),
    );
  }

  Widget _buildBottleCount() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            AppConstants.bottleEmoji,
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Text(
            '${entry.totalBottles}',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
