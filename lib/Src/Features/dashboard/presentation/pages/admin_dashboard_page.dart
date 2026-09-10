import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Features/branding/presentation/controllers/branding_controller.dart';
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
  late final BrandingController branding = sl()..load();

  @override
  Widget build(BuildContext context) {
    return Watch((_) => AsyncStateView(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value,
          isEmpty: false,
          onRetry: controller.load,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 44),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1260),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DashboardHero(
                      companyName: branding.branding.value.companyName,
                      onRefresh: controller.load,
                    ),
                    const SizedBox(height: 22),
                    LayoutBuilder(
                      builder: (context, c) {
                        final width = c.maxWidth;
                        final itemWidth = width >= 1040
                            ? (width - 48) / 4
                            : width >= 650
                                ? (width - 16) / 2
                                : width;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _StatusCard(
                              width: itemWidth,
                              icon: Icons.event_available_rounded,
                              label: 'Agendamentos hoje',
                              value: _text(controller.metrics.value['appointmentsToday'] ?? controller.metrics.value['appointments']),
                              helper: 'Programados para hoje',
                              accent: const Color(0xFFFF6A00),
                            ),
                            _StatusCard(
                              width: itemWidth,
                              icon: Icons.local_car_wash_rounded,
                              label: 'Em atendimento',
                              value: _text(controller.operation.value['inProgress']),
                              helper: 'Veículos em lavagem',
                              accent: const Color(0xFF2563EB),
                            ),
                            _StatusCard(
                              width: itemWidth,
                              icon: Icons.check_circle_rounded,
                              label: 'Prontos',
                              value: _text(controller.operation.value['ready']),
                              helper: 'Aguardando retirada',
                              accent: const Color(0xFF12B76A),
                            ),
                            _StatusCard(
                              width: itemWidth,
                              icon: Icons.people_alt_rounded,
                              label: 'Clientes',
                              value: _text(controller.metrics.value['customers'] ?? controller.metrics.value['totalCustomers']),
                              helper: 'Base cadastrada',
                              accent: const Color(0xFF7C3AED),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Ações rápidas',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: -.3),
                    ),
                    const SizedBox(height: 13),
                    LayoutBuilder(
                      builder: (context, c) {
                        final compact = c.maxWidth < 760;
                        final cards = [
                          _QuickAction(
                            icon: Icons.calendar_month_rounded,
                            title: 'Abrir agenda',
                            subtitle: 'Veja os horários e agendamentos do dia',
                            onTap: () => context.go(RoutePaths.adminCalendar),
                          ),
                          _QuickAction(
                            icon: Icons.local_car_wash_rounded,
                            title: 'Atendimentos',
                            subtitle: 'Veja quem está lavando e quem está pronto',
                            onTap: () => context.go(RoutePaths.adminOperation),
                          ),
                          _QuickAction(
                            icon: Icons.people_alt_rounded,
                            title: 'Clientes',
                            subtitle: 'Consulte rapidamente a base cadastrada',
                            onTap: () => context.go(RoutePaths.adminCustomers),
                          ),
                        ];
                        if (compact) {
                          return Column(
                            children: cards
                                .map((e) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: e,
                                    ))
                                .toList(),
                          );
                        }
                        return Row(children: [
                          for (int i = 0; i < cards.length; i++) ...[
                            Expanded(child: cards[i]),
                            if (i < cards.length - 1) const SizedBox(width: 14),
                          ],
                        ]);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  String _text(dynamic value) => value == null ? '0' : value.toString();
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({required this.companyName, required this.onRefresh});
  final String companyName;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B0F14), Color(0xFF151B24)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [BoxShadow(color: Color(0x160F172A), blurRadius: 34, offset: Offset(0, 14))],
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFF6A00), shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Text(
                companyName.toUpperCase(),
                style: const TextStyle(color: Color(0xFFFF9B54), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.1),
              ),
            ]),
            const SizedBox(height: 13),
            const Text(
              'Visão de hoje',
              style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1),
            ),
            const SizedBox(height: 6),
            const Text(
              'Só o que você precisa para tocar a operação agora.',
              style: TextStyle(color: Color(0xFF9BA7B7), fontSize: 14.5),
            ),
          ]),
        ),
        IconButton(
          tooltip: 'Atualizar',
          onPressed: onRefresh,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(.07),
            foregroundColor: Colors.white,
            minimumSize: const Size(46, 46),
          ),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ]),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.helper,
    required this.accent,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final String helper;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE7EBF0)),
          boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 24, offset: Offset(0, 10))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withOpacity(.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: accent, size: 21),
            ),
            const Spacer(),
            Container(width: 7, height: 7, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
          ]),
          const SizedBox(height: 18),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -.8)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: Color(0xFF344054), fontWeight: FontWeight.w800, fontSize: 12.5)),
          const SizedBox(height: 3),
          Text(helper, style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 11.5)),
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
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(19),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE7EBF0)),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Row(children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1E8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFFFF6A00), size: 22),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF667085), fontSize: 12, height: 1.3)),
                ]),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF98A2B3)),
            ]),
          ),
        ),
      );
}
