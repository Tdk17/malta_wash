import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroCard(onBook: () => context.go(RoutePaths.clientBooking)),
                const SizedBox(height: 26),
                const Text(
                  'O que você precisa?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 760;
                    final cards = [
                      _ActionCard(
                        icon: Icons.calendar_month_rounded,
                        title: 'Agendar lavagem',
                        text: 'Escolha o veículo, o serviço, a data e o horário.',
                        action: 'Agendar agora',
                        primary: true,
                        onTap: () => context.go(RoutePaths.clientBooking),
                      ),
                      _ActionCard(
                        icon: Icons.event_note_rounded,
                        title: 'Meus agendamentos',
                        text: 'Veja o próximo atendimento e acompanhe quando seu veículo estiver pronto.',
                        action: 'Ver agendamentos',
                        onTap: () => context.go(RoutePaths.clientAppointments),
                      ),
                      _ActionCard(
                        icon: Icons.workspace_premium_rounded,
                        title: 'Meu plano',
                        text: 'Consulte seu plano de assinatura e os serviços incluídos.',
                        action: 'Ver meu plano',
                        onTap: () => context.go(RoutePaths.clientPlans),
                      ),
                      _ActionCard(
                        icon: Icons.person_rounded,
                        title: 'Perfil',
                        text: 'Ajuste seus dados pessoais e informações da conta.',
                        action: 'Abrir perfil',
                        onTap: () => context.go(RoutePaths.clientProfile),
                      ),
                    ];
                    if (wide) {
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.15,
                        children: cards,
                      );
                    }
                    return Column(
                      children: cards
                          .map((card) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: card,
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onBook});
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF121820), Color(0xFF26160B)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [BoxShadow(color: Color(0x16000000), blurRadius: 32, offset: Offset(0, 14))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 690;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CLINICAR',
                style: TextStyle(color: Color(0xFFFF9A52), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.1),
              ),
              const SizedBox(height: 10),
              Text(
                'Seu carro limpo sem complicação.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: wide ? 32 : 27,
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                  letterSpacing: -.7,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Agende em poucos passos e acompanhe pelo sistema até receber o aviso de que ficou pronto.',
                style: TextStyle(color: Colors.white.withOpacity(.65), height: 1.5),
              ),
            ],
          );
          final button = FilledButton.icon(
            onPressed: onBook,
            icon: const Icon(Icons.calendar_month_rounded),
            label: const Text('Agendar lavagem'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6A00),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 52),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          );

          if (wide) {
            return Row(children: [
              Expanded(child: copy),
              const SizedBox(width: 34),
              button,
            ]);
          }
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            copy,
            const SizedBox(height: 22),
            SizedBox(width: double.infinity, child: button),
          ]);
        },
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.action,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String text;
  final String action;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primary ? const Color(0xFFFFC59B) : const Color(0xFFE6EAF0)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: primary ? const Color(0xFFFF6A00) : const Color(0xFFFFF2E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: primary ? Colors.white : const Color(0xFFFF6A00), size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    const SizedBox(height: 5),
                    Text(text, style: const TextStyle(fontSize: 12.5, height: 1.4, color: Color(0xFF667085))),
                    const SizedBox(height: 8),
                    Text(action, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFFFF6A00))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF98A2B3)),
            ],
          ),
        ),
      ),
    );
  }
}
