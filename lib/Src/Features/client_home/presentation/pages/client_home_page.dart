import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 42),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroCard(onBook: () => context.go(RoutePaths.clientBooking)),
              const SizedBox(height: 24),
              _SectionTitle(
                eyebrow: 'ACESSO RÁPIDO',
                title: 'O que você precisa hoje?',
                subtitle: 'Tudo organizado em poucos passos, sem informação desnecessária.',
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 760;
                  final cards = [
                    _ActionCard(
                      icon: Icons.calendar_month_rounded,
                      title: 'Agendar lavagem',
                      text: 'Escolha o veículo, serviço, data e horário disponível.',
                      action: 'Agendar agora',
                      primary: true,
                      onTap: () => context.go(RoutePaths.clientBooking),
                    ),
                    _ActionCard(
                      icon: Icons.event_note_rounded,
                      title: 'Meus agendamentos',
                      text: 'Acompanhe seus próximos horários e o andamento do atendimento.',
                      action: 'Ver agendamentos',
                      accent: const Color(0xFF2563EB),
                      onTap: () => context.go(RoutePaths.clientAppointments),
                    ),
                    _ActionCard(
                      icon: Icons.workspace_premium_rounded,
                      title: 'Meu plano',
                      text: 'Veja sua assinatura, benefícios e serviços incluídos.',
                      action: 'Ver meu plano',
                      accent: const Color(0xFF7C3AED),
                      onTap: () => context.go(RoutePaths.clientPlans),
                    ),
                    _ActionCard(
                      icon: Icons.person_rounded,
                      title: 'Perfil',
                      text: 'Mantenha seus dados atualizados e sua conta organizada.',
                      action: 'Abrir perfil',
                      accent: const Color(0xFF0F766E),
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
                      childAspectRatio: 2.08,
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
              const SizedBox(height: 20),
              const _InfoStrip(),
            ],
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
          colors: [Color(0xFF0B0F14), Color(0xFF171E28), Color(0xFF2B170B)],
          stops: [0, .58, 1],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF334155).withOpacity(.55)),
        boxShadow: const [
          BoxShadow(color: Color(0x250F172A), blurRadius: 36, offset: Offset(0, 16)),
          BoxShadow(color: Color(0x16FF6A00), blurRadius: 36, offset: Offset(12, 10)),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 690;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.06),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(.08)),
                ),
                child: const Text(
                  'MALTA WASH',
                  style: TextStyle(color: Color(0xFFFF9A52), fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Seu carro limpo\nsem complicação.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: wide ? 34 : 29,
                  fontWeight: FontWeight.w900,
                  height: 1.03,
                  letterSpacing: -.9,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Agende em poucos passos e acompanhe tudo pelo sistema até o veículo ficar pronto.',
                style: TextStyle(color: Colors.white.withOpacity(.67), height: 1.5, fontSize: 14.5),
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
              minimumSize: const Size(0, 54),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          );

          if (wide) {
            return Row(children: [
              Expanded(child: copy),
              const SizedBox(width: 34),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.055),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: Colors.white.withOpacity(.08)),
                    ),
                    child: const Icon(Icons.local_car_wash_rounded, size: 43, color: Color(0xFFFF8A34)),
                  ),
                  const SizedBox(height: 18),
                  button,
                ],
              ),
            ]);
          }

          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            copy,
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: button),
          ]);
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.eyebrow, required this.title, required this.subtitle});
  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow, style: const TextStyle(color: Color(0xFFFF6A00), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -.45)),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: Color(0xFF667085), fontSize: 13.5, height: 1.45)),
      ],
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
    this.accent = const Color(0xFFFF6A00),
  });

  final IconData icon;
  final String title;
  final String text;
  final String action;
  final VoidCallback onTap;
  final bool primary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withOpacity(.96), Colors.white.withOpacity(.84)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: primary ? const Color(0xFFFFC59B) : const Color(0xFFDDE3EA)),
            boxShadow: const [BoxShadow(color: Color(0x0E0F172A), blurRadius: 24, offset: Offset(0, 10))],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: primary ? const Color(0xFFFF6A00) : accent.withOpacity(.10),
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: primary ? const [BoxShadow(color: Color(0x33FF6A00), blurRadius: 16, offset: Offset(0, 7))] : null,
                ),
                child: Icon(icon, color: primary ? Colors.white : accent, size: 26),
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
                    Text(action, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: primary ? const Color(0xFFFF6A00) : accent)),
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

class _InfoStrip extends StatelessWidget {
  const _InfoStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334155).withOpacity(.55)),
      ),
      child: const Row(children: [
        Icon(Icons.auto_awesome_rounded, color: Color(0xFFFF8A34), size: 20),
        SizedBox(width: 11),
        Expanded(
          child: Text(
            'Malta Wash organiza seu agendamento, veículo e plano em uma experiência simples e rápida.',
            style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12.5, height: 1.4),
          ),
        ),
      ]),
    );
  }
}
