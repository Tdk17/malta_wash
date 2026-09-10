import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';
import 'package:malta_wash/Src/Features/common/presentation/controllers/resource_list_controller.dart';
import 'package:malta_wash/Src/Shared/widgets/async_state_view.dart';
import 'package:signals/signals_flutter.dart';

class OperationBoardPage extends StatefulWidget {
  const OperationBoardPage({super.key});

  @override
  State<OperationBoardPage> createState() => _OperationBoardPageState();
}

class _OperationBoardPageState extends State<OperationBoardPage> {
  late final ResourceRepository repository = sl<ResourceRepository>();
  late final controller = ResourceListController(repository, Endpoints.appointments)..load();
  String? updatingId;

  static const statuses = ['CONFIRMED', 'CHECKED_IN', 'IN_PROGRESS', 'READY', 'COMPLETED'];
  static const labels = {
    'CONFIRMED': 'Agendados',
    'CHECKED_IN': 'Chegaram',
    'IN_PROGRESS': 'Lavando',
    'READY': 'Prontos',
    'COMPLETED': 'Finalizados',
  };

  static const icons = {
    'CONFIRMED': Icons.event_available_rounded,
    'CHECKED_IN': Icons.login_rounded,
    'IN_PROGRESS': Icons.local_car_wash_rounded,
    'READY': Icons.notifications_active_rounded,
    'COMPLETED': Icons.check_circle_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Atendimentos', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1)),
                SizedBox(height: 5),
                Text('Do agendamento até o carro pronto, sem ordem de serviço separada.', style: TextStyle(color: Color(0xFF667085), fontSize: 14.5)),
              ]),
            ),
            IconButton.filledTonal(onPressed: controller.load, icon: const Icon(Icons.refresh_rounded)),
          ]),
          const SizedBox(height: 22),
          Expanded(
            child: Watch((_) => AsyncStateView(
                  isLoading: controller.isLoading.value,
                  errorMessage: controller.errorMessage.value,
                  isEmpty: controller.items.value.isEmpty,
                  onRetry: controller.load,
                  emptyTitle: 'Nenhum atendimento por enquanto',
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: statuses.map((status) => _column(status)).toList(),
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _column(String status) {
    final items = controller.items.value.where((item) => _status(item) == status).toList();
    return Container(
      width: 292,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
            child: Icon(icons[status], size: 19, color: const Color(0xFFFF6A00)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(labels[status]!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
            child: Text('${items.length}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 12),
        ...items.map((item) => _appointmentCard(item, status)),
      ]),
    );
  }

  Widget _appointmentCard(Map<String, dynamic> item, String status) {
    final id = (item['id'] ?? item['objectId'] ?? '').toString();
    final vehicleMap = item['vehicle'] is Map ? Map<String, dynamic>.from(item['vehicle'] as Map) : const <String, dynamic>{};
    final customerMap = item['customer'] is Map ? Map<String, dynamic>.from(item['customer'] as Map) : const <String, dynamic>{};
    final serviceMap = item['service'] is Map ? Map<String, dynamic>.from(item['service'] as Map) : const <String, dynamic>{};
    final plate = (item['vehiclePlate'] ?? item['plate'] ?? vehicleMap['plate'] ?? 'Veículo').toString();
    final vehicle = (item['vehicleName'] ?? item['model'] ?? vehicleMap['model'] ?? '').toString();
    final customer = (item['customerName'] ?? customerMap['name'] ?? '').toString();
    final service = (item['serviceName'] ?? serviceMap['name'] ?? (item['service'] is String ? item['service'] : '')).toString();
    final time = (item['startTime'] ?? item['start'] ?? item['startAt'] ?? '').toString();
    final next = _nextStatus(status);
    final busy = updatingId == id;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A101828), blurRadius: 16, offset: Offset(0, 7))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(plate, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17))),
          if (time.isNotEmpty) Text(_shortTime(time), style: const TextStyle(color: Color(0xFF667085), fontSize: 12)),
        ]),
        if (vehicle.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(vehicle, style: const TextStyle(color: Color(0xFF475467), fontWeight: FontWeight.w600)),
        ],
        if (customer.isNotEmpty) ...[
          const SizedBox(height: 9),
          Row(children: [const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF98A2B3)), const SizedBox(width: 6), Expanded(child: Text(customer, style: const TextStyle(fontSize: 12.5, color: Color(0xFF667085))))]),
        ],
        if (service.isNotEmpty) ...[
          const SizedBox(height: 5),
          Row(children: [const Icon(Icons.water_drop_outlined, size: 16, color: Color(0xFFFF6A00)), const SizedBox(width: 6), Expanded(child: Text(service, style: const TextStyle(fontSize: 12.5, color: Color(0xFF667085))))]),
        ],
        if (next != null) ...[
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: busy || id.isEmpty ? null : () => _advance(id, next),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6A00),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_nextLabel(next), style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ]),
    );
  }

  Future<void> _advance(String id, String status) async {
    setState(() => updatingId = id);
    try {
      await repository.patch(Endpoints.appointment(id), {'status': status});
      await controller.load();
      if (mounted && status == 'READY') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veículo marcado como pronto.')));
      }
      if (mounted && status == 'COMPLETED') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Atendimento finalizado.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => updatingId = null);
    }
  }

  String _status(Map<String, dynamic> item) {
    final raw = (item['status'] ?? 'CONFIRMED').toString().toUpperCase();
    if (raw == 'PENDING_PAYMENT') return 'CONFIRMED';
    return statuses.contains(raw) ? raw : 'CONFIRMED';
  }

  String? _nextStatus(String current) => switch (current) {
        'CONFIRMED' => 'CHECKED_IN',
        'CHECKED_IN' => 'IN_PROGRESS',
        'IN_PROGRESS' => 'READY',
        'READY' => 'COMPLETED',
        _ => null,
      };

  String _nextLabel(String status) => switch (status) {
        'CHECKED_IN' => 'Cliente chegou',
        'IN_PROGRESS' => 'Iniciar lavagem',
        'READY' => 'Marcar como pronto',
        'COMPLETED' => 'Finalizar atendimento',
        _ => 'Avançar',
      };

  String _shortTime(String raw) {
    if (RegExp(r'^\d{2}:\d{2}').hasMatch(raw)) return raw.substring(0, 5);
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
