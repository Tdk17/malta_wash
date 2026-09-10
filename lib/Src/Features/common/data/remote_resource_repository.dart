import 'package:malta_wash/Src/Core/http/http_manager.dart';
import 'package:malta_wash/Src/Core/http/http_method.dart';
import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';

class RemoteResourceRepository implements ResourceRepository {
  RemoteResourceRepository(this._http);
  final HttpManager _http;

  Map<String, dynamic> _map(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }

  @override
  Future<List<Map<String, dynamic>>> list(String endpoint, {Map<String, dynamic>? query}) async {
    final raw = await _http.request(endpoint, queryParameters: query);
    final dynamic listRaw = raw is List
        ? raw
        : raw is Map
            ? (raw['items'] ?? raw['data'] ?? raw['results'])
            : null;
    if (listRaw is! List) return const [];
    return listRaw.whereType<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))).toList();
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint) async => _map(await _http.request(endpoint));

  @override
  Future<Map<String, dynamic>> create(String endpoint, Map<String, dynamic> payload) async =>
      _map(await _http.request(endpoint, method: HttpMethod.post, data: payload));

  @override
  Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> payload) async =>
      _map(await _http.request(endpoint, method: HttpMethod.patch, data: payload));

  @override
  Future<void> delete(String endpoint) async {
    await _http.request(endpoint, method: HttpMethod.delete);
  }
}
