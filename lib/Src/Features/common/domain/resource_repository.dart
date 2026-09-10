abstract interface class ResourceRepository {
  Future<List<Map<String, dynamic>>> list(String endpoint, {Map<String, dynamic>? query});
  Future<Map<String, dynamic>> get(String endpoint);
  Future<Map<String, dynamic>> create(String endpoint, Map<String, dynamic> payload);
  Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> payload);
  Future<void> delete(String endpoint);
}
