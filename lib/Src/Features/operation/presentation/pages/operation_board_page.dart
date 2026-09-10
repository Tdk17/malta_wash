import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';
import 'package:malta_wash/Src/Features/common/presentation/controllers/resource_list_controller.dart';
import 'package:malta_wash/Src/Shared/widgets/async_state_view.dart';
import 'package:malta_wash/Src/Shared/widgets/page_header.dart';
import 'package:signals/signals_flutter.dart';

class OperationBoardPage extends StatefulWidget {
  const OperationBoardPage({super.key});

  @override
  State<OperationBoardPage> createState() => _OperationBoardPageState();
}

class _OperationBoardPageState extends State<OperationBoardPage> {
  late final controller = ResourceListController(
    sl<ResourceRepository>(),
    Endpoints.workOrders,
  )..load();

  static const columns = [
    'WAITING',
    'WASHING',
    'FINISHING',
    'INSPECTION',
    'READY',
  ];

  static const labels = {
    'WAITING': 'Aguardando',
    'WASHING': 'Em lavagem',
    'FINISHING': 'Acabamento',
    'INSPECTION': 'Inspeção',
    'READY': 'Prontos',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Fila operacional',
            subtitle: 'Acompanhe a execução das ordens de serviço em tempo real.',
            action: IconButton(
              onPressed: controller.load,
              icon: const Icon(Icons.refresh),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Watch(
              (_) => AsyncStateView(
                isLoading: controller.isLoading.value,
                errorMessage: controller.errorMessage.value,
                isEmpty: controller.items.value.isEmpty,
                onRetry: controller.load,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: columns.map((status) {
                      final items = controller.items.value
                          .where(
                            (e) => (e['status'] ?? '')
                                .toString()
                                .toUpperCase() == status,
                          )
                          .toList();

                      return Container(
                        width: 300,
                        margin: const EdgeInsets.only(right: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${labels[status]} (${items.length})',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            ...items.map(
                              (item) => Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (item['vehiclePlate'] ??
                                                item['plate'] ??
                                                item['id'] ??
                                                'OS')
                                            .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        (item['serviceName'] ??
                                                item['service'] ??
                                                'Serviço')
                                            .toString(),
                                      ),
                                      if (item['customerName'] != null)
                                        Text(item['customerName'].toString()),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
