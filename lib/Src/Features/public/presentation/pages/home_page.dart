import 'dart:math' as math;

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
            children: const [
              _Header(),
              _Hero(),
              _AccessSection(),
              _Footer(),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 720;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mobile ? 18 : 24, vertical: mobile ? 14 : 18),
              child: Row(
                children: [
                  const BrandLogo(size: 42),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Malta Wash',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900),
                    ),
                  ),
                  if (!mobile) ...[
                    TextButton(
                      onPressed: () => context.go('${RoutePaths.login}?area=cliente'),
                      child: const Text('Entrar como cliente'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => context.go('${RoutePaths.login}?area=empresa'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                      ),
                      child: const Text('Entrar como empresa'),
                    ),
                  ] else
                    PopupMenuButton<String>(
                      tooltip: 'Acessar',
                      color: const Color(0xFF151A21),
                      icon: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.06),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: Colors.white.withOpacity(.08)),
                        ),
                        child: const Icon(Icons.menu_rounded, color: Colors.white),
                      ),
                      onSelected: (value) {
                        context.go('${RoutePaths.login}?area=$value');
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'cliente', child: Text('Entrar como cliente', style: TextStyle(color: Colors.white))),
                        PopupMenuItem(value: 'empresa', child: Text('Entrar como empresa', style: TextStyle(color: Colors.white))),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final mobile = constraints.maxWidth < 600;
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
                  SizedBox(height: mobile ? 20 : 24),
                  Text(
                    'Agende. Acompanhe.\nPronto.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: wide ? 60 : mobile ? 44 : 50,
                      height: 1.02,
                      fontWeight: FontWeight.w900,
                      letterSpacing: wide ? -2.1 : -1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Uma experiência simples para clientes e uma operação direta para a empresa.',
                    style: TextStyle(color: Colors.white.withOpacity(.64), fontSize: mobile ? 16 : 18, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  if (mobile)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.icon(
                          onPressed: () => context.go('${RoutePaths.login}?area=cliente'),
                          icon: const Icon(Icons.person_rounded),
                          label: const Text('Entrar como cliente'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6A00),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52),
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => context.go('${RoutePaths.login}?area=empresa'),
                          icon: const Icon(Icons.storefront_rounded),
                          label: const Text('Entrar como empresa'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            minimumSize: const Size.fromHeight(52),
                          ),
                        ),
                      ],
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: () => context.go('${RoutePaths.login}?area=cliente'),
                          icon: const Icon(Icons.person_rounded),
                          label: const Text('Entrar como cliente'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6A00),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 52),
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go('${RoutePaths.login}?area=empresa'),
                          icon: const Icon(Icons.storefront_rounded),
                          label: const Text('Entrar como empresa'),
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

              final visual = const _HomeCarWashScene();
              final padding = EdgeInsets.fromLTRB(mobile ? 18 : 24, mobile ? 48 : 76, mobile ? 18 : 24, mobile ? 58 : 88);

              if (wide) {
                return Padding(
                  padding: padding,
                  child: Row(
                    children: [
                      Expanded(flex: 11, child: copy),
                      const SizedBox(width: 58),
                      Expanded(flex: 9, child: visual),
                    ],
                  ),
                );
              }

              return Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    copy,
                    SizedBox(height: mobile ? 34 : 42),
                    visual,
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeCarWashScene extends StatefulWidget {
  const _HomeCarWashScene();

  @override
  State<_HomeCarWashScene> createState() => _HomeCarWashSceneState();
}

class _HomeCarWashSceneState extends State<_HomeCarWashScene> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _segment(double t, double start, double end) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    return Curves.easeInOutCubic.transform((t - start) / (end - start));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final enter = _segment(t, 0, .22);
        final exit = _segment(t, .68, .94);
        final pulse = t >= .24 && t <= .70 ? math.sin((t - .24) * math.pi * 13).abs() : 0.0;
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final sceneHeight = width < 430 ? 210.0 : 260.0;
            final carWidth = width < 430 ? 138.0 : 170.0;
            final travel = math.max(250.0, width - carWidth + 70);
            final carX = -carWidth + (enter * .56 + exit * .48) * travel;

            return Container(
              height: sceneHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF11161D),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(.08)),
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 48, offset: Offset(0, 20))],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  const Positioned.fill(child: CustomPaint(painter: _SceneGridPainter())),
                  Positioned(top: 18, left: 18, child: _StatusPill(active: t < .23, label: 'CHEGANDO', color: Color(0xFF2563EB))),
                  Positioned(top: 52, left: 18, child: _StatusPill(active: t >= .23 && t < .70, label: 'LAVANDO', color: Color(0xFFFF6A00))),
                  Positioned(top: 86, left: 18, child: _StatusPill(active: t >= .70, label: 'PRONTO', color: Color(0xFF22C55E))),
                  Positioned(
                    left: width * .33,
                    right: width * .12,
                    bottom: 36,
                    child: Container(height: 2, color: Colors.white.withOpacity(.08)),
                  ),
                  Positioned(
                    left: width * .36,
                    bottom: 48,
                    child: Opacity(opacity: t >= .20 && t <= .72 ? .92 : .30, child: _WashArch(scale: width < 430 ? .72 : 1)),
                  ),
                  if (t >= .20 && t <= .72) ...[
                    Positioned(left: width * .50, bottom: 75, child: _Bubble(size: 8 + pulse * 4)),
                    Positioned(left: width * .59, bottom: 104, child: _Bubble(size: 7 + pulse * 3)),
                    Positioned(left: width * .69, bottom: 82, child: _Bubble(size: 10 + pulse * 4)),
                  ],
                  Positioned(
                    left: carX,
                    bottom: 31,
                    child: Transform.scale(
                      scale: (width < 430 ? .80 : 1) + pulse * .02,
                      alignment: Alignment.bottomLeft,
                      child: const _Car(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Car extends StatelessWidget {
  const _Car();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 76,
      child: Stack(
        children: [
          Positioned(left: 15, right: 0, bottom: 12, child: Container(height: 42, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6A00), Color(0xFFFF8A38)]), borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Color(0x55FF6A00), blurRadius: 18, offset: Offset(0, 7))]))),
          Positioned(left: 52, bottom: 44, child: Container(width: 76, height: 26, decoration: const BoxDecoration(color: Color(0xFF233044), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(24))))),
          Positioned(left: 63, bottom: 47, child: Container(width: 26, height: 18, decoration: BoxDecoration(color: const Color(0xFF79B8FF).withOpacity(.65), borderRadius: BorderRadius.circular(7)))),
          Positioned(left: 94, bottom: 47, child: Container(width: 25, height: 18, decoration: BoxDecoration(color: const Color(0xFF79B8FF).withOpacity(.45), borderRadius: BorderRadius.circular(7)))),
          const Positioned(left: 35, bottom: 3, child: _Wheel()),
          const Positioned(right: 25, bottom: 3, child: _Wheel()),
          Positioned(right: 8, bottom: 28, child: Container(width: 13, height: 7, decoration: BoxDecoration(color: const Color(0xFFFFD166), borderRadius: BorderRadius.circular(8)))),
        ],
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel();
  @override
  Widget build(BuildContext context) => Container(width: 25, height: 25, decoration: BoxDecoration(color: const Color(0xFF080B10), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF3A4657), width: 4)));
}

