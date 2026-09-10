import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Features/booking/presentation/controllers/booking_controller.dart';
import 'package:signals/signals_flutter.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late final BookingController controller = sl()..bootstrap();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: Watch((_) {
        if (controller.isLoading.value && controller.locations.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null && controller.locations.value.isEmpty) {
          return _CenteredMessage(
            icon: Icons.wifi_off_rounded,
            title: 'Não foi possível carregar o agendamento',
            text: controller.errorMessage.value!,
            actionLabel: 'Tentar novamente',
            onAction: controller.bootstrap,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 42),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Agendar lavagem', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  const SizedBox(height: 6),
                  const Text('Escolha o necessário e confirme seu horário.', style: TextStyle(color: Color(0xFF667085))),
                  const SizedBox(height: 22),
                  _Progress(step: controller.step.value),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE6EAF0)),
                    ),
                    child: _currentStep(),
                  ),
                  if (controller.errorMessage.value != null && controller.locations.value.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFFF1F0), borderRadius: BorderRadius.circular(14)),
                      child: Text(controller.errorMessage.value!, style: const TextStyle(color: Color(0xFFB42318))),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      if (controller.step.value > 0)
                        TextButton.icon(
                          onPressed: () => controller.step.value--,
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Voltar'),
                        ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: controller.isLoading.value ? null : _continue,
                        icon: controller.isLoading.value
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Icon(controller.step.value == 4 ? Icons.check_rounded : Icons.arrow_forward_rounded),
                        label: Text(controller.step.value == 4 ? 'Confirmar agendamento' : 'Continuar'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6A00),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 50),
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _currentStep() {
    switch (controller.step.value) {
      case 0:
        return _selectionStep(
          title: 'Onde você vai lavar?',
          subtitle: 'Selecione a unidade da Clinicar.',
          items: controller.locations.value,
          selectedId: controller.locationId.value,
          emptyTitle: 'Nenhuma unidade disponível',
          emptyText: 'A empresa ainda não cadastrou uma unidade ativa para agendamentos.',
          icon: Icons.storefront_rounded,
          labelBuilder: (item) => _firstText(item, const ['name', 'title', 'address', 'description'], fallback: 'Unidade'),
          detailBuilder: (item) => _firstText(item, const ['address', 'city', 'description']),
          onSelected: (id) => controller.locationId.value = id,
        );
      case 1:
        return _selectionStep(
          title: 'Qual veículo?',
          subtitle: 'Escolha o veículo que receberá o serviço.',
          items: controller.vehicles.value,
          selectedId: controller.vehicleId.value,
          emptyTitle: 'Nenhum veículo cadastrado',
          emptyText: 'Cadastre um veículo antes de continuar com o agendamento.',
          icon: Icons.directions_car_filled_rounded,
          labelBuilder: (item) => _firstText(item, const ['model', 'plate'], fallback: 'Veículo'),
          detailBuilder: (item) => [
            item['plate']?.toString(),
            item['color']?.toString(),
            item['category']?.toString(),
          ].whereType<String>().where((e) => e.trim().isNotEmpty).join(' • '),
          onSelected: (id) => controller.vehicleId.value = id,
        );
      case 2:
        return _selectionStep(
          title: 'Qual serviço?',
          subtitle: 'Selecione o tipo de lavagem cadastrado pela empresa.',
          items: controller.services.value,
          selectedId: controller.serviceId.value,
          emptyTitle: 'Nenhum serviço disponível',
          emptyText: 'A empresa ainda não cadastrou serviços ativos para agendamento.',
          icon: Icons.local_car_wash_rounded,
          labelBuilder: (item) => _firstText(item, const ['name', 'title', 'serviceName'], fallback: 'Serviço'),
          detailBuilder: (item) {
            final duration = item['durationMinutes'] ?? item['duration'];
            final price = item['price'] ?? item['basePrice'];
            final values = <String>[];
            if (duration != null) values.add('${duration} min');
            if (price != null) values.add('R\$ ${price.toString()}');
            final description = _firstText(item, const ['description']);
            if (description.isNotEmpty) values.add(description);
            return values.join(' • ');
          },
          onSelected: (id) => controller.serviceId.value = id,
        );
      case 3:
        return _dateAndTimeStep();
      default:
        return _reviewStep();
    }
  }

  Widget _selectionStep({
    required String title,
    required String subtitle,
    required List<Map<String, dynamic>> items,
    required String? selectedId,
    required String emptyTitle,
    required String emptyText,
    required IconData icon,
    required String Function(Map<String, dynamic>) labelBuilder,
    required String Function(Map<String, dynamic>) detailBuilder,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: Color(0xFF667085))),
        const SizedBox(height: 20),
        if (items.isEmpty)
          _EmptyChoice(title: emptyTitle, text: emptyText)
        else
          ...items.map((item) {
            final id = _id(item);
            final selected = selectedId == id;
            final detail = detailBuilder(item);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSelected(id),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFFFF5EE) : const Color(0xFFFAFBFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: selected ? const Color(0xFFFF6A00) : const Color(0xFFE6EAF0), width: selected ? 1.6 : 1),
                  ),
                  child: Row(children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(color: selected ? const Color(0xFFFF6A00) : const Color(0xFFFFEEE2), borderRadius: BorderRadius.circular(14)),
                      child: Icon(icon, color: selected ? Colors.white : const Color(0xFFFF6A00)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(labelBuilder(item), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                        if (detail.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(detail, style: const TextStyle(fontSize: 12.5, color: Color(0xFF667085), height: 1.35)),
                        ],
                      ]),
                    ),
                    Icon(selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: selected ? const Color(0xFFFF6A00) : const Color(0xFFB7C0CC)),
                  ]),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _dateAndTimeStep() {
    final availableSlots = controller.slots.value.where((s) => s['available'] != false).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Escolha a data e o horário', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
        const SizedBox(height: 5),
        const Text('Mostramos somente os horários disponíveis para sua escolha.', style: TextStyle(color: Color(0xFF667085))),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: _pickDate,
          icon: const Icon(Icons.calendar_month_rounded),
          label: Text(controller.date.value == null ? 'Escolher data' : DateFormat('dd/MM/yyyy').format(controller.date.value!)),
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        ),
        const SizedBox(height: 20),
        if (controller.date.value == null)
          const _EmptyChoice(title: 'Escolha uma data', text: 'Depois disso, os horários disponíveis aparecerão aqui.')
        else if (controller.isLoading.value)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
        else if (availableSlots.isEmpty)
          const _EmptyChoice(title: 'Sem horários disponíveis', text: 'Tente outra data para encontrar um horário livre.')
        else ...[
          const Text('Horários disponíveis', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: availableSlots.map((slot) {
              final startAt = (slot['startAt'] ?? slot['start'] ?? '').toString();
              final label = (slot['start'] ?? _timeLabel(startAt)).toString();
              return ChoiceChip(
                label: Text(label),
                selected: controller.startAt.value == startAt,
                onSelected: (_) => controller.startAt.value = startAt,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _reviewStep() {
    final location = _selected(controller.locations.value, controller.locationId.value);
    final vehicle = _selected(controller.vehicles.value, controller.vehicleId.value);
    final service = _selected(controller.services.value, controller.serviceId.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Confira seu agendamento', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
        const SizedBox(height: 5),
        const Text('Se estiver tudo certo, confirme.', style: TextStyle(color: Color(0xFF667085))),
        const SizedBox(height: 20),
        _ReviewRow(icon: Icons.storefront_rounded, label: 'Unidade', value: _firstText(location, const ['name', 'title', 'address'], fallback: 'Unidade selecionada')),
        _ReviewRow(icon: Icons.directions_car_filled_rounded, label: 'Veículo', value: [vehicle['model'], vehicle['plate']].whereType<Object>().map((e) => e.toString()).where((e) => e.isNotEmpty).join(' • ')),
        _ReviewRow(icon: Icons.local_car_wash_rounded, label: 'Serviço', value: _firstText(service, const ['name', 'title', 'serviceName'], fallback: 'Serviço selecionado')),
        _ReviewRow(icon: Icons.schedule_rounded, label: 'Data e horário', value: '${controller.date.value == null ? '' : DateFormat('dd/MM/yyyy').format(controller.date.value!)} • ${_timeLabel(controller.startAt.value ?? '')}'),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(14)),
          child: const Row(children: [
            Icon(Icons.notifications_active_outlined, color: Color(0xFFFF6A00), size: 20),
            SizedBox(width: 10),
            Expanded(child: Text('Você poderá acompanhar o agendamento e receber a atualização quando o veículo estiver pronto.', style: TextStyle(fontSize: 12.5, height: 1.4))),
          ]),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: today.add(const Duration(days: 180)),
      initialDate: controller.date.value ?? today,
    );
    if (date == null) return;
    controller.date.value = date;
    await controller.loadSlots();
  }

  Future<void> _continue() async {
    controller.errorMessage.value = null;

    if (controller.step.value == 0 && controller.locationId.value == null) {
      controller.errorMessage.value = 'Selecione a unidade para continuar.';
      return;
    }
    if (controller.step.value == 1 && controller.vehicleId.value == null) {
      controller.errorMessage.value = 'Selecione um veículo para continuar.';
      return;
    }
    if (controller.step.value == 2 && controller.serviceId.value == null) {
      controller.errorMessage.value = 'Selecione o serviço para continuar.';
      return;
    }
    if (controller.step.value == 3 && controller.startAt.value == null) {
      controller.errorMessage.value = 'Escolha uma data e um horário disponível.';
      return;
    }

    if (controller.step.value < 4) {
      controller.step.value++;
      return;
    }

    final result = await controller.confirm();
    if (!mounted || result == null) return;
    final protocol = result['id'] ?? result['objectId'] ?? result['protocol'] ?? '';
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF12B76A), size: 44),
        title: const Text('Agendamento confirmado', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text(
          protocol.toString().isEmpty
              ? 'Seu horário foi agendado com sucesso. Você pode acompanhar o atendimento em Meus agendamentos.'
              : 'Seu horário foi agendado com sucesso. Protocolo: $protocol',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Map<String, dynamic> _selected(List<Map<String, dynamic>> items, String? id) {
    if (id == null) return const {};
    for (final item in items) {
      if (_id(item) == id) return item;
    }
    return const {};
  }

  String _id(Map<String, dynamic> item) => (item['id'] ?? item['objectId'] ?? '').toString();

  String _firstText(Map<String, dynamic> item, List<String> keys, {String fallback = ''}) {
    for (final key in keys) {
      final value = item[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return fallback;
  }

  String _timeLabel(String raw) {
    if (raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) return DateFormat('HH:mm').format(parsed.toLocal());
    return raw.length >= 5 ? raw.substring(0, 5) : raw;
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    const labels = ['Unidade', 'Veículo', 'Serviço', 'Horário', 'Confirmar'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(labels.length, (index) {
          final active = index <= step;
          return Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: active ? const Color(0xFFFF6A00) : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: active ? const Color(0xFFFF6A00) : const Color(0xFFE1E6EC)),
              ),
              child: Text('${index + 1}. ${labels[index]}', style: TextStyle(color: active ? Colors.white : const Color(0xFF667085), fontSize: 12, fontWeight: FontWeight.w800)),
            ),
            if (index < labels.length - 1) Container(width: 16, height: 1, color: const Color(0xFFD9DEE5)),
          ]);
        }),
      ),
    );
  }
}

class _EmptyChoice extends StatelessWidget {
  const _EmptyChoice({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE6EAF0))),
      child: Column(children: [
        const Icon(Icons.info_outline_rounded, color: Color(0xFF98A2B3)),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: Color(0xFF667085), height: 1.4)),
      ]),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFFAFBFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE6EAF0))),
        child: Row(children: [
          Icon(icon, color: const Color(0xFFFF6A00), size: 21),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF667085))),
            const SizedBox(height: 2),
            Text(value.isEmpty ? '—' : value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ])),
        ]),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.icon, required this.title, required this.text, required this.actionLabel, required this.onAction});
  final IconData icon;
  final String title;
  final String text;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 44, color: const Color(0xFF98A2B3)),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF667085)))),
          const SizedBox(height: 16),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ]),
      ),
    );
  }
}
