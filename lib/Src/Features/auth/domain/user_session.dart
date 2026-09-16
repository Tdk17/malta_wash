class UserSession {
  const UserSession({
    required this.token,
    this.userId,
    this.tenantId,
    this.name,
    this.email,
    this.role,
  });

  final String token;
  final String? userId;
  final String? tenantId;
  final String? name;
  final String? email;
  final String? role;

  factory UserSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json['user'] is Map
            ? (json['user'] as Map).map((k, v) => MapEntry(k.toString(), v))
            : <String, dynamic>{};
    final tenant = json['tenant'] is Map<String, dynamic>
        ? json['tenant'] as Map<String, dynamic>
        : json['tenant'] is Map
            ? (json['tenant'] as Map).map((k, v) => MapEntry(k.toString(), v))
            : <String, dynamic>{};
    return UserSession(
      token: (json['token'] ?? json['accessToken'] ?? json['sessionToken'] ?? '').toString(),
      userId: (user['id'] ?? json['userId'])?.toString(),
      tenantId: (tenant['id'] ?? json['tenantId'])?.toString(),
      name: (user['name'] ?? json['name'])?.toString(),
      email: (user['email'] ?? json['email'])?.toString(),
      role: (json['role'] ?? user['role'])?.toString(),
    );
  }
}
