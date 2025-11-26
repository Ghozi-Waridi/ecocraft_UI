class LeaderboardEntry {
  final int rank;
  final String id;
  final String username;
  final String fullName;
  final int totalBottles;
  final DateTime createdAt;

  LeaderboardEntry({
    required this.rank,
    required this.id,
    required this.username,
    required this.fullName,
    required this.totalBottles,
    required this.createdAt,
  });

  /// Create LeaderboardEntry from JSON
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      id: json['id'] as String,
      username: json['username'] as String,
      // Use full_name if available, otherwise use username
      fullName: json['full_name'] as String? ?? json['username'] as String,
      totalBottles: json['total_bottles'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert LeaderboardEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'id': id,
      'username': username,
      'full_name': fullName,
      'total_bottles': totalBottles,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Check if this entry is in top 3
  bool get isTopThree => rank <= 3;

  /// Get medal emoji for top 3
  String? get medal {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return null;
    }
  }
}
