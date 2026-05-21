class UserStats {
  final String userId;
  final String name;
  final String email;
  final String role;
  final int productCount;

  UserStats({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.productCount,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'client',
      productCount: (json['productCount'] is num) ? (json['productCount'] as num).toInt() : 0,
    );
  }
}
