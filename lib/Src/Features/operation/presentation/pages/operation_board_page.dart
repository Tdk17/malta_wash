import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';

class OperationBoardPage extends StatefulWidget {
  const OperationBoardPage({super.key});

  @override
  State<OperationBoardPage> createState() => _OperationBoardPageState();
}

class _OperationBoardPageState extends State<OperationBoardPage> {
  final ResourceRepository repository = sl<ResourceRepository>();
  List<Map<String, dynamic>> appointments = const [];
  List<Map<String, dynamic>> customers = const [];
  List<Map<String, dynamic>> services = const [];
  bool loading = true;
  String? error;
  String? updatingId;

  static const statuses = ['CONFIRMED', 'CHECKED_IN', 'IN_PROGRESS', 'READY', 'COMPLETED'];
  static const labels = {
    'CONFIRMED': 'Agendados', 'CHECKED_IN': 'Chegaram', 'IN_PROGRESS': 'Lavando',
    'READY': 'Prontos', 'COMPLETED': 'Finalizados',
  };
  static const icons = {
    'CONFIRMED': Icons.event_available_rounded, 'CHECKED_IN': Icons.login_rounded,
    'IN_PROGRESS': Icons.local_car_wash_rounded, 'READY': Icons.notifications_active_rounded,
    'COMPLETED': Icons.check_circle_rounded,
  };

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final result = await Future.wait([
        repository.list(Endpoints.appointments), repository.list(Endpoints.customers),
        repository.list(Endpoints.services),
      ]);
      if (!mounted) return;
      setState(() { appointments = result[0]; customers = result[1]; services = result[2]; });
    } catch (e) { if (mounted) setState(() => error = e.toString()); }
    finally { if (mounted) setState(() => loading = false); }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Atendimentos', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1)),
          SizedBox(height: 5), Text('Acompanhe cada atendimento da chegada até a conclusão.', style: TextStyle(color: Color(0xFF667085), fontSize: 14.5)),
        ])),
        IconButton.filledTonal(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
      ]),
      const SizedBox(height: 22), Expanded(child: _body()),
    ]),
  );

  Widget _body() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!, style: const TextStyle(color: Color(0xFFB91C1C))));
    if (appointments.isEmpty) return const Center(child: Text('Nenhum atendimento por enquanto.', style: TextStyle(fontWeight: FontWeight.w800)));
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: statuses.map(_column).toList()));
  }

  Widget _column(String status) {
    final items = appointments.where((item) => _status(item) == status).toList();
    return Container(width: 310, margin: const EdgeInsets.only(right: 14), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE4E7EC))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)), child: Icon(icons[status], size: 19, color: const Color(0xFFFF6A00))), const SizedBox(width: 10), Expanded(child: Text(labels[status]!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5))), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)), child: Text('${items.length}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)))]),
        const SizedBox(height: 12),
        if (items.isEmpty) Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12), decoration: BoxDecoration(color: Colors.white.withOpacity(.65), borderRadius: BorderRadius.circular(14)), child: Text('Nenhum atendimento em ${labels[status]!.toLowerCase()}.', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 12.5)))
        else ...items.map((item) => _appointmentCard(item, status)),
      ]));
  }

  Widget _appointmentCard(Map<String, dynamic> item, String status) {
    final id = _id(item); final customer = _resolveCustomer(item); final service = _resolveService(item);
    final customerName = _pick(customer ?? item, ['name', 'customerName', 'clientName'], fallback: 'Cliente não identificado');
    final phone = _pick(customer ?? item, ['phone', 'customerPhone', 'mobile', 'whatsapp'], fallback: 'Telefone não informado');
    final createdAt = DateTime.tryParse((item['createdAt'] ?? '').toString())?.toLocal();
    final serviceName = _pick(service ?? item, ['name', 'serviceName', 'title'], fallback: 'Serviço');
    final time = _first(item, ['startAt', 'scheduledAt', 'appointmentAt', 'startsAt', 'start']); final next = _nextStatus(status); final busy = updatingId == id;
    return Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0A101828), blurRadius: 16, offset: Offset(0, 7))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(customerName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))), if (time.isNotEmpty) Text(_shortTime(time), style: const TextStyle(color: Color(0xFF667085), fontSize: 12, fontWeight: FontWeight.w700))]), const SizedBox(height: 9),
      Row(children: [const Icon(Icons.phone_outlined, size: 17, color: Color(0xFF2563EB)), const SizedBox(width: 7), Expanded(child: SelectableText(phone, style: const TextStyle(fontWeight: FontWeight.w700)))]),
      if (createdAt != null) Padding(padding: const EdgeInsets.only(top: 5), child: Text('Agendado em ${DateFormat('dd/MM/yyyy HH:mm').format(createdAt)}', style: const TextStyle(fontSize: 11, color: Color(0xFF667085)))),
      const SizedBox(height: 8),
      Row(children: [const Icon(Icons.water_drop_outlined, size: 16, color: Color(0xFFFF6A00)), const SizedBox(width: 6), Expanded(child: Text(serviceName, style: const TextStyle(fontSize: 12.5, color: Color(0xFF667085))))]),
      if (next != null) ...[const SizedBox(height: 13), SizedBox(width: double.infinity, child: FilledButton(onPressed: busy || id.isEmpty ? null : () => _advance(id, next), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6A00), foregroundColor: Colors.white, minimumSize: const Size(0, 42), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_nextLabel(next), style: const TextStyle(fontWeight: FontWeight.w800))))],
    ]));
  }

  Future<void> _advance(String id, String status) async {
    setState(() => updatingId = id);
    try {
      await repository.patch(Endpoints.appointmentAdvance(id), {'status': status});
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status == 'READY' ? 'Atendimento marcado como pronto.' : status == 'COMPLETED' ? 'Atendimento finalizado.' : 'Atendimento atualizado.')));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
    finally { if (mounted) setState(() => updatingId = null); }
  }

  Map<String, dynamic>? _resolveCustomer(Map<String, dynamic> appointment) {
    final embedded = appointment['customer'];
    if (embedded is Map && embedded['name'] != null) return embedded.map((k, v) => MapEntry(k.toString(), v));
    final customerId = _first(appointment, ['customerId', 'clientId', 'userId', 'ownerId']);
    for (final customer in customers) { if (_id(customer) == customerId) return customer; }
    return null;
  }
  Map<String, dynamic>? _resolveService(Map<String, dynamic> appointment) { final embedded=appointment['service']; if(embedded is Map)return embedded.map((k,v)=>MapEntry(k.toString(),v)); final id=_first(appointment,['serviceId']); for(final s in services){if(_id(s)==id)return s;} return null; }
  String _status(Map<String,dynamic> item){final raw=_first(item,['status','state','appointmentStatus']).toUpperCase(); if(raw=='PENDING_PAYMENT'||raw=='SCHEDULED'||raw=='BOOKED')return 'CONFIRMED'; if(raw=='ARRIVED')return 'CHECKED_IN'; if(raw=='WASHING')return 'IN_PROGRESS'; if(raw=='DONE'||raw=='FINISHED')return 'COMPLETED'; return raw;}
  String? _nextStatus(String current)=>switch(current){'CONFIRMED'=>'CHECKED_IN','CHECKED_IN'=>'IN_PROGRESS','IN_PROGRESS'=>'READY','READY'=>'COMPLETED',_=>null};
  String _nextLabel(String status)=>switch(status){'CHECKED_IN'=>'Cliente chegou','IN_PROGRESS'=>'Iniciar lavagem','READY'=>'Marcar como pronto','COMPLETED'=>'Finalizar atendimento',_=>'Avançar'};
  String _shortTime(String raw) { final date = DateTime.tryParse(raw)?.toLocal(); return date == null ? '' : DateFormat('dd/MM HH:mm').format(date); }
  String _id(Map<String,dynamic> item)=>_first(item,['id','objectId','_id']);
  String _first(Map<String,dynamic> item,List<String> keys){for(final key in keys){final value=item[key];if(value!=null&&value is! Map&&value.toString().trim().isNotEmpty)return value.toString().trim();}return '';}
  String _pick(Map<String,dynamic> item,List<String> keys,{String fallback='—'}){final value=_first(item,keys);return value.isEmpty?fallback:value;}
}
