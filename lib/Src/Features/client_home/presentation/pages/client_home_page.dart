import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Shared/widgets/page_header.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const PageHeader(title: 'Olá 👋', subtitle: 'Gerencie seus veículos e próximos atendimentos.'),
          const SizedBox(height: 24),
          Wrap(spacing: 16, runSpacing: 16, children: [
            _ActionCard(icon: Icons.calendar_month_outlined, title: 'Agendar lavagem', text: 'Escolha unidade, veículo, serviço, data e horário.', onTap: () => context.go(RoutePaths.clientBooking)),
            _ActionCard(icon: Icons.directions_car_outlined, title: 'Meus veículos', text: 'Cadastre e mantenha seus veículos atualizados.', onTap: () => context.go(RoutePaths.clientVehicles)),
            _ActionCard(icon: Icons.workspace_premium_outlined, title: 'Planos', text: 'Consulte assinaturas, franquias e benefícios.', onTap: () => context.go(RoutePaths.clientPlans)),
            _ActionCard(icon: Icons.event_note_outlined, title: 'Agendamentos', text: 'Acompanhe próximos, concluídos e cancelados.', onTap: () => context.go(RoutePaths.clientAppointments)),
          ]),
        ]),
      );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.title, required this.text, required this.onTap});
  final IconData icon;
  final String title;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 330,
    child: Card(child: InkWell(borderRadius: BorderRadius.circular(18), onTap: onTap, child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 34, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 16),
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text(text),
    ])))),
  );
}
