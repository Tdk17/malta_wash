import 'package:malta_wash/Src/Core/auth/session_storage.dart';
import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Core/http/http_manager.dart';
import 'package:malta_wash/Src/Core/http/http_method.dart';
import 'package:malta_wash/Src/Features/auth/domain/auth_repository.dart';
import 'package:malta_wash/Src/Features/auth/domain/user_session.dart';

class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository({required this.httpManager, required this.sessionStorage});
  final HttpManager httpManager;
  final SessionStorage sessionStorage;

  Map<String, dynamic> _map(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
    throw const FormatException('Resposta inesperada da API.');
  }

  @override
  Future<UserSession> login({required String email, required String password}) async {
    final raw = await httpManager.request(
      Endpoints.login,
      method: HttpMethod.post,
      authenticated: false,
      data: {'email': email.trim(), 'password': password},
    );
    final session = UserSession.fromJson(_map(raw));
    if (session.token.isEmpty) throw const FormatException('Token ausente no login.');
    await sessionStorage.save(token: session.token, role: session.role, userId: session.userId);
    return session;
  }

  @override
  Future<UserSession> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? tenantSlug,
  }) async {
    final slug = tenantSlug?.trim();
    final raw = await httpManager.request(
      Endpoints.register,
      method: HttpMethod.post,
      authenticated: false,
      data: {
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'password': password,
        if (slug != null && slug.isNotEmpty) 'tenantSlug': slug,
      },
    );
    final session = UserSession.fromJson(_map(raw));
    if (session.token.isNotEmpty) {
      await sessionStorage.save(token: session.token, role: session.role, userId: session.userId);
    }
    return session;
  }

  @override
  Future<UserSession> registerCompany({
    required String companyName,
    required String ownerName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final raw = await httpManager.request(
      Endpoints.registerCompany,
      method: HttpMethod.post,
      authenticated: false,
      data: {
        'companyName': companyName.trim(),
        'ownerName': ownerName.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'password': password,
        'timezone': 'America/Sao_Paulo',
        'planCode': 'STARTER',
      },
    );

    final session = UserSession.fromJson(_map(raw));
    if (session.token.isEmpty) {
      throw const FormatException('Token ausente após o cadastro da empresa.');
    }
    await sessionStorage.save(token: session.token, role: session.role, userId: session.userId);
    return session;
  }

  @override
  Future<Map<String, dynamic>> me() async => _map(await httpManager.request(Endpoints.me));

  @override
  Future<void> logout() async {
    try {
      await httpManager.request(Endpoints.logout, method: HttpMethod.post);
    } finally {
      await sessionStorage.clear();
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await httpManager.request(
      Endpoints.passwordReset,
      method: HttpMethod.post,
      authenticated: false,
      data: {'email': email.trim()},
    );
  }
}
