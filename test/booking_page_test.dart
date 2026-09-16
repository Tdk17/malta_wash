import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Features/booking/presentation/controllers/booking_controller.dart';
import 'package:malta_wash/Src/Features/booking/presentation/pages/booking_page_v2.dart';
import 'booking_controller_test.dart' show BookingApi;

void main() {
  testWidgets('booking starts at service and reviews without a vehicle step', (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await initializeDateFormatting('pt_BR');
    final controller = BookingController(BookingApi());
    sl.registerFactory<BookingController>(() => controller);
    addTearDown(() => sl.reset());
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BookingPageV2())));
    await tester.pumpAndSettle();
    expect(find.text('Escolha o serviço'), findsOneWidget);
    expect(find.text('Qual veículo?'), findsNothing);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Quando você quer vir?'), findsOneWidget);
    controller.date.value = DateTime(2030, 1, 7);
    controller.startAt.value = '2030-01-07T12:00:00Z';
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Confirmar agendamento'), findsOneWidget);
    expect(find.text('Veículo'), findsNothing);
    expect(find.textContaining('pagamento será feito no local'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
