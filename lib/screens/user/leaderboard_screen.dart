import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/leaderboard_card.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeaderboardProvider>(context, listen: false).fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUser?.id;

    return Consumer<LeaderboardProvider>(
      builder: (context, leaderboardProvider, _) {
        if (leaderboardProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (leaderboardProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  leaderboardProvider.errorMessage!,
                  style: AppTextStyles.body1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                ElevatedButton(
                  onPressed: () => leaderboardProvider.refresh(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        final leaderboard = leaderboardProvider.leaderboard;

        if (leaderboard.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '${AppConstants.trophyEmoji}',
                  style: TextStyle(fontSize: 64),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  'Belum ada data leaderboard',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  'Mulai kumpulkan botol untuk masuk leaderboard!',
                  style: AppTextStyles.body2,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => leaderboardProvider.refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            itemCount: leaderboard.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '${AppConstants.trophyEmoji}',
                            style: TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: AppConstants.paddingSmall),
                          Text(
                            'Top 10 Contributors',
                            style: AppTextStyles.h2,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        'Kontributor terbaik bulan ini',
                        style: AppTextStyles.body2,
                      ),
                    ],
                  ),
                );
              }

              final entry = leaderboard[index - 1];
              final isCurrentUser = entry.id == currentUserId;

              return LeaderboardCard(
                entry: entry,
                isCurrentUser: isCurrentUser,
              );
            },
          ),
        );
      },
    );
  }
}
