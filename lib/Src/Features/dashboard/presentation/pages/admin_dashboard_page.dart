import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:malta_wash/Src/Shared/widgets/async_state_view.dart';
import 'package:signals/signals_flutter.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late final DashboardController controller = sl()..load();

  @override
  Widget build(BuildContext context) {
    return Watch((_) => AsyncStateView(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value,
          isEmpty: false,
          onRetry: controller.load,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 42),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Visão de hoje', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1)),
                          SizedBox(height: 6),
                          Text('O essencial para tocar a operação sem complicação.', style: TextStyle(color: Color(0xFF667085), fontSize: 15)),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Atualizar',
                      onPressed: controller.load,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                LayoutBuilder(
                  builder: (context, c) {
                    final width = c.maxWidth;
                    final itemWidth = width >= 1050 ? (width - 48) / 4 : width >= 650 ? (width - 16) / 2 : width;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _StatusCard(width: itemWidth, icon: Icons.event_available_rounded, label: 'Agendamentos hoje', value: _text(controller.metrics.value['appointmentsToday'] ?? controller.metrics.value['appointments']), helper: 'Programados para hoje'),
                        _StatusCard(width: itemWidth, icon: Icons.local_car_wash_rounded, label: 'Em atendimento', value: _text(controller.operation.value['inProgress']), helper: 'Veículos em lavagem'),
                        _StatusCard(width: itemWidth, icon: Icons.check_circle_rounded, label: 'Prontos', value: _text(controller.operation.value['ready']), helper: 'Aguardando retirada'),
                        _StatusCard(width: itemWidth, icon: Icons.people_alt_rounded, label: 'Clientes', value: _text(controller.metrics.value['customers'] ?? controller.metrics.value['totalCustomers']), helper: 'Base cadastrada'),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                const Text('Ações rápidas', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, c) {
                    final compact = c.maxWidth < 760;
                    final cards = [
                      _QuickAction(icon: Icons.calendar_month_rounded, title: 'Abrir agenda', subtitle: 'Veja os horários do dia', onTap: () => context.go(RoutePaths.adminCalendar)),
                      _QuickAction(icon: Icons.local_car_wash_rounded, title: 'Atendimentos', subtitle: 'Veja quem está lavando e quem já está pronto', onTap: () => context.go(RoutePaths.adminOperation)),
                      _QuickAction(icon: Icons.people_alt_rounded, title: 'Clientes', subtitle: 'Consulte os clientes cadastrados', onTap: () => context.go(RoutePaths.adminCustomers)),
                    ];
                    if (compact) return Column(children: cards.map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: e)).toList());
                    return Row(children: [for (int i = 0; i < cards.length; i++) ...[Expanded(child: cards[i]), if (i < cards.length - 1) const SizedBox(width: 14)]]);
                  },
                ),
              ],
            ),
          ),
        ));
  }

  String _text(dynamic value) => value == null ? '0' : value.toString();
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.width, required this.icon, required this.label, required this.value, required this.helper});
  final double width;
  final IconData icon;
  final String label;
  final String value;
  final String helper;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE9ECF1)),
          boxShadow: const [BoxShadow(color: Color(0x0B0F172A), blurRadius: 24, offset: Offset(0, 10))],
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFFFFF1E8), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: const Color(0xFFFF6A00)),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Color(0xFF667085), fontWeight: FontWeight.w700, fontSize: 12.5)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: -.5)),
            Text(helper, style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 11.5)),
          ])),
        ]),
      );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE9ECF1)), borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              Icon(icon, color: const Color(0xFFFF6A00), size: 28),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Color(0xFF667085), fontSize: 12.5, height: 1.3)),
              ])),
              const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: Color(0xFF98A2B3)),
            ]),
          ),
        ),
      );
}
