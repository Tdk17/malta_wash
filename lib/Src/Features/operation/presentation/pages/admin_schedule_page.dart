import 'package:flutter/material.dart';
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
  List<Map<String, dynamic>> _items = const [];
  bool _loading = true;
  String? _error;
  DateTime _selectedDay = DateTime.now();
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
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _repository.list(Endpoints.appointments);
      if (mounted) setState(() => _items = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancel(Map<String, dynamic> item) async {
    final id = _id(item);
    if (id.isEmpty) return _message('Agendamento sem identificador técnico para cancelamento.');
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Cancelar agendamento?'),
      content: const Text('O horário será liberado e o agendamento ficará como cancelado.'),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Voltar')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Cancelar agendamento'))],
    ));
    if (ok != true) return;
    try {
      await _repository.create(Endpoints.appointmentCancel(id), const {'reason': 'Cancelado pela empresa'});
      await _load();
      _message('Agendamento cancelado.');
    } catch (e) { _message(e.toString()); }
  }

  Future<void> _reschedule(Map<String, dynamic> item) async {
    final id = _id(item);
    if (id.isEmpty) return _message('Agendamento sem identificador técnico para reagendamento.');
    final date = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)), initialDate: _date(item) ?? DateTime.now());
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date(item) ?? DateTime.now()));
    if (time == null) return;
    final startAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    try {
      await _repository.create(Endpoints.appointmentReschedule(id), {'startAt': startAt.toIso8601String()});
      await _load();
      _message('Agendamento reagendado.');
    } catch (e) { _message(e.toString()); }
  }

  Future<void> _blockDay() async {
    final reason = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: Text('Bloquear ${_dateLabel(_selectedDay)}?'),
      content: TextField(controller: reason, maxLines: 3, decoration: const InputDecoration(labelText: 'Motivo', hintText: 'Ex.: manutenção, feriado, evento interno')),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Voltar')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Bloquear dia'))],
    ));
    if (ok != true) { reason.dispose(); return; }
    final start = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final end = start.add(const Duration(days: 1));
    try {
      await _repository.create(Endpoints.blocks, {'startAt': start.toIso8601String(), 'endAt': end.toIso8601String(), 'reason': reason.text.trim(), 'allDay': true, 'active': true});
      _message('Agenda bloqueada para ${_dateLabel(_selectedDay)}.');
    } catch (e) { _message(e.toString()); }
    reason.dispose();
  }

  void _message(String text) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text))); }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFFFF7ED)])),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _header(filtered.length),
              const SizedBox(height: 18),
              if (widget.calendarMode) _calendarToolbar() else _filters(),
              const SizedBox(height: 18),
              Expanded(child: _body(filtered)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _header(int count) => Container(
    width: double.infinity, padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF111827)]), borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x220F172A), blurRadius: 26, offset: Offset(0, 12))]),
    child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6A00), Color(0xFFFF8A34)]), borderRadius: BorderRadius.circular(15)), child: Icon(widget.calendarMode ? Icons.calendar_month_rounded : Icons.event_available_rounded, color: Colors.white)),
      const SizedBox(width: 15),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.calendarMode ? 'Agenda' : 'Agendamentos', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(widget.calendarMode ? 'Escolha o dia, visualize horários e bloqueie datas quando necessário.' : 'Pesquise, reagende e cancele sem expor dados técnicos.', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13))])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white.withOpacity(.07), borderRadius: BorderRadius.circular(12)), child: Text('$count agendamentos', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 12))),
      const SizedBox(width: 8), IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: Colors.white)),
    ]),
  );

  Widget _calendarToolbar() => Column(children: [
    Row(children: [Expanded(child: _dayStrip()), const SizedBox(width: 14), FilledButton.icon(onPressed: _blockDay, icon: const Icon(Icons.block_rounded), label: const Text('Bloquear dia'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF111827), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16)))]),
    const SizedBox(height: 12),
    Align(alignment: Alignment.centerLeft, child: Text('Agenda de ${_dateLabel(_selectedDay)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)))),
  ]);

  Widget _filters() => Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
    SizedBox(width: 340, child: TextField(controller: _search, decoration: InputDecoration(hintText: 'Buscar cliente, veículo ou placa...', prefixIcon: const Icon(Icons.search_rounded), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)))),
    for (final status in const ['Todos', 'Agendado', 'Em atendimento', 'Pronto', 'Finalizado', 'Cancelado', 'No-show']) ChoiceChip(label: Text(status), selected: _status == status, onSelected: (_) => setState(() => _status = status), selectedColor: const Color(0xFFFF6A00), labelStyle: TextStyle(color: _status == status ? Colors.white : const Color(0xFF475569), fontWeight: FontWeight.w700), side: BorderSide.none, backgroundColor: Colors.white),
  ]);

  Widget _dayStrip() {
    final start = DateTime.now().subtract(const Duration(days: 2));
    return SizedBox(height: 86, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: 12, separatorBuilder: (_, __) => const SizedBox(width: 9), itemBuilder: (_, i) {
      final day = DateTime(start.year, start.month, start.day + i); final selected = _sameDay(day, _selectedDay);
      return InkWell(onTap: () => setState(() => _selectedDay = day), borderRadius: BorderRadius.circular(18), child: AnimatedContainer(duration: const Duration(milliseconds: 160), width: 76, padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(gradient: selected ? const LinearGradient(colors: [Color(0xFFFF6A00), Color(0xFFFF8A34)]) : null, color: selected ? null : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: selected ? const Color(0xFFFFA362) : const Color(0xFFE2E8F0))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_weekday(day), style: TextStyle(color: selected ? Colors.white70 : const Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text('${day.day}', style: TextStyle(color: selected ? Colors.white : const Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.w900))])));
    }));
  }

  Widget _body(List<Map<String, dynamic>> items) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _empty(Icons.cloud_off_rounded, 'Não foi possível carregar', _error!);
    if (items.isEmpty) return _empty(Icons.event_available_rounded, 'Nenhum agendamento aqui', widget.calendarMode ? 'Este dia está livre.' : 'Nenhum resultado encontrado para os filtros atuais.');
    return ListView.separated(itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, i) => _appointmentCard(items[i]));
  }

  Widget _appointmentCard(Map<String, dynamic> item) {
    final customer = _first(item, ['customerName', 'clientName', 'name'], nested: ['customer', 'name']);
    final vehicle = _first(item, ['vehicleName', 'model'], nested: ['vehicle', 'name']);
    final plate = _first(item, ['plate', 'licensePlate'], nested: ['vehicle', 'plate']);
    final service = _first(item, ['serviceName'], nested: ['service', 'name']);
    final status = _pick(item, ['status', 'state', 'appointmentStatus']);
    return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))), child: Row(children: [
      Container(width: 54, height: 54, decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.local_car_wash_rounded, color: Color(0xFFFF8A34))), const SizedBox(width: 15),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(customer, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text([vehicle, plate].where((e) => e != '—').join(' • '), style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)), if (service != '—') Text(service, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12))])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(_when(item), style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 7), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFF6A00).withOpacity(.10), borderRadius: BorderRadius.circular(999)), child: Text(status, style: const TextStyle(color: Color(0xFFC45200), fontWeight: FontWeight.w800, fontSize: 11)))]),
      const SizedBox(width: 10), PopupMenuButton<String>(tooltip: 'Ações', onSelected: (value) { if (value == 'reschedule') _reschedule(item); if (value == 'cancel') _cancel(item); }, itemBuilder: (_) => const [PopupMenuItem(value: 'reschedule', child: ListTile(leading: Icon(Icons.edit_calendar_rounded), title: Text('Reagendar'), contentPadding: EdgeInsets.zero)), PopupMenuItem(value: 'cancel', child: ListTile(leading: Icon(Icons.cancel_outlined, color: Color(0xFFB91C1C)), title: Text('Cancelar'), contentPadding: EdgeInsets.zero))]),
    ]));
  }

  Widget _empty(IconData icon, String title, String text) => Center(child: Container(constraints: const BoxConstraints(maxWidth: 500), padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 42, color: const Color(0xFFFF6A00)), const SizedBox(height: 12), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 7), Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B)))])));

  List<Map<String, dynamic>> _filtered() {
    final q = _search.text.trim().toLowerCase();
    return _items.where((item) {
      if (widget.calendarMode) { final date = _date(item); if (date != null && !_sameDay(date, _selectedDay)) return false; }
      final status = _pick(item, ['status', 'state', 'appointmentStatus']);
      if (!widget.calendarMode && _status != 'Todos' && status.toLowerCase() != _status.toLowerCase()) return false;
      if (q.isEmpty) return true;
      return [_pick(item, ['customerName', 'clientName', 'name']), _first(item, const [], nested: ['customer', 'name']), _pick(item, ['vehicleName', 'model']), _pick(item, ['plate', 'licensePlate'])].join(' ').toLowerCase().contains(q);
    }).toList();
  }

  String _id(Map<String, dynamic> item) => _pick(item, ['id', 'objectId', '_id'], fallback: '');
  DateTime? _date(Map<String, dynamic> item) { for (final key in const ['scheduledAt','date','startAt','appointmentAt','startsAt']) { final v=item[key]; if(v is String){final d=DateTime.tryParse(v); if(d!=null)return d.toLocal();}} return null; }
  bool _sameDay(DateTime a, DateTime b) => a.year==b.year && a.month==b.month && a.day==b.day;
  String _weekday(DateTime d) => const ['SEG','TER','QUA','QUI','SEX','SÁB','DOM'][d.weekday-1];
  String _dateLabel(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
  String _when(Map<String,dynamic> item) { final d=_date(item); return d==null?'Horário —':'${_dateLabel(d)} • ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}'; }
  String _pick(Map<String,dynamic> item,List<String> keys,{String fallback='—'}) { for(final k in keys){final v=item[k]; if(v!=null && v is! Map && v.toString().trim().isNotEmpty)return v.toString();} return fallback; }
  String _first(Map<String,dynamic> item,List<String> keys,{List<String>? nested}) { final direct=_pick(item,keys,fallback:''); if(direct.isNotEmpty)return direct; dynamic v=item; if(nested!=null){for(final p in nested){if(v is Map){v=v[p];}else{return '—';}} if(v!=null&&v.toString().trim().isNotEmpty)return v.toString();} return '—'; }
}
