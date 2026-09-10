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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 700;
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(mobile ? 16 : 28, 14, mobile ? 16 : 28, 28),
                    child: Column(
                      children: [
                        _Header(mobile: mobile),
                        SizedBox(height: mobile ? 22 : 52),
                        _Hero(mobile: mobile),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.mobile});
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    if (mobile) {
      return Row(
        children: [
          const BrandLogo(size: 40),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Malta Wash',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            color: const Color(0xFF11161D),
            onSelected: (value) => context.go('${RoutePaths.login}?area=$value'),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'cliente', child: Text('Entrar como cliente', style: TextStyle(color: Colors.white))),
              PopupMenuItem(value: 'empresa', child: Text('Entrar como empresa', style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        const BrandLogo(size: 46),
        const SizedBox(width: 12),
        const Expanded(child: Text('Malta Wash', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900))),
        TextButton(onPressed: () => context.go('${RoutePaths.login}?area=cliente'), child: const Text('Entrar como cliente')),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () => context.go('${RoutePaths.login}?area=empresa'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24)),
          child: const Text('Entrar como empresa'),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.mobile});
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(color: Colors.white.withOpacity(.05), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withOpacity(.08))),
          child: const Text('MALTA WASH', style: TextStyle(color: Color(0xFFFF8A38), fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
        ),
        const SizedBox(height: 18),
        Text(
          'Agende. Acompanhe.\nPronto.',
          style: TextStyle(color: Colors.white, fontSize: mobile ? 38 : 58, height: 1.02, fontWeight: FontWeight.w900, letterSpacing: mobile ? -1.2 : -2),
        ),
        const SizedBox(height: 16),
        Text(
          'Uma experiência simples para o cliente e uma operação direta para a empresa.',
          style: TextStyle(color: Colors.white.withOpacity(.62), fontSize: mobile ? 15 : 17, height: 1.5),
        ),
        const SizedBox(height: 24),
        if (mobile)
          Column(
            children: [
              SizedBox(width: double.infinity, child: _ClientButton()),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: _CompanyButton()),
            ],
          )
        else
          Wrap(spacing: 12, runSpacing: 12, children: const [_ClientButton(), _CompanyButton()]),
      ],
    );

    final scene = const _CarWashScene();

    if (mobile) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [scene, const SizedBox(height: 28), copy]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 9, child: copy),
        const SizedBox(width: 54),
        const Expanded(flex: 11, child: _CarWashScene()),
      ],
    );
  }
}

class _ClientButton extends StatelessWidget {
  const _ClientButton();
  @override
  Widget build(BuildContext context) => FilledButton.icon(
        onPressed: () => context.go('${RoutePaths.login}?area=cliente'),
        icon: const Icon(Icons.person_rounded),
        label: const Text('Entrar como cliente'),
        style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6A00), foregroundColor: Colors.white, minimumSize: const Size(0, 52)),
      );
}

class _CompanyButton extends StatelessWidget {
  const _CompanyButton();
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: () => context.go('${RoutePaths.login}?area=empresa'),
        icon: const Icon(Icons.storefront_rounded),
        label: const Text('Entrar como empresa'),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24), minimumSize: const Size(0, 52)),
      );
}

class _CarWashScene extends StatefulWidget {
  const _CarWashScene();
  @override
  State<_CarWashScene> createState() => _CarWashSceneState();
}

class _CarWashSceneState extends State<_CarWashScene> with SingleTickerProviderStateMixin {
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
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final compact = w < 500;
      final sceneHeight = compact ? 230.0 : 330.0;
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final enter = _segment(t, 0, .22);
          final exit = _segment(t, .68, .94);
          final pulse = t >= .24 && t <= .70 ? math.sin((t - .24) * math.pi * 13).abs() : 0.0;
          final travel = enter * .54 + exit * .48;
          final carWidth = compact ? 126.0 : 170.0;
          final left = -carWidth + travel * (w + carWidth + 18);

