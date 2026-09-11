import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';

class ClientAppointmentsPage extends StatefulWidget {
  const ClientAppointmentsPage({super.key});

  @override
  State<ClientAppointmentsPage> createState() => _ClientAppointmentsPageState();
}

class _ClientAppointmentsPageState extends State<ClientAppointmentsPage> {
  final _repository = sl<ResourceRepository>();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items = await _repository.list(Endpoints.appointments);
      items.sort((a, b) {
        final aDate = _dateTime(a) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = _dateTime(b) ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      _items = items;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(mobile ? 16 : 28, 24, mobile ? 16 : 28, 44),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _hero(),
              const SizedBox(height: 20),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _stateCard(
                  icon: Icons.error_outline_rounded,
                  title: 'Não foi possível carregar seus agendamentos',
                  text: _error!,
                  action: TextButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Tentar novamente'),
                  ),
                )
              else if (_items.isEmpty)
                _stateCard(
                  icon: Icons.event_available_rounded,
                  title: 'Nenhum agendamento ainda',
                  text: 'Quando você agendar uma lavagem, ela aparecerá aqui.',
                )
              else
                ..._items.map(_appointmentCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B0F14), Color(0xFF151B24), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(color: Color(0x220F172A), blurRadius: 30, offset: Offset(0, 14)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'MALTA WASH',
                  style: TextStyle(
                    color: Color(0xFFFF9B54),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Meus agendamentos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.8,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Veja somente a data, o horário e o status do seu atendimento.',
                  style: TextStyle(color: Color(0xFF94A3B8), height: 1.4),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _load,
            tooltip: 'Atualizar',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(.08),
              foregroundColor: Colors.white,
              minimumSize: const Size(48, 48),
            ),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }

  Widget _appointmentCard(Map<String, dynamic> item) {
    final start = _dateTime(item);
    final status = _status(item);
    final statusStyle = _statusStyle(status);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x0D0F172A), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final dateText = start == null ? '—' : DateFormat('dd/MM/yyyy').format(start.toLocal());
          final timeText = start == null ? '—' : DateFormat('HH:mm').format(start.toLocal());

          final data = [
            _InfoCell(
              icon: Icons.calendar_today_rounded,
              label: 'Data',
              value: dateText,
            ),
            _InfoCell(
              icon: Icons.schedule_rounded,
              label: 'Horário',
              value: timeText,
            ),
          ];

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: data[0]),
                    const SizedBox(width: 12),
                    Expanded(child: data[1]),
                  ],
                ),
                const SizedBox(height: 14),
                _StatusPill(label: statusStyle.label, color: statusStyle.color),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: data[0]),
              const SizedBox(width: 12),
              Expanded(child: data[1]),
              const Spacer(),
              _StatusPill(label: statusStyle.label, color: statusStyle.color),
            ],
          );
        },
      ),
    );
  }

  Widget _stateCard({
    required IconData icon,
    required String title,
    required String text,
    Widget? action,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFF6A00), size: 34),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF667085), height: 1.4)),
          if (action != null) ...[
            const SizedBox(height: 10),
            action,
          ],
        ],
      ),
    );
  }

  DateTime? _dateTime(Map<String, dynamic> item) {
    for (final key in const [
      'startAt',
      'startsAt',
      'scheduledAt',
      'dateTime',
      'datetime',
      'start',
    ]) {
      final value = item[key];
      if (value == null) continue;
      final parsed = DateTime.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  String _status(Map<String, dynamic> item) {
    for (final key in const ['status', 'state', 'appointmentStatus']) {
      final value = item[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return 'Agendado';
  }

  _StatusStyle _statusStyle(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('cancel')) {
      return const _StatusStyle('Cancelado', Color(0xFFD92D20));
    }
    if (value.contains('final') || value.contains('complete')) {
      return const _StatusStyle('Finalizado', Color(0xFF475467));
    }
    if (value.contains('pronto') || value.contains('ready')) {
      return const _StatusStyle('Pronto', Color(0xFF12B76A));
    }
    if (value.contains('atendimento') || value.contains('progress')) {
      return const _StatusStyle('Em atendimento', Color(0xFF2563EB));
    }
    if (value.contains('no-show') || value.contains('noshow')) {
      return const _StatusStyle('Não compareceu', Color(0xFFB54708));
    }
    return const _StatusStyle('Agendado', Color(0xFFFF6A00));
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3EA),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: const Color(0xFFFF6A00), size: 20),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 11.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.22)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle(this.label, this.color);
  final String label;
  final Color color;
}
