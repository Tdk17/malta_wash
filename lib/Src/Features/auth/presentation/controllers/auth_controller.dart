import 'package:malta_wash/Src/Core/auth/session_storage.dart';
import 'package:malta_wash/Src/Features/auth/domain/auth_repository.dart';
import 'package:signals/signals.dart';

class AuthController {
  AuthController(this._repository, this._sessionStorage);
  final AuthRepository _repository;
  final SessionStorage _sessionStorage;

  final isLoading = signal(false);
  final errorMessage = signal<String?>(null);
  final me = signal<Map<String, dynamic>?>(null);

  Future<bool> hasSession() => _sessionStorage.hasSession();
  Future<String?> role() => _sessionStorage.role();

  Future<void> loadMe() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      me.value = await _repository.me();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async => _repository.logout();
}
