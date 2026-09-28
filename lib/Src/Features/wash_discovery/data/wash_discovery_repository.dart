import 'package:malta_wash/Src/Core/http/http_manager.dart';
import 'package:malta_wash/Src/Core/http/http_method.dart';

class WashDiscoveryRepository {
  WashDiscoveryRepository(this._http);
  final HttpManager _http;

  Future<List<Map<String, dynamic>>> nearby({String? city, double? latitude, double? longitude, double radiusKm = 30}) async {
    final raw = await _http.request('/v1/washes-nearby', method: HttpMethod.post, authenticated: false, data: {
      if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'radiusKm': radiusKm,
    });
    final map = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    final items = map['items'] ?? map['results'] ?? map['data'] ?? const [];
    if (items is! List) return const [];
    return items.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
