abstract interface class DashboardRepository {
  Future<Map<String, dynamic>> metrics();
  Future<Map<String, dynamic>> operation();
}
