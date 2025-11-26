import '../config/supabase_config.dart';
import '../models/reward_model.dart';

class RewardService {
  final _supabase = SupabaseConfig.client;

  /// Get all rewards for a specific user
  Future<List<RewardModel>> getUserRewards(String userId) async {
    try {
      final response = await _supabase
          .from('rewards')
          .select()
          .eq('user_id', userId)
          .order('awarded_at', ascending: false);

      return (response as List)
          .map((json) => RewardModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get user rewards error: $e');
      return [];
    }
  }

  /// Get all rewards (admin view)
  Future<List<RewardModel>> getAllRewards() async {
    try {
      final response = await _supabase
          .from('rewards')
          .select()
          .order('awarded_at', ascending: false);

      return (response as List)
          .map((json) => RewardModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get all rewards error: $e');
      return [];
    }
  }

  /// Create a new reward for a user
  Future<RewardModel?> createReward({
    required String userId,
    required String rewardName,
    String? rewardDescription,
    required int bottlesCount,
  }) async {
    try {
      final response = await _supabase
          .from('rewards')
          .insert({
            'user_id': userId,
            'reward_name': rewardName,
            'reward_description': rewardDescription,
            'bottles_count': bottlesCount,
          })
          .select()
          .single();

      return RewardModel.fromJson(response);
    } catch (e) {
      print('Create reward error: $e');
      return null;
    }
  }

  /// Award top 3 users automatically
  Future<List<RewardModel>> awardTopThree({
    String reward1Name = 'Juara 1 Bulan Ini',
    String reward1Desc = 'Voucher Belanja Rp 100.000',
    String reward2Name = 'Juara 2 Bulan Ini',
    String reward2Desc = 'Voucher Belanja Rp 50.000',
    String reward3Name = 'Juara 3 Bulan Ini',
    String reward3Desc = 'Voucher Belanja Rp 25.000',
  }) async {
    try {
      // Get top 3 users
      final topUsers = await _supabase
          .from('users')
          .select()
          .order('total_bottles', ascending: false)
          .limit(3);

      final rewards = <RewardModel>[];

      if (topUsers.isNotEmpty) {
        // Award 1st place
        final reward1 = await createReward(
          userId: topUsers[0]['id'],
          rewardName: reward1Name,
          rewardDescription: reward1Desc,
          bottlesCount: topUsers[0]['total_bottles'],
        );
        if (reward1 != null) rewards.add(reward1);
      }

      if (topUsers.length > 1) {
        // Award 2nd place
        final reward2 = await createReward(
          userId: topUsers[1]['id'],
          rewardName: reward2Name,
          rewardDescription: reward2Desc,
          bottlesCount: topUsers[1]['total_bottles'],
        );
        if (reward2 != null) rewards.add(reward2);
      }

      if (topUsers.length > 2) {
        // Award 3rd place
        final reward3 = await createReward(
          userId: topUsers[2]['id'],
          rewardName: reward3Name,
          rewardDescription: reward3Desc,
          bottlesCount: topUsers[2]['total_bottles'],
        );
        if (reward3 != null) rewards.add(reward3);
      }

      return rewards;
    } catch (e) {
      print('Award top three error: $e');
      return [];
    }
  }

  /// Delete a reward (admin only)
  Future<bool> deleteReward(String rewardId) async {
    try {
      await _supabase
          .from('rewards')
          .delete()
          .eq('id', rewardId);
      return true;
    } catch (e) {
      print('Delete reward error: $e');
      return false;
    }
  }

  /// Get total number of rewards distributed
  Future<int> getTotalRewardsCount() async {
    try {
      final response = await _supabase
          .from('rewards')
          .select('id');
      
      return (response as List).length;
    } catch (e) {
      print('Get total rewards count error: $e');
      return 0;
    }
  }
}
