import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Shared/widgets/brand_logo.dart';

class MobileHomePage extends StatelessWidget {
  const MobileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C10),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Row(
                  children: [
                    BrandLogo(size: 44),
                    SizedBox(width: 12),
                    Text(
                      'Malta Wash',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 34, 20, 28),
                child: Column(
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
                        style: TextStyle(
                          color: Color(0xFFFF8A38),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Agende.\nAcompanhe.\nPronto.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        height: 1.02,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Uma experiência simples para clientes e uma operação direta para a empresa.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.64),
                        fontSize: 17,
                        height: 1.48,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => context.go('${RoutePaths.login}?area=cliente'),
                        icon: const Icon(Icons.person_rounded),
                        label: const Text('Entrar como cliente'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6A00),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('${RoutePaths.login}?area=empresa'),
                        icon: const Icon(Icons.storefront_rounded),
                        label: const Text('Entrar como empresa'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 38),
                    const _MobileCarWashScene(),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 26),
                child: Center(
                  child: Text(
                    'Malta Wash',
                    style: TextStyle(color: Colors.white30, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
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

class _MobileCarWashSceneState extends State<_MobileCarWashScene>
    with SingleTickerProviderStateMixin {
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
        final pulse = t >= .24 && t <= .70
            ? math.sin((t - .24) * math.pi * 13).abs()
            : 0.0;
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final travel = math.max(260.0, width + 70);
            final x = -145 + (enter * .56 + exit * .48) * travel;
            return Container(
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFF11161D),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(.08)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  const Positioned.fill(child: CustomPaint(painter: _GridPainter())),
                  Positioned(top: 18, left: 18, child: _Status(active: t < .23, label: 'CHEGANDO', color: Color(0xFF2563EB))),
                  Positioned(top: 52, left: 18, child: _Status(active: t >= .23 && t < .70, label: 'LAVANDO', color: Color(0xFFFF6A00))),
                  Positioned(top: 86, left: 18, child: _Status(active: t >= .70, label: 'PRONTO', color: Color(0xFF22C55E))),
                  Positioned(
                    right: 28,
                    bottom: 48,
                    child: Opacity(
                      opacity: t >= .20 && t <= .72 ? .9 : .3,
                      child: const _Arch(),
                    ),
                  ),
                  if (t >= .20 && t <= .72) ...[
                    Positioned(right: 90, bottom: 92, child: _Bubble(size: 8 + pulse * 4)),
                    Positioned(right: 126, bottom: 118, child: _Bubble(size: 7 + pulse * 3)),
                    Positioned(right: 160, bottom: 84, child: _Bubble(size: 10 + pulse * 4)),
                  ],
                  Positioned(left: x, bottom: 28, child: const _Car()),
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
      width: 145,
      height: 68,
      child: Stack(
        children: [
          Positioned(
            left: 12,
            right: 0,
            bottom: 10,
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF6A00), Color(0xFFFF8A38)]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [BoxShadow(color: Color(0x55FF6A00), blurRadius: 16, offset: Offset(0, 6))],
              ),
            ),
          ),
          Positioned(
            left: 43,
            bottom: 40,
            child: Container(
              width: 66,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF233044),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(22)),
              ),
            ),
          ),
          Positioned(left: 53, bottom: 43, child: Container(width: 23, height: 16, decoration: BoxDecoration(color: const Color(0xFF79B8FF).withOpacity(.65), borderRadius: BorderRadius.circular(6)))),
          Positioned(left: 80, bottom: 43, child: Container(width: 22, height: 16, decoration: BoxDecoration(color: const Color(0xFF79B8FF).withOpacity(.45), borderRadius: BorderRadius.circular(6)))),
          const Positioned(left: 28, bottom: 1, child: _Wheel()),
          const Positioned(right: 20, bottom: 1, child: _Wheel()),
        ],
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel();
  @override
  Widget build(BuildContext context) => Container(
        width: 23,
        height: 23,
        decoration: BoxDecoration(
          color: const Color(0xFF080B10),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF3A4657), width: 4),
        ),
      );
}

class _Arch extends StatelessWidget {
  const _Arch();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 190,
        height: 112,
        child: Stack(
          children: [
            Positioned(left: 0, bottom: 0, child: Container(width: 10, height: 86, decoration: BoxDecoration(color: const Color(0xFF27303B), borderRadius: BorderRadius.circular(999)))),
            Positioned(right: 0, bottom: 0, child: Container(width: 10, height: 86, decoration: BoxDecoration(color: const Color(0xFF27303B), borderRadius: BorderRadius.circular(999)))),
            Positioned(left: 0, right: 0, top: 5, child: Container(height: 11, decoration: BoxDecoration(color: const Color(0xFF27303B), borderRadius: BorderRadius.circular(999)))),
            const Positioned(left: 45, top: 23, child: _Spray()),
            const Positioned(left: 90, top: 23, child: _Spray()),
            const Positioned(left: 135, top: 23, child: _Spray()),
          ],
        ),
      );
}

class _Spray extends StatelessWidget {
  const _Spray();
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(width: 6, height: 14, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(999))),
          Container(width: 2, height: 34, decoration: BoxDecoration(color: const Color(0xFF67B7FF).withOpacity(.55), borderRadius: BorderRadius.circular(999))),
        ],
      );
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(.72),
          border: Border.all(color: const Color(0xFF9ED5FF).withOpacity(.45)),
        ),
      );
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
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: .7,
          ),
        ),
      );
}

class _GridPainter extends CustomPainter {
  const _GridPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF334155).withOpacity(.15)
      ..strokeWidth = .6;
    const gap = 26.0;
    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
