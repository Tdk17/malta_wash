import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Core/http/http_manager.dart';
import 'package:malta_wash/Src/Core/http/http_method.dart';
import 'package:malta_wash/Src/Features/vehicles/domain/vehicle.dart';
import 'package:malta_wash/Src/Features/vehicles/domain/vehicles_repository.dart';

class RemoteVehiclesRepository implements VehiclesRepository {
  RemoteVehiclesRepository(this._http);
  final HttpManager _http;

  Map<String, dynamic> _map(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }

  @override
  Future<List<Vehicle>> list() async {
    final raw = await _http.request(Endpoints.vehicles);
    final dynamic listRaw = raw is List ? raw : raw is Map ? (raw['items'] ?? raw['data']) : null;
    if (listRaw is! List) return const [];
    return listRaw.whereType<Map>().map((e) => Vehicle.fromJson(e.map((k, v) => MapEntry(k.toString(), v)))).toList();
  }

  @override
  Future<Vehicle> create(Map<String, dynamic> payload) async => Vehicle.fromJson(_map(
        await _http.request(Endpoints.vehicles, method: HttpMethod.post, data: payload),
      ));

  @override
  Future<Vehicle> update(String id, Map<String, dynamic> payload) async => Vehicle.fromJson(_map(
        await _http.request(Endpoints.vehicle(id), method: HttpMethod.patch, data: payload),
      ));

  @override
  Future<void> delete(String id) async {
    await _http.request(Endpoints.vehicle(id), method: HttpMethod.delete);
  }
}
