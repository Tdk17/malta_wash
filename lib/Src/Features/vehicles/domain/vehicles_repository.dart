import 'package:malta_wash/Src/Features/vehicles/domain/vehicle.dart';

abstract interface class VehiclesRepository {
  Future<List<Vehicle>> list();
  Future<Vehicle> create(Map<String, dynamic> payload);
  Future<Vehicle> update(String id, Map<String, dynamic> payload);
  Future<void> delete(String id);
}
