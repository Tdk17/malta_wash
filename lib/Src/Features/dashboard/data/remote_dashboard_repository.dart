import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Core/http/http_manager.dart';
import 'package:malta_wash/Src/Features/dashboard/domain/dashboard_repository.dart';

class RemoteDashboardRepository implements DashboardRepository {
  RemoteDashboardRepository(this._http);
  final HttpManager _http;
  Map<String, dynamic> _map(dynamic raw) => raw is Map<String, dynamic>
      ? raw
      : raw is Map
          ? raw.map((k, v) => MapEntry(k.toString(), v))
          : <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> metrics() async => _map(await _http.request(Endpoints.dashboardMetrics));
  @override
  Future<Map<String, dynamic>> operation() async => _map(await _http.request(Endpoints.dashboardOperation));
}
