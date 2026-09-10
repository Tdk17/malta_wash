import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Core/http/http_manager.dart';
import 'package:malta_wash/Src/Core/http/http_method.dart';
import 'package:malta_wash/Src/Features/booking/domain/booking_repository.dart';

class RemoteBookingRepository implements BookingRepository {
  RemoteBookingRepository(this._http);
  final HttpManager _http;

  List<Map<String, dynamic>> _list(dynamic raw) {
    final dynamic data = raw is List ? raw : raw is Map ? (raw['items'] ?? raw['data'] ?? raw['slots']) : null;
    if (data is! List) return const [];
    return data.whereType<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))).toList();
  }

  Map<String, dynamic> _map(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }

  @override
  Future<List<Map<String, dynamic>>> locations() async => _list(await _http.request(Endpoints.locations));
  @override
  Future<List<Map<String, dynamic>>> services() async => _list(await _http.request(Endpoints.services));
  @override
  Future<List<Map<String, dynamic>>> addons() async => _list(await _http.request(Endpoints.serviceAddons));

  @override
  Future<List<Map<String, dynamic>>> availability({
    required String locationId,
    required String serviceId,
    required String vehicleId,
    required String date,
  }) async {
    final raw = await _http.request(
      Endpoints.availability,
      queryParameters: {
        'locationId': locationId,
        'serviceId': serviceId,
        'vehicleId': vehicleId,
        'date': date,
      },
    );
    return _list(raw);
  }

  @override
  Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> payload) async => _map(
        await _http.request(Endpoints.appointments, method: HttpMethod.post, data: payload),
      );
}
