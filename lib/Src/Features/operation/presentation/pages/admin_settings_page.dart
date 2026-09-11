import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final _repository = sl<ResourceRepository>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _opening = TextEditingController(text: '08:00');
  final _closing = TextEditingController(text: '18:00');
  final _slotMinutes = TextEditingController(text: '30');
  final Set<int> _workingDays = {1, 2, 3, 4, 5, 6};
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String? _defaultLocationId;

  static const _dayLabels = <int, String>{
    1: 'Seg', 2: 'Ter', 3: 'Qua', 4: 'Qui', 5: 'Sex', 6: 'Sáb', 7: 'Dom',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _opening.dispose();
    _closing.dispose();
    _slotMinutes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _repository.get(Endpoints.settings);
      _name.text = _pick(data, ['companyName', 'name', 'businessName']);
      _email.text = _pick(data, ['email', 'contactEmail']);
      _phone.text = _pick(data, ['phone', 'contactPhone', 'whatsapp']);
      _opening.text = _pick(data, ['openingTime', 'opensAt'], fallback: '08:00');
      _closing.text = _pick(data, ['closingTime', 'closesAt'], fallback: '18:00');
      _slotMinutes.text = _pick(data, ['slotMinutes', 'slotIntervalMinutes'], fallback: '30');
      _defaultLocationId = _pick(data, ['defaultLocationId', 'locationId']);

      final days = data['workingDays'];
      if (days is List && days.isNotEmpty) {
        _workingDays
          ..clear()
          ..addAll(days.map((e) => int.tryParse(e.toString())).whereType<int>().where((e) => e >= 1 && e <= 7));
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final opening = _opening.text.trim().isEmpty ? '08:00' : _opening.text.trim();
    final closing = _closing.text.trim().isEmpty ? '18:00' : _closing.text.trim();
    final slotMinutes = int.tryParse(_slotMinutes.text.trim()) ?? 30;

    if (_workingDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione pelo menos um dia de atendimento.')));
      return;
    }

    setState(() => _saving = true);
    try {
      final locationId = await _ensureDefaultLocation(
        opening: opening,
        closing: closing,
        slotMinutes: slotMinutes,
      );

      await _repository.patch(Endpoints.settings, {
        'companyName': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'openingTime': opening,
        'closingTime': closing,
        'slotMinutes': slotMinutes,
        'workingDays': _workingDays.toList()..sort(),
        'defaultLocationId': locationId,
      });

      await _ensureShifts(locationId: locationId, opening: opening, closing: closing);
      _defaultLocationId = locationId;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agenda configurada e pronta para receber agendamentos.')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<String> _ensureDefaultLocation({
    required String opening,
    required String closing,
    required int slotMinutes,
  }) async {
    final locations = await _repository.list(Endpoints.locations);
    Map<String, dynamic>? location;

    if (_defaultLocationId != null && _defaultLocationId!.isNotEmpty) {
      for (final item in locations) {
        if (_id(item) == _defaultLocationId) {
          location = item;
          break;
        }
      }
    }

    if (location == null && locations.isNotEmpty) {
      final active = locations.where((e) => e['active'] != false).toList();
      location = active.isNotEmpty ? active.first : locations.first;
    }

    final payload = <String, dynamic>{
      'name': _name.text.trim().isEmpty ? 'Malta Wash' : _name.text.trim(),
      'active': true,
      'openingTime': opening,
      'closingTime': closing,
      'slotMinutes': slotMinutes,
      'workingDays': _workingDays.toList()..sort(),
      'isDefault': true,
    };

    if (location == null) {
      final created = await _repository.create(Endpoints.locations, payload);
      final id = _id(created);
      if (id.isEmpty) throw StateError('Não foi possível criar o local padrão da agenda.');
      return id;
    }

    final id = _id(location);
    if (id.isEmpty) throw StateError('O local padrão da agenda está sem identificador.');
    await _repository.patch(Endpoints.location(id), payload);
    return id;
  }

  Future<void> _ensureShifts({
    required String locationId,
    required String opening,
    required String closing,
  }) async {
    final existing = await _repository.list(Endpoints.shifts, query: {'locationId': locationId});
    if (existing.isNotEmpty) return;

    final days = _workingDays.toList()..sort();
    for (final weekday in days) {
      await _repository.create(Endpoints.shifts, {
        'locationId': locationId,
        'weekday': weekday,
        'dayOfWeek': weekday,
        'startTime': opening,
        'endTime': closing,
        'openingTime': opening,
        'closingTime': closing,
        'active': true,
      });
    }
  }

  String _id(Map<String, dynamic> item) => (item['id'] ?? item['objectId'] ?? '').toString().trim();

  String _pick(Map<String, dynamic> data, List<String> keys, {String fallback = ''}) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value is! Map && value.toString().trim().isNotEmpty) return value.toString();
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFEFF6FF)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF111827)]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF6A00), Color(0xFFFF8A34)]),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.settings_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Configurações da empresa', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                      SizedBox(height: 4),
                      Text('Configure dados e agenda de atendimento.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                    ]),
                  ),
                  IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: Colors.white)),
                ]),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!))
                        : SingleChildScrollView(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                const Text('Perfil da empresa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                                const SizedBox(height: 18),
                                _field(_name, 'Nome da empresa', Icons.storefront_rounded),
                                const SizedBox(height: 12),
                                _field(_email, 'E-mail', Icons.mail_outline_rounded, keyboard: TextInputType.emailAddress),
                                const SizedBox(height: 12),
                                _field(_phone, 'Telefone / WhatsApp', Icons.phone_rounded, keyboard: TextInputType.phone),
                                const SizedBox(height: 26),
                                const Text('Agenda de atendimento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                                const SizedBox(height: 5),
                                const Text('Esses horários alimentam automaticamente as opções que o cliente vê ao agendar.', style: TextStyle(color: Color(0xFF667085))),
                                const SizedBox(height: 16),
                                LayoutBuilder(builder: (context, constraints) {
                                  final compact = constraints.maxWidth < 620;
                                  if (compact) {
                                    return Column(children: [
                                      _field(_opening, 'Abre às', Icons.schedule_rounded),
                                      const SizedBox(height: 12),
                                      _field(_closing, 'Fecha às', Icons.schedule_rounded),
                                      const SizedBox(height: 12),
                                      _field(_slotMinutes, 'Intervalo (min)', Icons.timer_outlined, keyboard: TextInputType.number),
                                    ]);
                                  }
                                  return Row(children: [
                                    Expanded(child: _field(_opening, 'Abre às', Icons.schedule_rounded)),
                                    const SizedBox(width: 12),
                                    Expanded(child: _field(_closing, 'Fecha às', Icons.schedule_rounded)),
                                    const SizedBox(width: 12),
                                    Expanded(child: _field(_slotMinutes, 'Intervalo (min)', Icons.timer_outlined, keyboard: TextInputType.number)),
                                  ]);
                                }),
                                const SizedBox(height: 18),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _dayLabels.entries.map((entry) {
                                    final selected = _workingDays.contains(entry.key);
                                    return FilterChip(
                                      label: Text(entry.value),
                                      selected: selected,
                                      onSelected: (value) => setState(() {
                                        if (value) {
                                          _workingDays.add(entry.key);
                                        } else {
                                          _workingDays.remove(entry.key);
                                        }
                                      }),
                                      selectedColor: const Color(0xFFFFE7D6),
                                      checkmarkColor: const Color(0xFFFF6A00),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed: _saving ? null : _save,
                                    icon: _saving
                                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : const Icon(Icons.save_rounded),
                                    label: const Text('Salvar e ativar agenda'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF6A00),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {TextInputType? keyboard}) => TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        ),
      );
}
