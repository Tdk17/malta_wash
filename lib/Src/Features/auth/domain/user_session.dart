class UserSession {
  const UserSession({
    required this.token,
    this.userId,
    this.name,
    this.email,
    this.role,
  });

  final String token;
  final String? userId;
  final String? name;
  final String? email;
  final String? role;

  factory UserSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : <String, dynamic>{};
    return UserSession(
      token: (json['token'] ?? json['accessToken'] ?? json['sessionToken'] ?? '').toString(),
      userId: (user['id'] ?? json['userId'])?.toString(),
      name: (user['name'] ?? json['name'])?.toString(),
      email: (user['email'] ?? json['email'])?.toString(),
      role: (json['role'] ?? user['role'])?.toString(),
    );
  }
}
