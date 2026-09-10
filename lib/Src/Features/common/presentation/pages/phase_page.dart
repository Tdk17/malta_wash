import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Shared/widgets/page_header.dart';

class PhasePage extends StatelessWidget {
  const PhasePage({super.key, required this.title, required this.description, required this.phase});
  final String title;
  final String description;
  final String phase;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(title: title, subtitle: description),
      const SizedBox(height: 24),
      Card(child: Padding(padding: const EdgeInsets.all(24), child: Row(children: [
        const Icon(Icons.construction_outlined, size: 40),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Módulo previsto para $phase', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 6), const Text('A tela está reservada na navegação. O documento base não define contrato de API específico para este módulo, portanto nenhum endpoint foi inventado no front.')])),
      ]))),
    ]),
  );
}
