import 'package:malta_wash/Src/Features/auth/domain/auth_repository.dart';
import 'package:malta_wash/Src/Features/branding/domain/tenant_branding.dart';
import 'package:signals/signals.dart';

class BrandingController {
  BrandingController(this._authRepository);
  final AuthRepository _authRepository;
  final branding = signal(const TenantBranding());

  Future<void> load() async {
    try {
      branding.value = TenantBranding.fromAuthMe(await _authRepository.me());
    } catch (_) {
      // Mantém apenas o branding visual local do primeiro cliente.
    }
  }
}
