import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Features/booking/presentation/controllers/booking_controller.dart';
import 'package:malta_wash/Src/Shared/widgets/page_header.dart';
import 'package:signals/signals_flutter.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late final BookingController controller = sl()..bootstrap();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Agendar lavagem',
          subtitle:
              'Unidade → veículo → serviço → adicionais → data e horário → confirmação.',
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Watch((_) {
            if (controller.isLoading.value &&
                controller.locations.value.isEmpty)
              return const Center(child: CircularProgressIndicator());
            if (controller.errorMessage.value != null &&
                controller.locations.value.isEmpty)
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(controller.errorMessage.value!),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: controller.bootstrap,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            return Stepper(
              currentStep: controller.step.value,
              onStepContinue: _continue,
              onStepCancel: controller.step.value > 0
                  ? () => controller.step.value--
                  : null,
              controlsBuilder: (_, details) => Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(
                        controller.step.value == 5
                            ? 'Confirmar agendamento'
                            : 'Continuar',
                      ),
                    ),
                    if (controller.step.value > 0) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Voltar'),
                      ),
                    ],
                  ],
                ),
              ),
              steps: [
                Step(
                  title: const Text('Unidade'),
                  isActive: controller.step.value >= 0,
                  content: _selectFrom(
                    'Selecione a unidade',
                    controller.locations.value,
                    controller.locationId.value,
                    (v) => controller.locationId.value = v,
                  ),
                ),
                Step(
                  title: const Text('Veículo'),
                  isActive: controller.step.value >= 1,
                  content: _selectFrom(
                    'Selecione o veículo',
                    controller.vehicles.value,
                    controller.vehicleId.value,
                    (v) => controller.vehicleId.value = v,
                    labelKeys: const ['plate', 'brand', 'model'],
                  ),
                ),
                Step(
                  title: const Text('Serviço'),
                  isActive: controller.step.value >= 2,
                  content: Column(
                    children: [
                      _selectFrom(
                        'Selecione o serviço',
                        controller.services.value,
                        controller.serviceId.value,
                        (v) => controller.serviceId.value = v,
                      ),
                      const SizedBox(height: 12),
                      ...controller.addons.value.map((a) {
                        final id = _id(a);
                        final selected = controller.addonIds.value.contains(id);
                        return CheckboxListTile(
                          value: selected,
                          title: Text(_name(a)),
                          subtitle: Text(_price(a)),
                          onChanged: (v) {
                            final next = [...controller.addonIds.value];
                            if (v == true) {
                              if (!next.contains(id)) next.add(id);
                            } else {
                              next.remove(id);
                            }
                            controller.addonIds.value = next;
                          },
                        );
                      }),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Data'),
                  isActive: controller.step.value >= 3,
                  content: Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        controller.date.value == null
                            ? 'Escolher data'
                            : DateFormat(
                                'dd/MM/yyyy',
                              ).format(controller.date.value!),
                      ),
                    ),
                  ),
                ),
                Step(
                  title: const Text('Horário'),
                  isActive: controller.step.value >= 4,
                  content: controller.slots.value.isEmpty
                      ? const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Selecione uma data para consultar a disponibilidade real.',
                          ),
                        )
                      : Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: controller.slots.value
                              .where((s) => s['available'] != false)
                              .map((slot) {
                                final start =
                                    (slot['startAt'] ?? slot['start'] ?? '')
                                        .toString();
                                return ChoiceChip(
                                  label: Text(
                                    (slot['start'] ?? start).toString(),
                                  ),
                                  selected: controller.startAt.value == start,
                                  onSelected: (_) =>
                                      controller.startAt.value = start,
                                );
                              })
                              .toList(),
                        ),
                ),
                Step(
                  title: const Text('Revisão e pagamento'),
                  isActive: controller.step.value >= 5,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: controller.paymentMode.value,
                        decoration: const InputDecoration(
                          labelText: 'Forma de pagamento',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'ON_SITE',
                            child: Text('Pagar no local'),
                          ),
                          DropdownMenuItem(
                            value: 'ONLINE',
                            child: Text('Pagamento online'),
                          ),
                        ],
                        onChanged: (v) =>
                            controller.paymentMode.value = v ?? 'ON_SITE',
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Cupom (opcional)',
                        ),
                        onChanged: (v) => controller.couponCode.value =
                            v.trim().isEmpty ? null : v.trim(),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'A API deve validar novamente a disponibilidade ao confirmar; o horário exibido nesta etapa não reserva o slot sozinho.',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    ),
  );

  Widget _selectFrom(
    String hint,
    List<Map<String, dynamic>> items,
    String? value,
    ValueChanged<String?> onChanged, {
    List<String> labelKeys = const ['name', 'title', 'description'],
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: hint),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: _id(item),
              child: Text(
                labelKeys
                        .map((k) => item[k]?.toString())
                        .whereType<String>()
                        .where((e) => e.isNotEmpty)
                        .join(' • ')
                        .isEmpty
                    ? _id(item)
                    : labelKeys
                          .map((k) => item[k]?.toString())
                          .whereType<String>()
                          .where((e) => e.isNotEmpty)
                          .join(' • '),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  String _id(Map<String, dynamic> item) =>
      (item['id'] ?? item['objectId'] ?? '').toString();
  String _name(Map<String, dynamic> item) =>
      (item['name'] ?? item['title'] ?? 'Adicional').toString();
  String _price(Map<String, dynamic> item) =>
      item['price'] == null ? '' : 'R\$ ${item['price']}';

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      initialDate: controller.date.value ?? DateTime.now(),
    );
    if (date == null) return;
    controller.date.value = date;
    controller.startAt.value = null;
    await controller.loadSlots();
  }

  Future<void> _continue() async {
    if (controller.step.value < 5) {
      controller.step.value++;
      if (controller.step.value == 4) await controller.loadSlots();
      return;
    }
    final result = await controller.confirm();
    if (!mounted || result == null) return;
    final protocol = result['id'] ?? result['protocol'] ?? '';
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Agendamento criado'),
        content: Text(
          protocol.toString().isEmpty
              ? 'Seu agendamento foi criado com sucesso.'
              : 'Protocolo: $protocol',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