class _WashArch extends StatelessWidget {
  const _WashArch({required this.scale});
  final double scale;
  @override
  Widget build(BuildContext context) => Transform.scale(
        scale: scale,
        alignment: Alignment.bottomLeft,
        child: SizedBox(
          width: 250,
          height: 128,
          child: Stack(children: [
            Positioned(left: 0, bottom: 0, child: Container(width: 12, height: 98, decoration: BoxDecoration(color: const Color(0xFF27303B), borderRadius: BorderRadius.circular(999)))),
            Positioned(right: 0, bottom: 0, child: Container(width: 12, height: 98, decoration: BoxDecoration(color: const Color(0xFF27303B), borderRadius: BorderRadius.circular(999)))),
            Positioned(left: 0, right: 0, top: 4, child: Container(height: 13, decoration: BoxDecoration(color: const Color(0xFF27303B), borderRadius: BorderRadius.circular(999)))),
            const Positioned(left: 55, top: 26, child: _Spray()),
            const Positioned(left: 115, top: 26, child: _Spray()),
            const Positioned(left: 175, top: 26, child: _Spray()),
          ]),
        ),
      );
}

class _Spray extends StatelessWidget {
  const _Spray();
  @override
  Widget build(BuildContext context) => Column(children: [
        Container(width: 7, height: 16, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(999))),
        const SizedBox(height: 2),
        Container(width: 2, height: 40, decoration: BoxDecoration(color: const Color(0xFF67B7FF).withOpacity(.55), borderRadius: BorderRadius.circular(999))),
      ]);
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.72), border: Border.all(color: const Color(0xFF9ED5FF).withOpacity(.45))));
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.active, required this.label, required this.color});
  final bool active;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(color: active ? color.withOpacity(.16) : Colors.white.withOpacity(.025), borderRadius: BorderRadius.circular(9), border: Border.all(color: active ? color.withOpacity(.5) : Colors.white.withOpacity(.05))),
        child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .7)),
      );
}

class _SceneGridPainter extends CustomPainter {
  const _SceneGridPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF334155).withOpacity(.15)..strokeWidth = .6;
    const gap = 26.0;
    for (double x = 0; x < size.width; x += gap) canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += gap) canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
            padding: const EdgeInsets.fromLTRB(18, 56, 18, 64),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 780;
                final client = _AccessCard(icon: Icons.person_rounded, title: 'Cliente', description: 'Entre para agendar uma lavagem, acompanhar seu veículo e consultar seu plano.', button: 'Entrar como cliente', onTap: () => context.go('${RoutePaths.login}?area=cliente'));
                final company = _AccessCard(icon: Icons.storefront_rounded, title: 'Empresa', description: 'Entre no painel para administrar agenda, clientes, veículos, serviços e planos.', button: 'Entrar como empresa', onTap: () => context.go('${RoutePaths.login}?area=empresa'), dark: true);
                if (wide) return Row(children: [Expanded(child: client), const SizedBox(width: 18), Expanded(child: company)]);
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
  const _AccessCard({required this.icon, required this.title, required this.description, required this.button, required this.onTap, this.dark = false});
  final IconData icon;
  final String title;
  final String description;
  final String button;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: dark ? const Color(0xFF11161D) : Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: dark ? const Color(0xFF2C333D) : const Color(0xFFE5E8ED))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFFFF6A00).withOpacity(.12), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: const Color(0xFFFF6A00))),
        const SizedBox(height: 20),
        Text(title, style: TextStyle(color: dark ? Colors.white : const Color(0xFF111827), fontSize: 23, fontWeight: FontWeight.w900)),
        const SizedBox(height: 9),
        Text(description, style: TextStyle(color: dark ? Colors.white60 : const Color(0xFF667085), height: 1.5)),
        const SizedBox(height: 22),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: onTap, style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6A00), foregroundColor: Colors.white), child: Text(button))),
      ]),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, color: const Color(0xFF090C10), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28), child: const Center(child: Text('Malta Wash', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w700))));
}
