import 'package:malta_wash/Src/Features/auth/domain/auth_repository.dart';
import 'package:malta_wash/Src/Features/auth/domain/user_session.dart';
import 'package:signals/signals.dart';

class RegisterController {
  RegisterController(this._repository);
  final AuthRepository _repository;
  final isLoading = signal(false);
  final errorMessage = signal<String?>(null);

  Future<UserSession?> submit({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? tenantSlug,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      return await _repository.register(
        name: name,
        phone: phone,
        email: email,
        password: password,
        tenantSlug: tenantSlug,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
