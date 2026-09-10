import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Shared/widgets/brand_logo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C10),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _Header(),
              const _Hero(),
              const _AccessSection(),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

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
                child: Text(
                  'Malta Wash',
                  style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
                ),
              ),
              TextButton(
                onPressed: () => context.go('${RoutePaths.login}?area=cliente'),
                child: const Text('Cliente'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => context.go('${RoutePaths.login}?area=empresa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                ),
                child: const Text('Empresa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(.62, -.12),
          radius: 1.15,
          colors: [Color(0x332563EB), Color(0x222F1300), Color(0x00090C10)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 86, 24, 96),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                final copy = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.05),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withOpacity(.08)),
                      ),
                      child: const Text(
                        'MALTA WASH',
                        style: TextStyle(color: Color(0xFFFF8A38), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Agende. Acompanhe.\nPronto.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: wide ? 60 : 42,
                        height: 1.02,
                        fontWeight: FontWeight.w900,
                        letterSpacing: wide ? -2.1 : -1.2,
                      ),
                    ),
                    const SizedBox(height: 22),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Text(
                        'Uma experiência simples para clientes e uma operação direta para a empresa.',
                        style: TextStyle(color: Colors.white.withOpacity(.64), fontSize: 18, height: 1.55),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: () => context.go('${RoutePaths.login}?area=cliente'),
                          icon: const Icon(Icons.calendar_month_rounded),
                          label: const Text('Agendar lavagem'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6A00),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 52),
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go(RoutePaths.companyRegister),
                          icon: const Icon(Icons.storefront_rounded),
                          label: const Text('Cadastrar empresa'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            minimumSize: const Size(0, 52),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                );

                final visual = Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: const Color(0xFF11161D),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: Colors.white.withOpacity(.08)),
                    boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 60, offset: Offset(0, 24))],
                  ),
                  child: const Column(
                    children: [
                      BrandLogo(size: 148),
                      SizedBox(height: 22),
                      Text('Malta Wash', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                      SizedBox(height: 8),
                      Text('Seu agendamento e sua operação em um só lugar.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, height: 1.45)),
                    ],
                  ),
                );

                if (wide) {
                  return Row(
                    children: [
                      Expanded(flex: 12, child: copy),
                      const SizedBox(width: 72),
                      Expanded(flex: 8, child: visual),
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

class _AccessSection extends StatelessWidget {
  const _AccessSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF4F6F8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 72, 24, 80),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 780;
                final client = _AccessCard(
                  icon: Icons.person_rounded,
                  title: 'Cliente',
                  description: 'Agende uma lavagem, acompanhe seu veículo, veja seu plano e gerencie seu perfil.',
                  button: 'Entrar como cliente',
                  onTap: () => context.go('${RoutePaths.login}?area=cliente'),
                );
                final company = _AccessCard(
                  icon: Icons.storefront_rounded,
                  title: 'Empresa',
                  description: 'Acompanhe agenda, atendimentos, clientes e veículos sem complicação.',
                  button: 'Entrar como empresa',
                  onTap: () => context.go('${RoutePaths.login}?area=empresa'),
                  dark: true,
                );
                if (wide) {
                  return Row(children: [Expanded(child: client), const SizedBox(width: 18), Expanded(child: company)]);
                }
                return Column(children: [client, const SizedBox(height: 16), company]);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.button,
    required this.onTap,
    this.dark = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final String button;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF11161D) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: dark ? const Color(0xFF2C333D) : const Color(0xFFE5E8ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: const Color(0xFFFF6A00).withOpacity(.12), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: const Color(0xFFFF6A00)),
          ),
          const SizedBox(height: 22),
          Text(title, style: TextStyle(color: dark ? Colors.white : const Color(0xFF111827), fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Text(description, style: TextStyle(color: dark ? Colors.white60 : const Color(0xFF667085), height: 1.5)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6A00), foregroundColor: Colors.white),
            child: Text(button),
          ),
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
        child: Text('Malta Wash', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
