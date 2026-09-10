import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';
import 'package:signals/signals.dart';

class ResourceDetailController {
  ResourceDetailController(this._repository, this.endpoint);

  final ResourceRepository _repository;
  final String endpoint;

  final isLoading = signal(false);
  final data = signal<Map<String, dynamic>>(const {});
  final errorMessage = signal<String?>(null);

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      data.value = await _repository.get(endpoint);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
