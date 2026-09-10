import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Features/vehicles/presentation/controllers/vehicles_controller.dart';
import 'package:malta_wash/Src/Shared/widgets/async_state_view.dart';
import 'package:signals/signals_flutter.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  late final VehiclesController controller = sl()..load();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Meus veículos', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                          SizedBox(height: 5),
                          Text('Cadastre só o necessário para agendar mais rápido.', style: TextStyle(color: Color(0xFF667085))),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _newVehicle,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Adicionar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6A00),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Watch((_) => AsyncStateView(
                        isLoading: controller.isLoading.value,
                        errorMessage: controller.errorMessage.value,
                        isEmpty: controller.items.value.isEmpty,
                        onRetry: controller.load,
                        emptyTitle: 'Nenhum veículo cadastrado',
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 380,
                            mainAxisExtent: 160,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: controller.items.value.length,
                          itemBuilder: (_, index) {
                            final v = controller.items.value[index];
                            final model = (v.model ?? '').trim();
                            final color = (v.color ?? '').trim();
                            final category = (v.category ?? '').trim();
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE6EAF0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(color: const Color(0xFFFFF2E9), borderRadius: BorderRadius.circular(14)),
                                      child: Icon(_categoryIcon(category), color: const Color(0xFFFF6A00)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(model.isEmpty ? 'Veículo' : model, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                                          const SizedBox(height: 2),
                                          Text(category.isEmpty ? 'Categoria não informada' : category, style: const TextStyle(fontSize: 12, color: Color(0xFF667085))),
                                        ],
                                      ),
                                    ),
                                  ]),
                                  const Spacer(),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      _InfoPill(icon: Icons.pin_outlined, text: v.plate.isEmpty ? 'Sem placa' : v.plate),
                                      if (color.isNotEmpty) _InfoPill(icon: Icons.palette_outlined, text: color),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'CAMINHÃO':
      case 'CAMINHAO':
        return Icons.local_shipping_rounded;
      case 'CARRETA':
        return Icons.fire_truck_rounded;
      case 'VAN':
        return Icons.airport_shuttle_rounded;
      default:
        return Icons.directions_car_filled_rounded;
    }
  }

  Future<void> _newVehicle() async {
    final formKey = GlobalKey<FormState>();
    final plate = TextEditingController();
    final model = TextEditingController();
    final color = TextEditingController();
    String category = 'CARRO';

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('Adicionar veículo', style: TextStyle(fontWeight: FontWeight.w900)),
          content: SizedBox(
            width: 480,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Leva menos de um minuto.', style: TextStyle(color: Color(0xFF667085))),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: plate,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: 'Placa', hintText: 'ABC1D23', prefixIcon: Icon(Icons.pin_outlined)),
                      validator: (v) => (v == null || v.trim().length < 7) ? 'Informe a placa.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: model,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Qual é o veículo?', hintText: 'Ex.: Corsa', prefixIcon: Icon(Icons.directions_car_outlined)),
                      validator: (v) => (v == null || v.trim().length < 2) ? 'Informe o veículo.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: color,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Cor', hintText: 'Ex.: Preto', prefixIcon: Icon(Icons.palette_outlined)),
                    ),
                    const SizedBox(height: 18),
                    const Text('Categoria', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['CARRO', 'VAN', 'CAMINHÃO', 'CARRETA'].map((item) {
                        final selected = category == item;
                        return ChoiceChip(
                          label: Text(_categoryLabel(item)),
                          selected: selected,
                          onSelected: (_) => setDialogState(() => category = item),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6A00), foregroundColor: Colors.white),
              child: const Text('Salvar veículo'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;
    await controller.create({
      'plate': plate.text.trim().toUpperCase(),
      'model': model.text.trim(),
      'color': color.text.trim(),
      'category': category,
    });
  }

  String _categoryLabel(String value) => switch (value) {
        'CAMINHÃO' => 'Caminhão',
        'CARRETA' => 'Carreta',
        'VAN' => 'Van',
        _ => 'Carro',
      };
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: const Color(0xFF667085)),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF475467))),
      ]),
    );
  }
}
