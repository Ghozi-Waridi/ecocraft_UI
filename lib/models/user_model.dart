class UserModel {
  final String id;
  final String username;
  final String fullName;
  final String? email;
  final int totalBottles;
  final String role; // 'admin' or 'user'
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    this.email,
    required this.totalBottles,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      // Use full_name if available, otherwise use username
      fullName: json['full_name'] as String? ?? json['username'] as String,
      email: json['email'] as String?,
      totalBottles: json['total_bottles'] as int? ?? 0,
      role: json['role'] as String? ?? 'user',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'email': email,
      'total_bottles': totalBottles,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Copy with method for immutability
  UserModel copyWith({
    String? id,
    String? username,
    String? fullName,
    String? email,
    int? totalBottles,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      totalBottles: totalBottles ?? this.totalBottles,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
