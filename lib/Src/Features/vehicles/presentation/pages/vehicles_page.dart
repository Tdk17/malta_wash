import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Features/vehicles/presentation/controllers/vehicles_controller.dart';
import 'package:malta_wash/Src/Shared/widgets/async_state_view.dart';
import 'package:malta_wash/Src/Shared/widgets/page_header.dart';
import 'package:signals/signals_flutter.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});
  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  late final VehiclesController controller = sl()..load();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(title: 'Meus veículos', subtitle: 'Cadastre os veículos usados nos agendamentos.', action: ElevatedButton.icon(onPressed: _newVehicle, icon: const Icon(Icons.add), label: const Text('Adicionar veículo'))),
      const SizedBox(height: 22),
      Expanded(child: Watch((_) => AsyncStateView(
        isLoading: controller.isLoading.value,
        errorMessage: controller.errorMessage.value,
        isEmpty: controller.items.value.isEmpty,
        onRetry: controller.load,
        emptyTitle: 'Você ainda não cadastrou veículos',
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 360, mainAxisExtent: 170, crossAxisSpacing: 14, mainAxisSpacing: 14),
          itemCount: controller.items.value.length,
          itemBuilder: (_, index) {
            final v = controller.items.value[index];
            return Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const Icon(Icons.directions_car), const SizedBox(width: 10), Expanded(child: Text('${v.brand ?? ''} ${v.model ?? ''}'.trim().isEmpty ? 'Veículo' : '${v.brand ?? ''} ${v.model ?? ''}', style: Theme.of(context).textTheme.titleLarge))]),
              const SizedBox(height: 12),
              Text(v.plate.isEmpty ? 'Placa não informada' : v.plate, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text([v.year?.toString(), v.color, v.category].whereType<String>().where((e) => e.isNotEmpty).join(' • ')),
            ])));
          },
        ),
      ))),
    ]),
  );

  Future<void> _newVehicle() async {
    final formKey = GlobalKey<FormState>();
    final plate = TextEditingController();
    final brand = TextEditingController();
    final model = TextEditingController();
    final year = TextEditingController();
    final color = TextEditingController();
    final category = TextEditingController();
    final notes = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Novo veículo'),
      content: SizedBox(width: 520, child: Form(key: formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: plate, decoration: const InputDecoration(labelText: 'Placa'), validator: (v) => (v == null || v.trim().length < 7) ? 'Informe a placa.' : null),
        const SizedBox(height: 10),
        TextField(controller: brand, decoration: const InputDecoration(labelText: 'Marca')),
        const SizedBox(height: 10),
        TextField(controller: model, decoration: const InputDecoration(labelText: 'Modelo')),
        const SizedBox(height: 10),
        TextField(controller: year, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ano')),
        const SizedBox(height: 10),
        TextField(controller: color, decoration: const InputDecoration(labelText: 'Cor')),
        const SizedBox(height: 10),
        TextField(controller: category, decoration: const InputDecoration(labelText: 'Categoria / porte')),
        const SizedBox(height: 10),
        TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Observações')),
      ])))),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), ElevatedButton(onPressed: () { if (formKey.currentState!.validate()) Navigator.pop(context, true); }, child: const Text('Salvar'))],
    ));
    if (ok != true) return;
    await controller.create({'plate': plate.text.trim().toUpperCase(), 'brand': brand.text.trim(), 'model': model.text.trim(), 'year': int.tryParse(year.text), 'color': color.text.trim(), 'category': category.text.trim(), 'notes': notes.text.trim()});
  }
}
