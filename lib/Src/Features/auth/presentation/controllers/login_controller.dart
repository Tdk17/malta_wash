import 'package:malta_wash/Src/Features/auth/domain/auth_repository.dart';
import 'package:malta_wash/Src/Features/auth/domain/user_session.dart';
import 'package:signals/signals.dart';

class LoginController {
  LoginController(this._repository);
  final AuthRepository _repository;
  final isLoading = signal(false);
  final errorMessage = signal<String?>(null);

  Future<UserSession?> submit(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      return await _repository.login(email: email, password: password);
    } catch (e) {
      errorMessage.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logoutCurrentSession() async {
    try {
      await _repository.logout();
    } catch (_) {
      // O repository sempre limpa a sessão local no finally do logout.
    }
  }
}
