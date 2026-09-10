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
  final locations = signal<List<Map<String, dynamic>>>(const []);
  final vehicles = signal<List<Map<String, dynamic>>>(const []);
  final services = signal<List<Map<String, dynamic>>>(const []);
  final addons = signal<List<Map<String, dynamic>>>(const []);
  final slots = signal<List<Map<String, dynamic>>>(const []);

  final locationId = signal<String?>(null);
  final vehicleId = signal<String?>(null);
  final serviceId = signal<String?>(null);
  final addonIds = signal<List<String>>(const []);
  final date = signal<DateTime?>(null);
  final startAt = signal<String?>(null);
  final paymentMode = signal('ON_SITE');
  final couponCode = signal<String?>(null);

  Future<void> bootstrap() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait([
        _booking.locations(),
        _booking.services(),
        _booking.addons(),
        _vehicles.list(),
      ]);
      locations.value = results[0] as List<Map<String, dynamic>>;
      services.value = results[1] as List<Map<String, dynamic>>;
      addons.value = results[2] as List<Map<String, dynamic>>;
      vehicles.value = (results[3] as List).map((v) => <String, dynamic>{
            'id': v.id,
            'plate': v.plate,
            'brand': v.brand,
            'model': v.model,
          }).toList();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSlots() async {
    if (locationId.value == null || vehicleId.value == null || serviceId.value == null || date.value == null) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      slots.value = await _booking.availability(
        locationId: locationId.value!,
        serviceId: serviceId.value!,
        vehicleId: vehicleId.value!,
        date: DateFormat('yyyy-MM-dd').format(date.value!),
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> confirm() async {
    if (locationId.value == null || vehicleId.value == null || serviceId.value == null || startAt.value == null) {
      errorMessage.value = 'Preencha todas as etapas obrigatórias.';
      return null;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      return await _booking.createAppointment({
        'locationId': locationId.value,
        'vehicleId': vehicleId.value,
        'serviceId': serviceId.value,
        'addonIds': addonIds.value,
        'startAt': startAt.value,
        'paymentMode': paymentMode.value,
        'couponCode': couponCode.value,
      });
    } catch (e) {
      errorMessage.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