          return Container(
            height: sceneHeight,
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF111820), Color(0xFF0B1016), Color(0xFF21140C)]),
              borderRadius: BorderRadius.circular(compact ? 24 : 32),
              border: Border.all(color: Colors.white.withOpacity(.08)),
              boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 42, offset: Offset(0, 20))],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _GridPainter())),
                Positioned(top: 18, left: 18, child: _Status(active: t < .23, label: 'CHEGANDO', color: const Color(0xFF2563EB))),
                Positioned(top: 54, left: 18, child: _Status(active: t >= .23 && t < .70, label: 'LAVANDO', color: const Color(0xFFFF6A00))),
                Positioned(top: 90, left: 18, child: _Status(active: t >= .70, label: 'PRONTO', color: const Color(0xFF22C55E))),
                Positioned(
                  left: compact ? w * .31 : w * .30,
                  right: compact ? 18 : 34,
                  bottom: compact ? 48 : 70,
                  child: const _WashArch(),
                ),
                if (t >= .22 && t <= .72)
                  Positioned(left: w * .48, bottom: compact ? 106 : 145, child: _Bubble(size: 11 + pulse * 7)),
                Positioned(left: left, bottom: compact ? 34 : 52, child: Transform.scale(scale: compact ? .78 : 1, child: const _Car())),
              ],
            ),
          );
        },
      );
    });
  }
}

class _WashArch extends StatelessWidget {
  const _WashArch();
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 128,
        child: Stack(children: [
          Positioned(left: 0, bottom: 0, child: Container(width: 11, height: 96, decoration: BoxDecoration(color: const Color(0xFF2A3440), borderRadius: BorderRadius.circular(10)))),
          Positioned(right: 0, bottom: 0, child: Container(width: 11, height: 96, decoration: BoxDecoration(color: const Color(0xFF2A3440), borderRadius: BorderRadius.circular(10)))),
          Positioned(left: 0, right: 0, top: 5, child: Container(height: 12, decoration: BoxDecoration(color: const Color(0xFF2A3440), borderRadius: BorderRadius.circular(10)))),
          const Positioned(left: 40, top: 25, child: _Spray()),
          const Positioned(left: 95, top: 25, child: _Spray()),
          const Positioned(right: 40, top: 25, child: _Spray()),
        ]),
      );
}

class _Spray extends StatelessWidget {
  const _Spray();
  @override
  Widget build(BuildContext context) => Column(children: [
        Container(width: 7, height: 14, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(8))),
        Container(width: 2, height: 42, color: const Color(0x887CC7FF)),
      ]);
}

class _Car extends StatelessWidget {
  const _Car();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 170,
        height: 76,
        child: Stack(children: [
          Positioned(left: 15, right: 0, bottom: 12, child: Container(height: 42, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6A00), Color(0xFFFF8A38)]), borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Color(0x55FF6A00), blurRadius: 18, offset: Offset(0, 7))]))),
          Positioned(left: 52, bottom: 44, child: Container(width: 76, height: 26, decoration: const BoxDecoration(color: Color(0xFF233044), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(24))))),
          Positioned(left: 63, bottom: 47, child: Container(width: 26, height: 18, decoration: BoxDecoration(color: const Color(0xFF79B8FF).withOpacity(.65), borderRadius: BorderRadius.circular(7)))),
          Positioned(left: 94, bottom: 47, child: Container(width: 25, height: 18, decoration: BoxDecoration(color: const Color(0xFF79B8FF).withOpacity(.45), borderRadius: BorderRadius.circular(7)))),
          const Positioned(left: 35, bottom: 3, child: _Wheel()),
          const Positioned(right: 25, bottom: 3, child: _Wheel()),
        ]),
      );
}

class _Wheel extends StatelessWidget {
  const _Wheel();
  @override
  Widget build(BuildContext context) => Container(width: 25, height: 25, decoration: BoxDecoration(color: const Color(0xFF080B10), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF3A4657), width: 4)));
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
        decoration: BoxDecoration(color: active ? color.withOpacity(.16) : Colors.white.withOpacity(.03), borderRadius: BorderRadius.circular(10), border: Border.all(color: active ? color.withOpacity(.55) : Colors.white.withOpacity(.05))),
        child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.white30, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .8)),
      );
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.65), border: Border.all(color: const Color(0xFF9ED5FF).withOpacity(.6))));
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF94A3B8).withOpacity(.06)..strokeWidth = .6;
    const gap = 28.0;
    for (double x = 0; x < size.width; x += gap) canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += gap) canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
