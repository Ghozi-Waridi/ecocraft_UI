import '../config/supabase_config.dart';
import '../models/user_model.dart';
import '../models/leaderboard_entry.dart';

class UserService {
  final _supabase = SupabaseConfig.client;

  /// Get all users ordered by total bottles
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .order('total_bottles', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get all users error: $e');
      return [];
    }
  }

  /// Get leaderboard (top 10 users)
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      final response = await _supabase
          .from('leaderboard')
          .select();

      return (response as List)
          .map((json) => LeaderboardEntry.fromJson(json))
          .toList();
    } catch (e) {
      print('Get leaderboard error: $e');
      return [];
    }
  }

  /// Get user's rank in leaderboard
  Future<int?> getUserRank(String userId) async {
    try {
      final response = await _supabase
          .from('leaderboard')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        // User not in top 10, calculate rank manually
        final allUsers = await getAllUsers();
        final index = allUsers.indexWhere((user) => user.id == userId);
        return index >= 0 ? index + 1 : null;
      }

      return response['rank'] as int;
    } catch (e) {
      print('Get user rank error: $e');
      return null;
    }
  }

  /// Increment user's bottle count
  Future<bool> incrementBottles(String username, {int amount = 1}) async {
    try {
      await _supabase.rpc('increment_bottles', params: {
        'user_username': username,
        'amount': amount,
      });
      return true;
    } catch (e) {
      print('Increment bottles error: $e');
      return false;
    }
  }

  /// Update user's bottle count directly (admin only)
  Future<bool> updateBottleCount(String userId, int newCount) async {
    try {
      await _supabase
          .from('users')
          .update({'total_bottles': newCount})
          .eq('id', userId);
      return true;
    } catch (e) {
      print('Update bottle count error: $e');
      return false;
    }
  }

  /// Get total number of users
  Future<int> getTotalUsersCount() async {
    try {
      final response = await _supabase
          .from('users')
          .select('id');
      
      return (response as List).length;
    } catch (e) {
      print('Get total users count error: $e');
      return 0;
    }
  }

  /// Get total bottles collected across all users
  Future<int> getTotalBottlesCollected() async {
    try {
      final response = await _supabase
          .from('users')
          .select('total_bottles');

      int total = 0;
      for (var user in response as List) {
        total += (user['total_bottles'] as int? ?? 0);
      }
      return total;
    } catch (e) {
      print('Get total bottles error: $e');
      return 0;
    }
  }

  /// Delete user (admin only)
  Future<bool> deleteUser(String userId) async {
    try {
      await _supabase
          .from('users')
          .delete()
          .eq('id', userId);
      return true;
    } catch (e) {
      print('Delete user error: $e');
      return false;
    }
  }

  /// Update user information
  Future<UserModel?> updateUser({
    required String userId,
    String? fullName,
    String? email,
    String? role,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (email != null) updates['email'] = email;
      if (role != null) updates['role'] = role;

      if (updates.isEmpty) return null;

      final response = await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Update user error: $e');
      return null;
    }
  }
}
