abstract interface class BookingRepository {
  Future<List<Map<String, dynamic>>> locations();
  Future<Map<String, dynamic>> settings();
  Future<List<Map<String, dynamic>>> services();
  Future<List<Map<String, dynamic>>> addons();
  Future<List<Map<String, dynamic>>> appointments({
    String? locationId,
    required String date,
  });
  Future<List<Map<String, dynamic>>> availability({
    String? locationId,
    required String serviceId,
    required String vehicleId,
    required String date,
  });
  Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> payload);
}
