import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Shared/widgets/brand_logo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _orange = Color(0xFFFF6A00);
  static const _dark = Color(0xFF0B0F14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _Header(),
              _Hero(),
              _PortalSection(),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Row(
            children: [
              const BrandLogo(size: 46),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Clinicar', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    Text('powered by Malta Wash', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              if (MediaQuery.sizeOf(context).width >= 760) ...[
                TextButton.icon(
                  onPressed: () => context.go('${RoutePaths.login}?area=cliente'),
                  icon: const Icon(Icons.person_outline_rounded, size: 18),
                  label: const Text('Área do cliente'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                ),
                const SizedBox(width: 8),
              ],
              OutlinedButton.icon(
                onPressed: () => context.go('${RoutePaths.login}?area=empresa'),
                icon: const Icon(Icons.storefront_outlined, size: 18),
                label: Text(MediaQuery.sizeOf(context).width >= 620 ? 'Área da empresa' : 'Empresa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(.65, -.15),
          radius: 1.05,
          colors: [Color(0x332F1300), Color(0x000B0F14)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 72, 24, 86),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 920;
                final copy = _HeroCopy(wide: wide);
                final visual = const _HeroVisual();
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 12, child: copy),
                      const SizedBox(width: 70),
                      const Expanded(flex: 8, child: visual),
                    ],
                  );
                }
                return Column(children: [copy, const SizedBox(height: 44), visual]);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.06),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(.08)),
          ),
          child: const Text(
            'CLINICAR • EXPERIÊNCIA DIGITAL',
            style: TextStyle(color: Color(0xFFFFA15F), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Seu carro bem cuidado.\nSeu tempo respeitado.',
          style: TextStyle(
            color: Colors.white,
            fontSize: wide ? 58 : 42,
            fontWeight: FontWeight.w900,
            height: 1.02,
            letterSpacing: wide ? -2.1 : -1.3,
          ),
        ),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Text(
            'Agende sua lavagem, acompanhe o atendimento e concentre veículos, planos, pagamentos e benefícios em um único lugar.',
            style: TextStyle(color: Colors.white.withOpacity(.66), fontSize: 18, height: 1.55),
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.go('${RoutePaths.login}?area=cliente'),
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text('Agendar lavagem'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52), padding: const EdgeInsets.symmetric(horizontal: 22)),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('${RoutePaths.register}?tenant=clinicar'),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Criar conta de cliente'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                minimumSize: const Size(0, 52),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Wrap(
          spacing: 22,
          runSpacing: 12,
          children: [
            _TinyFeature(icon: Icons.schedule_rounded, text: 'Horários em tempo real'),
            _TinyFeature(icon: Icons.verified_user_outlined, text: 'Conta e histórico seguros'),
            _TinyFeature(icon: Icons.notifications_none_rounded, text: 'Acompanhamento do serviço'),
          ],
        ),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 450),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF141A22),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withOpacity(.08)),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 60, offset: Offset(0, 24))],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.04),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Column(
              children: [
                BrandLogo(size: 150),
                SizedBox(height: 22),
                Text('Clinicar', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text('Cuidado automotivo com experiência digital.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, height: 1.45)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(child: _MiniStat(icon: Icons.directions_car_filled_outlined, value: 'Veículos', label: 'Organizados')),
              SizedBox(width: 12),
              Expanded(child: _MiniStat(icon: Icons.calendar_today_outlined, value: 'Agenda', label: 'Online')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PortalSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF4F6F8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 72, 24, 78),
            child: Column(
              children: [
                const Text('Dois acessos. Um único ecossistema.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF111827), fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -.8)),
                const SizedBox(height: 10),
                const Text('Cliente e empresa possuem experiências separadas, com permissões e telas próprias.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6B7280), fontSize: 16)),
                const SizedBox(height: 34),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 820;
                    final client = _PortalCard(
                      icon: Icons.person_rounded,
                      overline: 'PORTAL DO CLIENTE',
                      title: 'Quero cuidar do meu carro',
                      description: 'Agendamentos, veículos, planos, pacotes, pagamentos, notificações e benefícios.',
                      actionLabel: 'Acessar como cliente',
                      onTap: () => context.go('${RoutePaths.login}?area=cliente'),
                    );
                    final company = _PortalCard(
                      icon: Icons.storefront_rounded,
                      overline: 'PAINEL DA EMPRESA',
                      title: 'Quero gerenciar a operação',
                      description: 'Dashboard, agenda, clientes, veículos, ordens de serviço, equipe, financeiro e relatórios.',
                      actionLabel: 'Acessar painel da empresa',
                      onTap: () => context.go('${RoutePaths.login}?area=empresa'),
                      highlighted: true,
                    );
                    if (wide) {
                      return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: client), const SizedBox(width: 20), Expanded(child: company)]);
                    }
                    return Column(children: [client, const SizedBox(height: 16), company]);
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

class _PortalCard extends StatelessWidget {
  const _PortalCard({
    required this.icon,
    required this.overline,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String overline;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFF11161D) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: highlighted ? const Color(0xFF2C333D) : const Color(0xFFE5E8ED)),
        boxShadow: const [BoxShadow(color: Color(0x100F172A), blurRadius: 30, offset: Offset(0, 14))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: const Color(0xFFFF6A00).withOpacity(.12), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.arrow_outward_rounded, color: Color(0xFFFF6A00)),
          ),
          const SizedBox(height: 22),
          Text(overline, style: const TextStyle(color: Color(0xFFFF6A00), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .9)),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: highlighted ? Colors.white : const Color(0xFF111827), fontSize: 24, fontWeight: FontWeight.w900, height: 1.12)),
          const SizedBox(height: 12),
          Text(description, style: TextStyle(color: highlighted ? Colors.white60 : const Color(0xFF6B7280), height: 1.5)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 19),
            label: Text(actionLabel),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6A00),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyFeature extends StatelessWidget {
  const _TinyFeature({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFFF8A38), size: 18),
        const SizedBox(width: 7),
        Text(text, style: const TextStyle(color: Colors.white54, fontSize: 12.5, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.04), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(.06))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFF8A38), size: 20),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF090C10),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: const Center(
        child: Text('Clinicar • Malta Wash — Gestão & Agendamento Automotivo', style: TextStyle(color: Colors.white38, fontSize: 12)),
      ),
    );
  }
}
