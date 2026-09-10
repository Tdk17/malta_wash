import 'package:malta_wash/Src/Core/storage/secure_storage_service.dart';

class SessionStorage {
  SessionStorage(this._storage);
  final SecureStorageService _storage;

  static const _tokenKey = 'auth_token';
  static const _roleKey = 'auth_role';
  static const _userIdKey = 'auth_user_id';

  Future<void> save({
    required String token,
    String? role,
    String? userId,
  }) async {
    await _storage.write(_tokenKey, token);
    if (role != null) await _storage.write(_roleKey, role);
    if (userId != null) await _storage.write(_userIdKey, userId);
  }

  Future<String?> token() => _storage.read(_tokenKey);
  Future<String?> role() => _storage.read(_roleKey);
  Future<String?> userId() => _storage.read(_userIdKey);
  Future<bool> hasSession() async => (await token())?.isNotEmpty == true;
  Future<void> clear() => _storage.clear();
}
