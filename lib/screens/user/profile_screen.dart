import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/reward_service.dart';
import '../../models/reward_model.dart';
import '../../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final RewardService _rewardService = RewardService();
  List<RewardModel> _rewards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRewards();
  }

  Future<void> _loadRewards() async {
    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    
    if (userId != null) {
      final rewards = await _rewardService.getUserRewards(userId);
      setState(() {
        _rewards = rewards;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadRewards,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(user),
            const SizedBox(height: AppConstants.paddingLarge),

            // Stats Section
            _buildStatsSection(user),
            const SizedBox(height: AppConstants.paddingLarge),

            // Rewards Section
            _buildRewardsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.fullName[0].toUpperCase(),
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingLarge),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: AppTextStyles.h2.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.username}',
                    style: AppTextStyles.body2,
                  ),
                  if (user.email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.email!,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(user) {
    final joinDate = DateFormat('dd MMM yyyy').format(user.createdAt);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistik',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            _buildStatRow(
              icon: Icons.recycling,
              label: 'Total Botol',
              value: '${user.totalBottles}',
              color: AppColors.primary,
            ),
            const Divider(),
            _buildStatRow(
              icon: Icons.calendar_today,
              label: 'Bergabung Sejak',
              value: joinDate,
              color: AppColors.accent,
            ),
            const Divider(),
            _buildStatRow(
              icon: Icons.card_giftcard,
              label: 'Total Reward',
              value: '${_rewards.length}',
              color: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingSmall),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Text(label, style: AppTextStyles.body1),
          ),
          Text(
            value,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Reward',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: AppConstants.paddingMedium),

        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingLarge),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_rewards.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.card_giftcard,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'Belum ada reward',
                      style: AppTextStyles.body1,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      'Kumpulkan lebih banyak botol untuk mendapatkan reward!',
                      style: AppTextStyles.body2,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _rewards.length,
            itemBuilder: (context, index) {
              final reward = _rewards[index];
              return _buildRewardCard(reward);
            },
          ),
      ],
    );
  }

  Widget _buildRewardCard(RewardModel reward) {
    final awardDate = DateFormat('dd MMM yyyy, HH:mm').format(reward.awardedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.emoji_events,
            color: AppColors.warning,
          ),
        ),
        title: Text(
          reward.rewardName,
          style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reward.rewardDescription != null) ...[
              const SizedBox(height: 4),
              Text(reward.rewardDescription!),
            ],
            const SizedBox(height: 4),
            Text(
              '${reward.bottlesCount} botol • $awardDate',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
