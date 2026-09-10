import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Features/booking/presentation/controllers/booking_controller.dart';
import 'package:malta_wash/Src/Features/branding/presentation/controllers/branding_controller.dart';
import 'package:signals/signals_flutter.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late final BookingController controller = sl()..bootstrap();
  late final BrandingController branding = sl()..load();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F6F8),
      child: Watch((_) {
        if (controller.isLoading.value &&
            controller.vehicles.value.isEmpty &&
            controller.services.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 44),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Hero(
                    companyName: branding.branding.value.companyName,
                    step: controller.step.value,
                  ),
                  const SizedBox(height: 18),
                  _Progress(step: controller.step.value),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE4E8EE)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D0F172A),
                          blurRadius: 30,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: _currentStep(),
                  ),
                  if (controller.errorMessage.value != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F0),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        controller.errorMessage.value!,
                        style: const TextStyle(color: Color(0xFFB42318)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(children: [
                    if (controller.step.value > 0)
                      TextButton.icon(
                        onPressed: () => controller.step.value--,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Voltar'),
                      ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: controller.isLoading.value ? null : _continue,
                      icon: Icon(
                        controller.step.value == 3
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        controller.step.value == 3
                            ? 'Confirmar agendamento'
                            : 'Continuar',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6A00),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 52),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ]),
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
          title: 'Qual veículo?',
          subtitle: 'Escolha o veículo que você quer agendar.',
          items: controller.vehicles.value,
          selectedId: controller.vehicleId.value,
          emptyTitle: 'Nenhum veículo cadastrado',
          emptyText: 'Cadastre um veículo antes de continuar.',
          icon: Icons.directions_car_filled_rounded,
          labelBuilder: (item) => _firstText(
            item,
            const ['model', 'plate'],
            fallback: 'Veículo',
          ),
          detailBuilder: (item) => [
            item['plate']?.toString(),
            item['color']?.toString(),
            item['category']?.toString(),
          ].whereType<String>().where((e) => e.trim().isNotEmpty).join(' • '),
          onSelected: (id) => controller.vehicleId.value = id,
        );
      case 1:
        return _selectionStep(
          title: 'Escolha a lavagem',
          subtitle: 'Selecione uma das opções disponíveis.',
          items: controller.services.value,
          selectedId: controller.serviceId.value,
          emptyTitle: 'Nenhum serviço disponível',
          emptyText: 'A empresa ainda não cadastrou opções de lavagem.',
          icon: Icons.local_car_wash_rounded,
          labelBuilder: (item) => _firstText(
            item,
            const ['name', 'title', 'serviceName'],
            fallback: 'Lavagem',
          ),
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
      case 2:
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: Color(0xFF667085))),
        const SizedBox(height: 20),
        if (items.isEmpty)
          _EmptyChoice(title: emptyTitle, text: emptyText)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 720;
              final width = twoColumns
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: items.map((item) {
                  final id = _id(item);
                  final selected = selectedId == id;
                  final detail = detailBuilder(item);
                  return SizedBox(
                    width: width,
                    child: InkWell(
                      onTap: () => onSelected(id),
                      borderRadius: BorderRadius.circular(18),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 170),
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFFFF4EC)
                              : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFFF6A00)
                                : const Color(0xFFE5E9EF),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFFF6A00)
                                  : const Color(0xFFEEF3FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              icon,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  labelBuilder(item),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                if (detail.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    detail,
                                    style: const TextStyle(
                                      color: Color(0xFF667085),
                                      fontSize: 12.5,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(
                            selected
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: selected
                                ? const Color(0xFFFF6A00)
                                : const Color(0xFFCBD2DC),
                            size: 21,
                          ),
                        ]),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _dateAndTimeStep() {
    final availableSlots =
        controller.slots.value.where((s) => s['available'] != false).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quando você quer vir?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Escolha a data e depois um horário disponível.',
          style: TextStyle(color: Color(0xFF667085)),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: _pickDate,
          icon: const Icon(Icons.calendar_month_rounded),
          label: Text(
            controller.date.value == null
                ? 'Escolher data'
                : DateFormat('dd/MM/yyyy').format(controller.date.value!),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF111827),
            minimumSize: const Size(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (controller.date.value == null)
          const _EmptyChoice(
            title: 'Escolha uma data',
            text: 'Os horários livres aparecerão aqui.',
          )
        else if (controller.isLoading.value)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (availableSlots.isEmpty)
          const _EmptyChoice(
            title: 'Sem horários disponíveis',
            text: 'Escolha outra data para continuar.',
          )
        else
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: availableSlots.map((slot) {
              final startAt =
                  (slot['startAt'] ?? slot['start'] ?? '').toString();
              final label =
                  (slot['start'] ?? _timeLabel(startAt)).toString();
              return ChoiceChip(
                label: Text(label),
                selected: controller.startAt.value == startAt,
                selectedColor: const Color(0xFFFFE7D6),
                onSelected: (_) => controller.startAt.value = startAt,
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _reviewStep() {
    final vehicle = _selected(controller.vehicles.value, controller.vehicleId.value);
    final service = _selected(controller.services.value, controller.serviceId.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tudo certo?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Confira antes de confirmar.',
          style: TextStyle(color: Color(0xFF667085)),
        ),
        const SizedBox(height: 20),
        _ReviewRow(
          icon: Icons.directions_car_filled_rounded,
          label: 'Veículo',
          value: [vehicle['model'], vehicle['plate']]
              .whereType<Object>()
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .join(' • '),
        ),
        _ReviewRow(
          icon: Icons.local_car_wash_rounded,
          label: 'Lavagem',
          value: _firstText(
            service,
            const ['name', 'title', 'serviceName'],
            fallback: 'Serviço selecionado',
          ),
        ),
        _ReviewRow(
          icon: Icons.schedule_rounded,
          label: 'Data e horário',
          value:
              '${controller.date.value == null ? '' : DateFormat('dd/MM/yyyy').format(controller.date.value!)} • ${_timeLabel(controller.startAt.value ?? '')}',
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF4FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(children: [
            Icon(Icons.notifications_active_rounded,
                color: Color(0xFF2563EB), size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Você poderá acompanhar o agendamento e será avisado quando o veículo estiver pronto.',
                style: TextStyle(fontSize: 12.5, height: 1.4),
              ),
            ),
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

    if (controller.step.value == 0 && controller.vehicleId.value == null) {
      controller.errorMessage.value = 'Selecione um veículo para continuar.';
      return;
    }
    if (controller.step.value == 1 && controller.serviceId.value == null) {
      controller.errorMessage.value = 'Selecione a lavagem para continuar.';
      return;
    }
    if (controller.step.value == 2 && controller.startAt.value == null) {
      controller.errorMessage.value = 'Escolha uma data e um horário disponível.';
      return;
    }

    if (controller.step.value < 3) {
      controller.step.value++;
      return;
    }

    final result = await controller.confirm();
    if (!mounted || result == null) return;
    final protocol =
        result['id'] ?? result['objectId'] ?? result['protocol'] ?? '';
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: const Icon(Icons.check_circle_rounded,
            color: Color(0xFF12B76A), size: 44),
        title: const Text(
          'Agendamento confirmado',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          protocol.toString().isEmpty
              ? 'Seu horário foi reservado. Você pode acompanhar tudo em Meus agendamentos.'
              : 'Seu horário foi reservado. Protocolo: $protocol',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _selected(
    List<Map<String, dynamic>> items,
    String? id,
  ) {
    for (final item in items) {
      if (_id(item) == id) return item;
    }
    return <String, dynamic>{};
  }

  String _id(Map<String, dynamic> item) =>
      (item['id'] ?? item['objectId'] ?? '').toString();

  String _firstText(
    Map<String, dynamic> item,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = item[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return fallback;
  }

  String _timeLabel(String value) {
    if (value.isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return DateFormat('HH:mm').format(parsed.toLocal());
    return value;
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.companyName, required this.step});
  final String companyName;
  final int step;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B0F14), Color(0xFF151B24)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x1A0F172A), blurRadius: 28, offset: Offset(0, 12)),
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFF6A00), shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Text(
                companyName.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFFF9B54),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ]),
            const SizedBox(height: 13),
            const Text(
              'Agendar lavagem',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -.8,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Rápido, simples e sem etapas desnecessárias.',
              style: TextStyle(color: Color(0xFF9AA6B5)),
            ),
          ]),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(.12),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF2563EB).withOpacity(.25)),
          ),
          child: const Icon(Icons.local_car_wash_rounded, color: Color(0xFF60A5FA)),
        ),
      ]),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    const labels = ['Veículo', 'Lavagem', 'Horário', 'Confirmar'];
    return Row(
      children: List.generate(labels.length, (index) {
        final active = index <= step;
        return Expanded(
          child: Row(children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? const Color(0xFFFF6A00) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: active
                      ? const Color(0xFFFF6A00)
                      : const Color(0xFFD9DEE6),
                ),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: active ? Colors.white : const Color(0xFF98A2B3),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 7),
            if (MediaQuery.sizeOf(context).width >= 700)
              Text(
                labels[index],
                style: TextStyle(
                  color: active
                      ? const Color(0xFF111827)
                      : const Color(0xFF98A2B3),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            if (index < labels.length - 1)
              Expanded(
                child: Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: index < step
                      ? const Color(0xFFFFB37D)
                      : const Color(0xFFDDE2E8),
                ),
              ),
          ]),
        );
      }),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Row(children: [
        Icon(icon, color: const Color(0xFFFF6A00), size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ]),
        ),
      ]),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(text, style: const TextStyle(color: Color(0xFF667085))),
      ]),
    );
  }
}
