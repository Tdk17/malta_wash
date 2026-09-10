import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureStorageService {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> clear();
}

class FlutterSecureStorageService implements SecureStorageService {
  const FlutterSecureStorageService();
  static const _storage = FlutterSecureStorage();

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> clear() => _storage.deleteAll();
}
