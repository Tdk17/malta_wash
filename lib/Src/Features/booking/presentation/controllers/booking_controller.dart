import 'package:intl/intl.dart';
import 'package:malta_wash/Src/Features/booking/domain/booking_repository.dart';
import 'package:malta_wash/Src/Features/vehicles/domain/vehicles_repository.dart';
import 'package:signals/signals.dart';

class BookingController {
  BookingController(this._booking, this._vehicles);
  final BookingRepository _booking;
  final VehiclesRepository _vehicles;

  final isLoading = signal(false);
  final errorMessage = signal<String?>(null);
  final step = signal(0);
  final vehicles = signal<List<Map<String, dynamic>>>(const []);
  final services = signal<List<Map<String, dynamic>>>(const []);
  final slots = signal<List<Map<String, dynamic>>>(const []);

  final vehicleId = signal<String?>(null);
  final serviceId = signal<String?>(null);
  final date = signal<DateTime?>(null);
  final startAt = signal<String?>(null);

  String? _legacyLocationId;

  Future<void> bootstrap() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait([
        _booking.services(),
        _vehicles.list(),
        _loadLegacyDefaultLocation(),
      ]);

      services.value = (results[0] as List<Map<String, dynamic>>)
          .where(_hasUsableId)
          .where((item) => item['active'] != false)
          .toList();
      vehicles.value = (results[1] as List)
          .map((v) => <String, dynamic>{
                'id': v.id,
                'plate': v.plate,
                'model': v.model,
                'color': v.color,
                'category': v.category,
              })
          .where(_hasUsableId)
          .toList();

      if (vehicles.value.length == 1) vehicleId.value = _id(vehicles.value.first);
      if (services.value.length == 1) serviceId.value = _id(services.value.first);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadLegacyDefaultLocation() async {
    try {
      final items = (await _booking.locations())
          .where(_hasUsableId)
          .where((item) => item['active'] != false)
          .toList();
      if (items.isNotEmpty) _legacyLocationId = _id(items.first);
    } catch (_) {
      // Compatibilidade temporária: o MVP não depende mais de unidade.
      _legacyLocationId = null;
    }
  }

  Future<void> loadSlots() async {
    if (vehicleId.value == null || serviceId.value == null || date.value == null) return;
    isLoading.value = true;
    errorMessage.value = null;
    startAt.value = null;
    try {
      slots.value = await _booking.availability(
        locationId: _legacyLocationId,
        serviceId: serviceId.value!,
        vehicleId: vehicleId.value!,
        date: DateFormat('yyyy-MM-dd').format(date.value!),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      slots.value = const [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> confirm() async {
    if (vehicleId.value == null || serviceId.value == null || startAt.value == null) {
      errorMessage.value = 'Preencha todas as etapas obrigatórias.';
      return null;
    }

    isLoading.value = true;
    errorMessage.value = null;
    try {
      return await _booking.createAppointment({
        if (_legacyLocationId != null) 'locationId': _legacyLocationId,
        'vehicleId': vehicleId.value,
        'serviceId': serviceId.value,
        'startAt': startAt.value,
      });
    } catch (e) {
      errorMessage.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  bool _hasUsableId(Map<String, dynamic> item) => _id(item).isNotEmpty;

  String _id(Map<String, dynamic> item) =>
      (item['id'] ?? item['objectId'] ?? '').toString().trim();
}
