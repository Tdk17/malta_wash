import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';
import 'package:malta_wash/Src/Features/common/presentation/controllers/resource_list_controller.dart';
import 'package:malta_wash/Src/Shared/widgets/async_state_view.dart';
import 'package:malta_wash/Src/Shared/widgets/page_header.dart';
import 'package:malta_wash/Src/Shared/widgets/resource_table.dart';
import 'package:signals/signals_flutter.dart';

class ResourceListPage extends StatefulWidget {
  const ResourceListPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.endpoint,
    this.emptyTitle,
  });
  final String title;
  final String subtitle;
  final String endpoint;
  final String? emptyTitle;

  @override
  State<ResourceListPage> createState() => _ResourceListPageState();
}

class _ResourceListPageState extends State<ResourceListPage> {
  late final ResourceListController controller;

  @override
  void initState() {
    super.initState();
    controller = ResourceListController(sl<ResourceRepository>(), widget.endpoint)..load();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PageHeader(
            title: widget.title,
            subtitle: widget.subtitle,
            action: IconButton(onPressed: controller.load, icon: const Icon(Icons.refresh)),
          ),
          const SizedBox(height: 22),
          Expanded(child: Watch((_) => AsyncStateView(
                isLoading: controller.isLoading.value,
                errorMessage: controller.errorMessage.value,
                isEmpty: controller.items.value.isEmpty,
                onRetry: controller.load,
                emptyTitle: widget.emptyTitle ?? 'Nenhum registro encontrado',
                child: SingleChildScrollView(child: ResourceTable(items: controller.items.value)),
              ))),
        ]),
      );
}
