import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';
import 'package:malta_wash/Src/Features/common/presentation/controllers/resource_list_controller.dart';
import 'package:malta_wash/Src/Shared/widgets/async_state_view.dart';
import 'package:malta_wash/Src/Shared/widgets/resource_table.dart';
import 'package:signals/signals_flutter.dart';

class ResourceListPage extends StatefulWidget {
  const ResourceListPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.endpoint,
    this.emptyTitle,
    this.visibleKeys,
    this.labels = const {},
  });

  final String title;
  final String subtitle;
  final String endpoint;
  final String? emptyTitle;
  final List<String>? visibleKeys;
  final Map<String, String> labels;

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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _CenterBackground()),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      title: widget.title,
                      subtitle: widget.subtitle,
                      onRefresh: controller.load,
                    ),
                    const SizedBox(height: 22),
                    Expanded(
                      child: Watch((_) => AsyncStateView(
                            isLoading: controller.isLoading.value,
                            errorMessage: controller.errorMessage.value,
                            isEmpty: controller.items.value.isEmpty,
                            onRetry: controller.load,
                            emptyTitle: widget.emptyTitle ?? 'Nenhum registro encontrado',
                            child: SingleChildScrollView(
                              child: ResourceTable(
                                items: controller.items.value,
                                visibleKeys: widget.visibleKeys,
                                labels: widget.labels,
                              ),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle, required this.onRefresh});
  final String title;
  final String subtitle;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 22, 18, 22),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155).withOpacity(.55)),
        boxShadow: const [BoxShadow(color: Color(0x220F172A), blurRadius: 28, offset: Offset(0, 14))],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF6A00), Color(0xFFFF8A34)]),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -.4)),
                const SizedBox(height: 5),
                Text(subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5, height: 1.4)),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: onRefresh,
            tooltip: 'Atualizar',
            style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(.08), foregroundColor: Colors.white),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _CenterBackground extends StatelessWidget {
  const _CenterBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CenterGridPainter(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFFFF7ED)],
          ),
        ),
      ),
    );
  }
}

class _CenterGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF64748B).withOpacity(.055)
      ..strokeWidth = .6;
    const gap = 34.0;
    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
