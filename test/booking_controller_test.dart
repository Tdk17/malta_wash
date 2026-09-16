import 'package:flutter_test/flutter_test.dart';
import 'package:malta_wash/Src/Features/booking/domain/booking_repository.dart';
import 'package:malta_wash/Src/Features/booking/presentation/controllers/booking_controller.dart';

class BookingApi implements BookingRepository {
  List<Map<String, dynamic>> available = [];
  Object? failure;
  Map<String, dynamic>? submitted;
  Map<String, dynamic>? availabilityQuery;
  @override
  Future<List<Map<String, dynamic>>> services() async => [{'id': 'wash', 'active': true}];
  @override
  Future<Map<String, dynamic>> settings() async => {'defaultLocationId': 'shop'};
  @override
  Future<List<Map<String, dynamic>>> locations() async => [{'id': 'shop'}];
  @override
  Future<List<Map<String, dynamic>>> addons() async => [];
  @override
  Future<List<Map<String, dynamic>>> appointments({String? locationId, required String date}) async => [];
  @override
  Future<List<Map<String, dynamic>>> availability({String? locationId, required String serviceId, required String date}) async {
    availabilityQuery = {'locationId': locationId, 'serviceId': serviceId, 'date': date};
    if (failure != null) throw failure!;
    return available;
  }
  @override
  Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> payload) async {
    submitted = payload;
    return {'id': 'appointment', 'status': 'CONFIRMED'};
  }
}

void main() {
  test('new customer can select and book without a vehicle dependency', () async {
    final api = BookingApi()..available = [{'startAt': '2030-01-07T12:00:00Z', 'available': true}];
    final controller = BookingController(api);
    await controller.bootstrap();
    expect(controller.serviceId.value, 'wash');
    controller.date.value = DateTime(2030, 1, 7);
    await controller.loadSlots();
    expect(api.availabilityQuery, {'locationId': 'shop', 'serviceId': 'wash', 'date': '2030-01-07'});
    controller.startAt.value = controller.slots.value.single['startAt'] as String;
    expect((await controller.confirm())?['status'], 'CONFIRMED');
    expect(api.submitted, {'locationId': 'shop', 'serviceId': 'wash', 'startAt': '2030-01-07T12:00:00Z'});
  });
  test('server closed or full day never generates fallback slots', () async {
    final api = BookingApi();
    final controller = BookingController(api);
    await controller.bootstrap();
    controller.date.value = DateTime(2030, 1, 7);
    await controller.loadSlots();
    expect(controller.slots.value, isEmpty);
    expect(controller.errorMessage.value, contains('Não há horários'));
  });
  test('API failures clear stale selection and do not invent availability', () async {
    final api = BookingApi()..failure = StateError('Falha na API');
    final controller = BookingController(api);
    await controller.bootstrap();
    controller.date.value = DateTime(2030, 1, 7);
    controller.startAt.value = '2030-01-07T12:00:00Z';
    await controller.loadSlots();
    expect(controller.slots.value, isEmpty);
    expect(controller.startAt.value, isNull);
    expect(controller.errorMessage.value, contains('Falha na API'));
  });
  test('confirmation still requires service and time', () async {
    final api = BookingApi();
    final controller = BookingController(api);
    expect(await controller.confirm(), isNull);
    expect(api.submitted, isNull);
  });
}
