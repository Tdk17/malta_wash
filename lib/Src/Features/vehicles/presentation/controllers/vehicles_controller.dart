import 'package:malta_wash/Src/Features/vehicles/domain/vehicle.dart';
import 'package:malta_wash/Src/Features/vehicles/domain/vehicles_repository.dart';
import 'package:signals/signals.dart';

class VehiclesController {
  VehiclesController(this._repository);
  final VehiclesRepository _repository;
  final isLoading = signal(false);
  final items = signal<List<Vehicle>>(const []);
  final errorMessage = signal<String?>(null);

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      items.value = await _repository.list();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> create(Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _repository.create(payload);
      await load();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
