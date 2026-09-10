import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Features/public/presentation/pages/home_page.dart' as desktop_home;
import 'package:malta_wash/Src/Shared/widgets/brand_logo.dart';

class ResponsiveHomePage extends StatelessWidget {
  const ResponsiveHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 720) {
          return const desktop_home.HomePage();
        }
        return const _MobileHome();
      },
    );
  }
}

class _MobileHome extends StatelessWidget {
  const _MobileHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C10),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  BrandLogo(size: 42),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Malta Wash',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 42),
              Container(
                alignment: Alignment.centerLeft,
                child: Container(
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
              ),
              const SizedBox(height: 20),
              const Text(
                'Agende.\nAcompanhe.\nPronto.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  height: .98,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.7,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Uma experiência simples para clientes e uma operação direta para a empresa.',
                style: TextStyle(color: Colors.white.withOpacity(.62), fontSize: 16, height: 1.48),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => context.go('${RoutePaths.login}?area=cliente'),
                icon: const Icon(Icons.person_rounded),
                label: const Text('Entrar como cliente'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6A00),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 11),
              OutlinedButton.icon(
                onPressed: () => context.go('${RoutePaths.login}?area=empresa'),
                icon: const Icon(Icons.storefront_rounded),
                label: const Text('Entrar como empresa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 34),
              const _MobileCarWashScene(),
              const SizedBox(height: 28),
              const Center(
                child: Text('Malta Wash', style: TextStyle(color: Colors.white30, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileCarWashScene extends StatefulWidget {
  const _MobileCarWashScene();

  @override
  State<_MobileCarWashScene> createState() => _MobileCarWashSceneState();
}

class _MobileCarWashSceneState extends State<_MobileCarWashScene> with SingleTickerProviderStateMixin {
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
            final travel = math.max(240.0, width + 80);
            final carX = -120 + (enter * .56 + exit * .48) * travel;

            return Container(
              height: 205,
              decoration: BoxDecoration(
                color: const Color(0xFF11161D),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withOpacity(.08)),
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 38, offset: Offset(0, 16))],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  const Positioned.fill(child: CustomPaint(painter: _GridPainter())),
                  Positioned(top: 16, left: 16, child: _Status(active: t < .23, label: 'CHEGANDO', color: const Color(0xFF2563EB))),
                  Positioned(top: 47, left: 16, child: _Status(active: t >= .23 && t < .70, label: 'LAVANDO', color: const Color(0xFFFF6A00))),
                  Positioned(top: 78, left: 16, child: _Status(active: t >= .70, label: 'PRONTO', color: const Color(0xFF22C55E))),
                  Positioned(
                    left: width * .42,
                    bottom: 41,
                    child: Opacity(
                      opacity: t >= .20 && t <= .72 ? .95 : .30,
                      child: const _WashArch(),
                    ),
                  ),
                  if (t >= .20 && t <= .72) ...[
                    Positioned(left: width * .57, bottom: 73, child: _Bubble(size: 8 + pulse * 4)),
                    Positioned(left: width * .68, bottom: 96, child: _Bubble(size: 6 + pulse * 3)),
                    Positioned(left: width * .77, bottom: 78, child: _Bubble(size: 9 + pulse * 4)),
                  ],
                  Positioned(
                    left: carX,
                    bottom: 28,
                    child: Transform.scale(
                      scale: .72 + pulse * .02,
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
  const _WashArch();
  @override
  Widget build(BuildContext context) => Transform.scale(
        scale: .66,
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

class _Status extends StatelessWidget {
  const _Status({required this.active, required this.label, required this.color});
  final bool active;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(.16) : Colors.white.withOpacity(.025),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: active ? color.withOpacity(.5) : Colors.white.withOpacity(.05)),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .7)),
      );
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF334155).withOpacity(.15)..strokeWidth = .6;
    const gap = 25.0;
    for (double x = 0; x < size.width; x += gap) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += gap) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
