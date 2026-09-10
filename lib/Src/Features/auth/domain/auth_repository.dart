import 'package:malta_wash/Src/Features/auth/domain/user_session.dart';

abstract interface class AuthRepository {
  Future<UserSession> login({required String email, required String password});
  Future<UserSession> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? tenantSlug,
  });
  Future<Map<String, dynamic>> me();
  Future<void> logout();
  Future<void> requestPasswordReset(String email);
}
