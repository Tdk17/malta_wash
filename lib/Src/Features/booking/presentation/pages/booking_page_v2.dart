import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Features/booking/presentation/controllers/booking_controller.dart';
import 'package:signals/signals_flutter.dart';

class BookingPageV2 extends StatefulWidget {
  const BookingPageV2({super.key});

  @override
  State<BookingPageV2> createState() => _BookingPageV2State();
}

class _BookingPageV2State extends State<BookingPageV2> {
  late final BookingController controller = sl()..bootstrap();

  @override
  Widget build(BuildContext context) {
    return Watch((_) {
      final initialLoading = controller.isLoading.value &&
          controller.vehicles.value.isEmpty &&
          controller.services.value.isEmpty;

      if (initialLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          MediaQuery.sizeOf(context).width < 700 ? 16 : 28,
          24,
          MediaQuery.sizeOf(context).width < 700 ? 16 : 28,
          44,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _hero(),
                const SizedBox(height: 18),
                _progress(),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 700 ? 18 : 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.95),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x120F172A),
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
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F0),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Text(
                      controller.errorMessage.value!,
                      style: const TextStyle(
                        color: Color(0xFFB42318),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    if (controller.step.value > 0)
                      TextButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.step.value--,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Voltar'),
                      ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: controller.isLoading.value ? null : _continue,
                      icon: controller.isLoading.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
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
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
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
          BoxShadow(color: Color(0x220F172A), blurRadius: 32, offset: Offset(0, 14)),
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
                  'Agendar lavagem',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.8,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Escolha veículo, serviço, data e horário. Só o necessário.',
                  style: TextStyle(color: Color(0xFF94A3B8), height: 1.4),
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6A00), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.local_car_wash_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _progress() {
    const labels = ['Veículo', 'Serviço', 'Horário', 'Confirmar'];
    final mobile = MediaQuery.sizeOf(context).width < 700;
    return Row(
      children: List.generate(labels.length, (index) {
        final active = index <= controller.step.value;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFFFF6A00) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active
                        ? const Color(0xFFFF6A00)
                        : const Color(0xFFD5DBE5),
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
              if (!mobile) ...[
                const SizedBox(width: 7),
                Text(
                  labels[index],
                  style: TextStyle(
                    color: active
                        ? const Color(0xFF111827)
                        : const Color(0xFF98A2B3),
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
              ],
              if (index < labels.length - 1)
                Expanded(
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 9),
                    color: index < controller.step.value
                        ? const Color(0xFFFFB37D)
                        : const Color(0xFFDDE2E8),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _currentStep() {
    switch (controller.step.value) {
      case 0:
        return _choiceList(
          title: 'Qual veículo?',
          subtitle: 'Escolha o veículo que vai receber o serviço.',
          items: controller.vehicles.value,
          selectedId: controller.vehicleId.value,
          icon: Icons.directions_car_filled_rounded,
          emptyText: 'Cadastre um veículo antes de continuar.',
          titleOf: (item) => _first(item, const ['model', 'plate'], 'Veículo'),
          detailOf: (item) => [item['plate'], item['color'], item['category']]
              .where((e) => e != null && e.toString().trim().isNotEmpty)
              .map((e) => e.toString())
              .join(' • '),
          onTap: (id) => controller.vehicleId.value = id,
        );
      case 1:
        return _choiceList(
          title: 'Escolha o serviço',
          subtitle: 'Selecione a lavagem ou serviço desejado.',
          items: controller.services.value,
          selectedId: controller.serviceId.value,
          icon: Icons.local_car_wash_rounded,
          emptyText: 'A empresa ainda não cadastrou serviços.',
          titleOf: (item) => _first(item, const ['name', 'title', 'serviceName'], 'Serviço'),
          detailOf: (item) {
            final values = <String>[];
            final duration = item['durationMinutes'] ?? item['duration'];
            final price = item['price'] ?? item['basePrice'];
            if (duration != null) values.add('$duration min');
            if (price != null) values.add('R\$ $price');
            final description = _first(item, const ['description'], '');
            if (description.isNotEmpty) values.add(description);
            return values.join(' • ');
          },
          onTap: (id) {
            controller.serviceId.value = id;
            controller.date.value = null;
            controller.startAt.value = null;
            controller.slots.value = const [];
          },
        );
      case 2:
        return _dateTimeStep();
      default:
        return _reviewStep();
    }
  }

  Widget _choiceList({
    required String title,
    required String subtitle,
    required List<Map<String, dynamic>> items,
    required String? selectedId,
    required IconData icon,
    required String emptyText,
    required String Function(Map<String, dynamic>) titleOf,
    required String Function(Map<String, dynamic>) detailOf,
    required ValueChanged<String> onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: Color(0xFF667085))),
        const SizedBox(height: 18),
        if (items.isEmpty)
          _empty(emptyText)
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
                  return SizedBox(
                    width: width,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onTap(id),
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 170),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFFFF4EC)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFFFF6A00)
                                  : const Color(0xFFE2E8F0),
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFFFF6A00)
                                      : const Color(0xFFEEF4FF),
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
                                      titleOf(item),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (detailOf(item).isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        detailOf(item),
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
                                    : const Color(0xFFCBD5E1),
                              ),
                            ],
                          ),
                        ),
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

  Widget _dateTimeStep() {
    final slots = controller.slots.value
        .where((item) => item['available'] != false)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quando você quer vir?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        const Text('Escolha a data e depois o horário.', style: TextStyle(color: Color(0xFF667085))),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: controller.isLoading.value ? null : _pickDate,
          icon: const Icon(Icons.calendar_month_rounded),
          label: Text(
            controller.date.value == null
                ? 'Escolher data'
                : DateFormat('dd/MM/yyyy').format(controller.date.value!),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 52),
            foregroundColor: const Color(0xFF111827),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 18),
        if (controller.date.value == null)
          _empty('Escolha uma data para carregar os horários disponíveis.')
        else if (controller.isLoading.value)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (slots.isEmpty)
          _empty('Não há horários livres nessa data. Escolha outra data.')
        else ...[
          const Text('Horários disponíveis', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: slots.map((slot) {
              final startAt = (slot['startAt'] ?? slot['start'] ?? '').toString();
              final label = _timeLabel(startAt);
              final selected = controller.startAt.value == startAt;
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => controller.startAt.value = startAt,
                selectedColor: const Color(0xFFFFE7D6),
                checkmarkColor: const Color(0xFFFF6A00),
                side: BorderSide(
                  color: selected
                      ? const Color(0xFFFF6A00)
                      : const Color(0xFFDDE3EA),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _reviewStep() {
    final vehicle = _selected(controller.vehicles.value, controller.vehicleId.value);
    final service = _selected(controller.services.value, controller.serviceId.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Confirme seu agendamento', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        const Text('Confira os dados antes de confirmar.', style: TextStyle(color: Color(0xFF667085))),
        const SizedBox(height: 18),
        _reviewRow(
          Icons.directions_car_filled_rounded,
          'Veículo',
          [vehicle['model'], vehicle['plate']]
              .where((e) => e != null && e.toString().isNotEmpty)
              .map((e) => e.toString())
              .join(' • '),
        ),
        _reviewRow(
          Icons.local_car_wash_rounded,
          'Serviço',
          _first(service, const ['name', 'title', 'serviceName'], 'Serviço'),
        ),
        _reviewRow(
          Icons.calendar_month_rounded,
          'Data',
          controller.date.value == null
              ? ''
              : DateFormat('dd/MM/yyyy').format(controller.date.value!),
        ),
        _reviewRow(
          Icons.schedule_rounded,
          'Horário',
          _timeLabel(controller.startAt.value ?? ''),
        ),
      ],
    );
  }

  Widget _reviewRow(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF6A00), size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF667085), fontSize: 11.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF667085), height: 1.4)),
    );
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: today.add(const Duration(days: 180)),
      initialDate: controller.date.value ?? today,
    );
    if (picked == null) return;
    controller.date.value = picked;
    controller.startAt.value = null;
    await controller.loadSlots();
  }

  Future<void> _continue() async {
    controller.errorMessage.value = null;

    if (controller.step.value == 0 && controller.vehicleId.value == null) {
      controller.errorMessage.value = 'Selecione um veículo para continuar.';
      return;
    }
    if (controller.step.value == 1 && controller.serviceId.value == null) {
      controller.errorMessage.value = 'Selecione um serviço para continuar.';
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

    // Não abre modal sobre a rota após o POST. No Flutter Web/mobile isso
    // estava deixando a árvore visual em branco em alguns navegadores.
    // Após confirmação real da API, navega direto para a lista do cliente.
    context.go(RoutePaths.clientAppointments);
  }

  Map<String, dynamic> _selected(List<Map<String, dynamic>> items, String? id) {
    for (final item in items) {
      if (_id(item) == id) return item;
    }
    return <String, dynamic>{};
  }

  String _id(Map<String, dynamic> item) =>
      (item['id'] ?? item['objectId'] ?? '').toString().trim();

  String _first(Map<String, dynamic> item, List<String> keys, String fallback) {
    for (final key in keys) {
      final value = item[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return fallback;
  }

  String _timeLabel(String value) {
    if (value.trim().isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return DateFormat('HH:mm').format(parsed.toLocal());
    final match = RegExp(r'(\d{1,2}:\d{2})').firstMatch(value);
    return match?.group(1) ?? value;
  }
}
