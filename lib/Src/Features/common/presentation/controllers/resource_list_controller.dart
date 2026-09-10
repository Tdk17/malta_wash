import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';
import 'package:signals/signals.dart';

class ResourceListController {
  ResourceListController(this._repository, this.endpoint);
  final ResourceRepository _repository;
  final String endpoint;

  final isLoading = signal(false);
  final items = signal<List<Map<String, dynamic>>>(const []);
  final errorMessage = signal<String?>(null);

  Future<void> load({Map<String, dynamic>? query}) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      items.value = await _repository.list(endpoint, query: query);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
