import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Core/http/http_manager.dart';
import 'package:malta_wash/Src/Core/http/http_method.dart';
import 'package:malta_wash/Src/Features/booking/domain/booking_repository.dart';

class RemoteBookingRepository implements BookingRepository {
  RemoteBookingRepository(this._http);
  final HttpManager _http;

  List<Map<String, dynamic>> _list(dynamic raw) {
    if (raw is List) {
      return raw
          .map<Map<String, dynamic>?>((item) {
            if (item is Map<String, dynamic>) return item;
            if (item is Map) {
              return item.map((k, v) => MapEntry(k.toString(), v));
            }
            if (item is String || item is num) {
              final value = item.toString().trim();
              if (value.isEmpty) return null;
              return <String, dynamic>{'time': value, 'available': true};
            }
            return null;
          })
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    if (raw is Map) {
      final map = raw.map((k, v) => MapEntry(k.toString(), v));
      for (final key in const [
        'items',
        'data',
        'results',
        'locations',
        'services',
        'addons',
        'appointments',
        'slots',
        'availableSlots',
        'available_times',
        'availableTimes',
        'times',
        'hours',
        'availability',
      ]) {
        if (map[key] != null) {
          final result = _list(map[key]);
          if (result.isNotEmpty || map[key] is List) return result;
        }
      }

      final timeEntries = map.entries
          .where((entry) => RegExp(r'^\d{1,2}:\d{2}$').hasMatch(entry.key))
          .where((entry) => entry.value != false)
          .map((entry) => <String, dynamic>{
                'time': entry.key,
                'available': true,
              })
          .toList();
      if (timeEntries.isNotEmpty) return timeEntries;
    }

    return const [];
  }

  Map<String, dynamic> _map(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }

  @override
  Future<List<Map<String, dynamic>>> locations() async =>
      _list(await _http.request(Endpoints.locations));

  @override
  Future<Map<String, dynamic>> settings() async =>
      _map(await _http.request(Endpoints.settings));

  @override
  Future<List<Map<String, dynamic>>> services() async =>
      _list(await _http.request(Endpoints.services));

  @override
  Future<List<Map<String, dynamic>>> addons() async =>
      _list(await _http.request(Endpoints.serviceAddons));

  @override
  Future<List<Map<String, dynamic>>> appointments({
    String? locationId,
    required String date,
  }) async {
    final raw = await _http.request(
      Endpoints.appointments,
      queryParameters: {
        if (locationId != null && locationId.isNotEmpty)
          'locationId': locationId,
        'date': date,
      },
    );
    return _list(raw);
  }

  @override
  Future<List<Map<String, dynamic>>> availability({
    String? locationId,
    required String serviceId,
    required String vehicleId,
    required String date,
  }) async {
    final raw = await _http.request(
      Endpoints.availability,
      queryParameters: {
        if (locationId != null && locationId.isNotEmpty)
          'locationId': locationId,
        'serviceId': serviceId,
        'vehicleId': vehicleId,
        'date': date,
      },
    );
    return _list(raw);
  }

  @override
  Future<Map<String, dynamic>> createAppointment(
          Map<String, dynamic> payload) async =>
      _map(await _http.request(
        Endpoints.appointments,
        method: HttpMethod.post,
        data: payload,
      ));
}
