class RewardModel {
  final String id;
  final String userId;
  final String rewardName;
  final String? rewardDescription;
  final int bottlesCount;
  final DateTime awardedAt;

  RewardModel({
    required this.id,
    required this.userId,
    required this.rewardName,
    this.rewardDescription,
    required this.bottlesCount,
    required this.awardedAt,
  });

  /// Create RewardModel from JSON
  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      rewardName: json['reward_name'] as String,
      rewardDescription: json['reward_description'] as String?,
      bottlesCount: json['bottles_count'] as int,
      awardedAt: DateTime.parse(json['awarded_at'] as String),
    );
  }

  /// Convert RewardModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reward_name': rewardName,
      'reward_description': rewardDescription,
      'bottles_count': bottlesCount,
      'awarded_at': awardedAt.toIso8601String(),
    };
  }

  /// Copy with method for immutability
  RewardModel copyWith({
    String? id,
    String? userId,
    String? rewardName,
    String? rewardDescription,
    int? bottlesCount,
    DateTime? awardedAt,
  }) {
    return RewardModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rewardName: rewardName ?? this.rewardName,
      rewardDescription: rewardDescription ?? this.rewardDescription,
      bottlesCount: bottlesCount ?? this.bottlesCount,
      awardedAt: awardedAt ?? this.awardedAt,
    );
  }
}
