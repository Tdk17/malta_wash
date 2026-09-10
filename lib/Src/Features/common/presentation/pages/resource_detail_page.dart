import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';
import 'package:malta_wash/Src/Features/common/presentation/controllers/resource_detail_controller.dart';
import 'package:malta_wash/Src/Shared/widgets/async_state_view.dart';
import 'package:malta_wash/Src/Shared/widgets/page_header.dart';
import 'package:signals/signals_flutter.dart';

class ResourceDetailPage extends StatefulWidget {
  const ResourceDetailPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.endpoint,
  });

  final String title;
  final String subtitle;
  final String endpoint;

  @override
  State<ResourceDetailPage> createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends State<ResourceDetailPage> {
  late final ResourceDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = ResourceDetailController(
      sl<ResourceRepository>(),
      widget.endpoint,
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: widget.title,
            subtitle: widget.subtitle,
            action: IconButton(
              onPressed: controller.load,
              icon: const Icon(Icons.refresh),
            ),
          ),
          const SizedBox(height: 22),
          Expanded(
            child: Watch(
              (_) => AsyncStateView(
                isLoading: controller.isLoading.value,
                errorMessage: controller.errorMessage.value,
                isEmpty: controller.data.value.isEmpty,
                onRetry: controller.load,
                child: SingleChildScrollView(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: controller.data.value.entries
                            .where((e) => e.value is! Map && e.value is! List)
                            .map(
                              (entry) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 9),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        _label(entry.key),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        entry.value?.toString() ?? '—',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _label(String key) => key
      .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}')
      .trim();
}
