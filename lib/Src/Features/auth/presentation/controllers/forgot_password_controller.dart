import 'package:malta_wash/Src/Features/auth/domain/auth_repository.dart';
import 'package:signals/signals.dart';

class ForgotPasswordController {
  ForgotPasswordController(this._repository);
  final AuthRepository _repository;
  final isLoading = signal(false);
  final message = signal<String?>(null);
  final errorMessage = signal<String?>(null);

  Future<void> submit(String email) async {
    isLoading.value = true;
    errorMessage.value = null;
    message.value = null;
    try {
      await _repository.requestPasswordReset(email);
      message.value = 'Solicitação enviada. Verifique seu e-mail.';
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
