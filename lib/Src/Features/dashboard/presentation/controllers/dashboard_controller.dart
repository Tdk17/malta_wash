import 'package:malta_wash/Src/Features/dashboard/domain/dashboard_repository.dart';
import 'package:signals/signals.dart';

class DashboardController {
  DashboardController(this._repository);
  final DashboardRepository _repository;
  final isLoading = signal(false);
  final errorMessage = signal<String?>(null);
  final metrics = signal<Map<String, dynamic>>(const {});
  final operation = signal<Map<String, dynamic>>(const {});

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final values = await Future.wait([_repository.metrics(), _repository.operation()]);
      metrics.value = values[0];
      operation.value = values[1];
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
