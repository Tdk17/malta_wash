import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:malta_wash/Src/Shared/widgets/async_state_view.dart';
import 'package:malta_wash/Src/Shared/widgets/metric_card.dart';
import 'package:malta_wash/Src/Shared/widgets/page_header.dart';
import 'package:signals/signals_flutter.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});
  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late final DashboardController controller = sl()..load();
  final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(title: 'Dashboard', subtitle: 'Visão comercial e operacional da unidade.', action: IconButton(onPressed: controller.load, icon: const Icon(Icons.refresh))),
      const SizedBox(height: 22),
      Expanded(child: Watch((_) => AsyncStateView(
        isLoading: controller.isLoading.value,
        errorMessage: controller.errorMessage.value,
        isEmpty: controller.metrics.value.isEmpty,
        onRetry: controller.load,
        child: SingleChildScrollView(child: Wrap(spacing: 14, runSpacing: 14, children: [
          SizedBox(width: 300, child: MetricCard(label: 'Faturamento', value: _money(controller.metrics.value['revenue'] ?? controller.metrics.value['grossRevenue']), icon: Icons.payments_outlined)),
          SizedBox(width: 300, child: MetricCard(label: 'Agendamentos', value: _text(controller.metrics.value['appointments']), icon: Icons.event_available_outlined)),
          SizedBox(width: 300, child: MetricCard(label: 'Ticket médio', value: _money(controller.metrics.value['averageTicket']), icon: Icons.receipt_long_outlined)),
          SizedBox(width: 300, child: MetricCard(label: 'Ocupação', value: _percent(controller.metrics.value['occupancy']), icon: Icons.calendar_view_week_outlined)),
          SizedBox(width: 300, child: MetricCard(label: 'Clientes novos', value: _text(controller.metrics.value['newCustomers']), icon: Icons.person_add_alt_1_outlined)),
          SizedBox(width: 300, child: MetricCard(label: 'Cancelamentos', value: _percent(controller.metrics.value['cancellationRate']), icon: Icons.event_busy_outlined)),
          SizedBox(width: 300, child: MetricCard(label: 'Planos ativos', value: _text(controller.metrics.value['activeSubscriptions']), icon: Icons.workspace_premium_outlined)),
          SizedBox(width: 300, child: MetricCard(label: 'Em atendimento', value: _text(controller.operation.value['inProgress']), icon: Icons.local_car_wash_outlined)),
        ])),
      ))),
    ]),
  );

  String _text(dynamic v) => v == null ? '—' : v.toString();
  String _money(dynamic v) => v is num ? currency.format(v) : _text(v);
  String _percent(dynamic v) => v is num ? '${(v <= 1 ? v * 100 : v).toStringAsFixed(1)}%' : _text(v);
}
