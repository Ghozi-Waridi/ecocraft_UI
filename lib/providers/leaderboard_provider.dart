import 'package:flutter/foundation.dart';
import '../models/leaderboard_entry.dart';
import '../services/user_service.dart';

class LeaderboardProvider with ChangeNotifier {
  final UserService _userService = UserService();
  
  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<LeaderboardEntry> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch leaderboard data
  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _leaderboard = await _userService.getLeaderboard();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat leaderboard: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get user's rank
  Future<int?> getUserRank(String userId) async {
    try {
      return await _userService.getUserRank(userId);
    } catch (e) {
      print('Get user rank error: $e');
      return null;
    }
  }

  /// Refresh leaderboard
  Future<void> refresh() async {
    await fetchLeaderboard();
  }
}
