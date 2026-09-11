import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';

class AdminSchedulePage extends StatefulWidget {
  const AdminSchedulePage({super.key, this.calendarMode = false});
  final bool calendarMode;

  @override
  State<AdminSchedulePage> createState() => _AdminSchedulePageState();
}

class _AdminSchedulePageState extends State<AdminSchedulePage> {
  final _repository = sl<ResourceRepository>();
  final _search = TextEditingController();

  List<Map<String, dynamic>> _appointments = const [];
  List<Map<String, dynamic>> _customers = const [];
  List<Map<String, dynamic>> _vehicles = const [];
  List<Map<String, dynamic>> _services = const [];
  bool _loading = true;
  String? _error;
  String _status = 'Todos';

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _repository.list(Endpoints.appointments),
        _repository.list(Endpoints.customers),
        _repository.list(Endpoints.vehicles),
        _repository.list(Endpoints.services),
      ]);
      if (!mounted) return;
      setState(() {
        _appointments = results[0];
        _customers = results[1];
        _vehicles = results[2];
        _services = results[3];
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancel(Map<String, dynamic> item) async {
    final id = _id(item);
    if (id.isEmpty) return _message('Não foi possível identificar este agendamento.');
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Cancelar agendamento?'),
        content: const Text('O horário será liberado para outro cliente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Voltar')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Cancelar')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repository.create(
        Endpoints.appointmentCancel(id),
        const {'reason': 'Cancelado pela empresa'},
      );
      await _load();
      _message('Agendamento cancelado.');
    } catch (e) {
      _message(e.toString());
    }
  }

  Future<void> _reschedule(Map<String, dynamic> item) async {
    final id = _id(item);
    if (id.isEmpty) return _message('Não foi possível identificar este agendamento.');
    final current = _date(item) ?? DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: current.isBefore(DateTime.now()) ? DateTime.now() : current,
    );
    if (selectedDate == null || !mounted) return;
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (selectedTime == null) return;

    final startAt = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    try {
      await _repository.create(
        Endpoints.appointmentReschedule(id),
        {'startAt': startAt.toIso8601String()},
      );
      await _load();
      _message('Agendamento reagendado.');
    } catch (e) {
      _message(e.toString());
    }
  }

  void _message(String text) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered();
    final today = DateTime.now();
    return Padding(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 700 ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(today, items.length),
              const SizedBox(height: 18),
              _filters(),
              const SizedBox(height: 18),
              Expanded(child: _body(items)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(DateTime today, int count) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0B0F14), Color(0xFF172033)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x220F172A), blurRadius: 28, offset: Offset(0, 12))],
        ),
        child: LayoutBuilder(builder: (context, c) {
          final compact = c.maxWidth < 620;
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hoje, ${DateFormat('dd/MM/yyyy').format(today)}',
                style: const TextStyle(color: Color(0xFFFF9A52), fontSize: 11, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text('Agendamentos', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text('Cliente, veículo, placa, serviço, horário e status em uma única tela.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
            ],
          );
          final badge = Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(12)),
              child: Text('$count registros', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 12)),
            ),
            const SizedBox(width: 6),
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: Colors.white)),
          ]);
          if (compact) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [title, const SizedBox(height: 14), badge]);
          return Row(children: [Expanded(child: title), badge]);
        }),
      );

  Widget _filters() => Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 340,
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Buscar cliente, veículo ou placa...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white.withOpacity(.94),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          for (final status in const ['Todos', 'Agendado', 'Em atendimento', 'Pronto', 'Finalizado', 'Cancelado'])
            ChoiceChip(
              label: Text(status),
              selected: _status == status,
              onSelected: (_) => setState(() => _status = status),
              selectedColor: const Color(0xFFFF6A00),
              backgroundColor: Colors.white.withOpacity(.92),
              side: BorderSide.none,
              labelStyle: TextStyle(
                color: _status == status ? Colors.white : const Color(0xFF475569),
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      );

  Widget _body(List<Map<String, dynamic>> items) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _empty(Icons.cloud_off_rounded, 'Não foi possível carregar', _error!);
    if (items.isEmpty) return _empty(Icons.event_available_rounded, 'Nenhum agendamento encontrado', 'Os agendamentos feitos pelos clientes aparecerão aqui.');
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _appointmentCard(items[i]),
      ),
    );
  }

  Widget _appointmentCard(Map<String, dynamic> item) {
    final vehicle = _vehicleFor(item);
    final customer = _customerFor(item, vehicle);
    final service = _serviceFor(item);
    final customerName = _displayName(customer, item);
    final model = _firstNonEmpty([
      _value(vehicle, ['model', 'vehicleModel', 'name']),
      _value(item, ['vehicleName', 'vehicleModel', 'model']),
      _nested(item, 'vehicle', ['model', 'name']),
    ], fallback: 'Veículo não informado');
    final plate = _firstNonEmpty([
      _value(vehicle, ['plate', 'licensePlate']),
      _value(item, ['plate', 'licensePlate']),
      _nested(item, 'vehicle', ['plate', 'licensePlate']),
    ]);
    final serviceName = _firstNonEmpty([
      _value(service, ['name', 'title']),
      _value(item, ['serviceName']),
      _nested(item, 'service', ['name', 'title']),
    ]);
    final status = _statusLabel(_value(item, ['status', 'state', 'appointmentStatus']));
    final when = _date(item);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x0B0F172A), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: LayoutBuilder(builder: (context, c) {
        final compact = c.maxWidth < 650;
        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            const SizedBox(height: 5),
            Text(
              [model, if (plate.isNotEmpty) plate].join(' • '),
              style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w700),
            ),
            if (serviceName.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(serviceName, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5)),
            ],
          ],
        );
        final meta = Row(mainAxisSize: MainAxisSize.min, children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(when == null ? 'Data não informada' : DateFormat('dd/MM/yyyy').format(when), style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(when == null ? '--:--' : DateFormat('HH:mm').format(when), style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800)),
              const SizedBox(height: 7),
              _statusBadge(status),
            ],
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: 'Ações',
            onSelected: (value) {
              if (value == 'reschedule') _reschedule(item);
              if (value == 'cancel') _cancel(item);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'reschedule', child: Text('Reagendar')),
              PopupMenuItem(value: 'cancel', child: Text('Cancelar')),
            ],
          ),
        ]);

        final icon = Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF111827), Color(0xFF1E293B)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.local_car_wash_rounded, color: Color(0xFFFF8A34)),
        );

        if (compact) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [icon, const SizedBox(width: 12), Expanded(child: details)]),
            const SizedBox(height: 14),
            Align(alignment: Alignment.centerRight, child: meta),
          ]);
        }
        return Row(children: [icon, const SizedBox(width: 15), Expanded(child: details), meta]);
      }),
    );
  }

  Widget _statusBadge(String status) {
    final color = switch (status) {
      'Finalizado' => const Color(0xFF067647),
      'Pronto' => const Color(0xFF175CD3),
      'Em atendimento' => const Color(0xFFB54708),
      'Cancelado' => const Color(0xFFB42318),
      _ => const Color(0xFF475467),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(999)),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
    );
  }

  Widget _empty(IconData icon, String title, String text) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.94),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 42, color: const Color(0xFFFF6A00)),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B))),
          ]),
        ),
      );

  List<Map<String, dynamic>> _filtered() {
    final q = _search.text.trim().toLowerCase();
    final items = [..._appointments];
    items.sort((a, b) {
      final da = _date(a);
      final db = _date(b);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });

    return items.where((item) {
      final vehicle = _vehicleFor(item);
      final customer = _customerFor(item, vehicle);
      final status = _statusLabel(_value(item, ['status', 'state', 'appointmentStatus']));
      if (_status != 'Todos' && status != _status) return false;
      if (q.isEmpty) return true;
      final haystack = [
        _displayName(customer, item),
        _value(vehicle, ['model', 'vehicleModel', 'name']),
        _value(vehicle, ['plate', 'licensePlate']),
        _value(item, ['vehicleName', 'vehicleModel', 'plate', 'licensePlate']),
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  Map<String, dynamic> _vehicleFor(Map<String, dynamic> appointment) {
    final nested = appointment['vehicle'];
    if (nested is Map) return nested.map((k, v) => MapEntry(k.toString(), v));
    final id = _firstNonEmpty([
      _value(appointment, ['vehicleId', 'carId', 'vehicleObjectId']),
      _pointerId(appointment['vehicle']),
    ]);
    if (id.isEmpty) return const {};
    return _findById(_vehicles, id);
  }

  Map<String, dynamic> _customerFor(Map<String, dynamic> appointment, Map<String, dynamic> vehicle) {
    final nested = appointment['customer'] ?? appointment['client'];
    if (nested is Map) return nested.map((k, v) => MapEntry(k.toString(), v));
    final id = _firstNonEmpty([
      _value(appointment, ['customerId', 'clientId', 'userId', 'customerObjectId']),
      _pointerId(appointment['customer']),
      _value(vehicle, ['customerId', 'clientId', 'userId', 'ownerId']),
      _pointerId(vehicle['customer']),
    ]);
    if (id.isEmpty) return const {};
    return _findById(_customers, id);
  }

  Map<String, dynamic> _serviceFor(Map<String, dynamic> appointment) {
    final nested = appointment['service'];
    if (nested is Map) return nested.map((k, v) => MapEntry(k.toString(), v));
    final id = _firstNonEmpty([
      _value(appointment, ['serviceId', 'serviceObjectId']),
      _pointerId(appointment['service']),
    ]);
    if (id.isEmpty) return const {};
    return _findById(_services, id);
  }

  Map<String, dynamic> _findById(List<Map<String, dynamic>> list, String id) {
    for (final item in list) {
      if (_id(item) == id) return item;
    }
    return const {};
  }

  String _displayName(Map<String, dynamic> customer, Map<String, dynamic> appointment) => _firstNonEmpty([
        _value(customer, ['name', 'fullName', 'customerName']),
        _value(appointment, ['customerName', 'clientName', 'name']),
        _nested(appointment, 'customer', ['name', 'fullName']),
      ], fallback: 'Cliente não informado');

  DateTime? _date(Map<String, dynamic> item) {
    for (final key in const ['startAt', 'scheduledAt', 'appointmentAt', 'startsAt', 'date']) {
      final raw = item[key];
      if (raw == null) continue;
      final value = raw is Map ? (raw['iso'] ?? raw['date'] ?? raw['value'])?.toString() : raw.toString();
      if (value == null || value.isEmpty) continue;
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed.toLocal();
    }
    return null;
  }

  String _statusLabel(String raw) {
    final value = raw.trim().toUpperCase().replaceAll('-', '_').replaceAll(' ', '_');
    return switch (value) {
      'SCHEDULED' || 'BOOKED' || 'PENDING' || 'CONFIRMED' => 'Agendado',
      'IN_PROGRESS' || 'INPROGRESS' || 'STARTED' => 'Em atendimento',
      'READY' => 'Pronto',
      'FINISHED' || 'COMPLETED' || 'DONE' => 'Finalizado',
      'CANCELLED' || 'CANCELED' => 'Cancelado',
      'NO_SHOW' || 'NOSHOW' => 'No-show',
      _ => raw.trim().isEmpty ? 'Agendado' : raw,
    };
  }

  String _id(Map<String, dynamic> item) => _firstNonEmpty([
        _value(item, ['id', 'objectId', '_id']),
      ]);

  String _pointerId(dynamic value) {
    if (value is Map) {
      return _firstNonEmpty([
        value['objectId']?.toString() ?? '',
        value['id']?.toString() ?? '',
      ]);
    }
    return '';
  }

  String _nested(Map<String, dynamic> item, String key, List<String> keys) {
    final nested = item[key];
    if (nested is! Map) return '';
    for (final k in keys) {
      final value = nested[k]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  String _value(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value is! Map) {
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
    }
    return '';
  }

  String _firstNonEmpty(List<String> values, {String fallback = ''}) {
    for (final value in values) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return fallback;
  }
}
