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

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFFFF7ED)]),
      ),
      child: CustomPaint(
        painter: _GridPainter(),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1320),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Hero(
                  title: widget.calendarMode ? 'Agenda' : 'Agendamentos',
                  subtitle: widget.calendarMode
                      ? 'Visualize o dia, horários e veículos programados sem poluição visual.'
                      : 'Busque, filtre e acompanhe cada agendamento em uma única tela.',
                  count: filtered.length,
                  onRefresh: _load,
                ),
                const SizedBox(height: 18),
                if (widget.calendarMode) _dayStrip() else _filters(),
                const SizedBox(height: 18),
                Expanded(child: _body(filtered)),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(List<Map<String, dynamic>> items) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _Message(icon: Icons.cloud_off_rounded, title: 'Não foi possível carregar os agendamentos', text: _error!, action: _load);
    if (items.isEmpty) return _Message(icon: Icons.event_available_rounded, title: 'Nenhum agendamento aqui', text: widget.calendarMode ? 'Quando houver horários para este dia, eles aparecerão nesta agenda.' : 'Novos agendamentos aparecerão aqui automaticamente.', action: _load);
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _AppointmentCard(item: items[i]),
    );
  }

  Widget _filters() {
    return Wrap(
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
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ),
        for (final status in const ['Todos', 'Agendado', 'Em atendimento', 'Pronto', 'Finalizado', 'Cancelado', 'No-show'])
          ChoiceChip(
            label: Text(status),
            selected: _status == status,
            onSelected: (_) => setState(() => _status = status),
            selectedColor: const Color(0xFFFF6A00),
            labelStyle: TextStyle(color: _status == status ? Colors.white : const Color(0xFF475569), fontWeight: FontWeight.w700),
            side: BorderSide.none,
            backgroundColor: Colors.white,
          ),
      ],
    );
  }

  Widget _dayStrip() {
    final start = DateTime.now().subtract(const Duration(days: 2));
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 9,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (_, i) {
          final day = DateTime(start.year, start.month, start.day + i);
          final selected = _sameDay(day, _selectedDay);
          return InkWell(
            onTap: () => setState(() => _selectedDay = day),
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 76,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: selected ? const LinearGradient(colors: [Color(0xFFFF6A00), Color(0xFFFF8A34)]) : null,
                color: selected ? null : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: selected ? const Color(0xFFFFA362) : const Color(0xFFE2E8F0)),
                boxShadow: selected ? const [BoxShadow(color: Color(0x33FF6A00), blurRadius: 18, offset: Offset(0, 8))] : null,
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(_weekday(day), style: TextStyle(color: selected ? Colors.white70 : const Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text('${day.day}', style: TextStyle(color: selected ? Colors.white : const Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.w900)),
              ]),
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _filtered() {
    final q = _search.text.trim().toLowerCase();
    return _items.where((item) {
      if (widget.calendarMode) {
        final date = _date(item);
        if (date != null && !_sameDay(date, _selectedDay)) return false;
      }
      final status = _pick(item, ['status', 'state', 'appointmentStatus']);
      if (_status != 'Todos' && status.toLowerCase() != _status.toLowerCase()) return false;
      if (q.isEmpty) return true;
      final haystack = [
        _pick(item, ['customerName', 'clientName', 'name']),
        _nested(item, ['customer', 'name']),
        _pick(item, ['vehicleName', 'vehicle', 'model']),
        _pick(item, ['plate', 'licensePlate']),
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  DateTime? _date(Map<String, dynamic> item) {
    for (final key in const ['scheduledAt', 'date', 'startAt', 'appointmentAt', 'startsAt']) {
      final value = item[key];
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed.toLocal();
      }
    }
    return null;
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  String _weekday(DateTime d) => const ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'][d.weekday - 1];
  String _pick(Map<String, dynamic> item, List<String> keys) { for (final k in keys) { final v = item[k]; if (v != null && v.toString().trim().isNotEmpty) return v.toString(); } return '—'; }
  String _nested(Map<String, dynamic> item, List<String> path) { dynamic v = item; for (final p in path) { if (v is Map) v = v[p]; else return ''; } return v?.toString() ?? ''; }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final customer = _first(['customerName', 'clientName', 'name'], nested: ['customer', 'name']);
    final vehicle = _first(['vehicleName', 'model'], nested: ['vehicle', 'name']);
    final plate = _first(['plate', 'licensePlate'], nested: ['vehicle', 'plate']);
    final service = _first(['serviceName', 'service'], nested: ['service', 'name']);
    final status = _first(['status', 'state', 'appointmentStatus']);
    final when = _when();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.94), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.local_car_wash_rounded, color: Color(0xFFFF8A34))),
        const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(customer, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 5),
          Text([vehicle, plate].where((e) => e != '—').join(' • '), style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          if (service != '—') Padding(padding: const EdgeInsets.only(top: 4), child: Text(service, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12))),
        ])),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(when, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFF6A00).withOpacity(.10), borderRadius: BorderRadius.circular(999)), child: Text(status, style: const TextStyle(color: Color(0xFFC45200), fontWeight: FontWeight.w800, fontSize: 11))),
        ]),
      ]),
    );
  }

  String _first(List<String> keys, {List<String>? nested}) { for (final k in keys) { final v = item[k]; if (v != null && v.toString().trim().isNotEmpty && v is! Map) return v.toString(); } if (nested != null) { dynamic v = item; for (final p in nested) { if (v is Map) v = v[p]; else return '—'; } if (v != null && v.toString().trim().isNotEmpty) return v.toString(); } return '—'; }
  String _when() { for (final k in const ['scheduledAt', 'date', 'startAt', 'appointmentAt', 'startsAt']) { final v = item[k]; if (v is String) { final d = DateTime.tryParse(v)?.toLocal(); if (d != null) return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')} • ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}'; } } return 'Horário —'; }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.title, required this.subtitle, required this.count, required this.onRefresh});
  final String title; final String subtitle; final int count; final VoidCallback onRefresh;
  @override Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF111827)]), borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x240F172A), blurRadius: 26, offset: Offset(0, 12))]),
    child: Row(children: [Container(width: 48,height:48,decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFFFF6A00),Color(0xFFFF8A34)]),borderRadius:BorderRadius.circular(15)),child:const Icon(Icons.calendar_month_rounded,color:Colors.white)),const SizedBox(width:15),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(color:Colors.white,fontSize:24,fontWeight:FontWeight.w900)),const SizedBox(height:4),Text(subtitle,style:const TextStyle(color:Color(0xFF94A3B8),fontSize:13))])),Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),decoration:BoxDecoration(color:Colors.white.withOpacity(.07),borderRadius:BorderRadius.circular(12)),child:Text('$count registros',style:const TextStyle(color:Colors.white70,fontWeight:FontWeight.w700,fontSize:12))),const SizedBox(width:8),IconButton(onPressed:onRefresh,icon:const Icon(Icons.refresh_rounded,color:Colors.white))]),
  );
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, required this.text, required this.action}); final IconData icon; final String title; final String text; final VoidCallback action;
  @override Widget build(BuildContext context) => Center(child:Container(constraints:const BoxConstraints(maxWidth:520),padding:const EdgeInsets.all(28),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(24),border:Border.all(color:const Color(0xFFE2E8F0))),child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(icon,size:40,color:const Color(0xFFFF6A00)),const SizedBox(height:12),Text(title,textAlign:TextAlign.center,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(height:7),Text(text,textAlign:TextAlign.center,style:const TextStyle(color:Color(0xFF64748B))),const SizedBox(height:16),OutlinedButton.icon(onPressed:action,icon:const Icon(Icons.refresh),label:const Text('Atualizar'))])));
}

class _GridPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) { final p=Paint()..color=const Color(0xFF64748B).withOpacity(.05)..strokeWidth=.6; const gap=34.0; for(double x=0;x<size.width;x+=gap) canvas.drawLine(Offset(x,0),Offset(x,size.height),p); for(double y=0;y<size.height;y+=gap) canvas.drawLine(Offset(0,y),Offset(size.width,y),p); }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}
