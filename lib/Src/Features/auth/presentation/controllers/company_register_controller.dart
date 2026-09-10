import 'package:malta_wash/Src/Features/auth/domain/auth_repository.dart';
import 'package:malta_wash/Src/Features/auth/domain/user_session.dart';
import 'package:signals/signals.dart';

class CompanyRegisterController {
  CompanyRegisterController(this._repository);

  final AuthRepository _repository;
  final isLoading = signal(false);
  final errorMessage = signal<String?>(null);

  Future<UserSession?> submit({
    required String companyName,
    required String ownerName,
    required String phone,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      return await _repository.registerCompany(
        companyName: companyName,
        ownerName: ownerName,
        phone: phone,
        email: email,
        password: password,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
