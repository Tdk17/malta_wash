import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Shared/widgets/brand_logo.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.child,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final Widget child;
  final String eyebrow;
  final String title;
  final String description;

  static const _orange = Color(0xFFFF6A00);
  static const _ink = Color(0xFF0D1117);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 980;
          if (desktop) {
            return Row(
              children: [
                Expanded(flex: 11, child: _BrandPanel(title: title, description: description)),
                Expanded(flex: 9, child: _FormSide(eyebrow: eyebrow, child: child)),
              ],
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
              child: Column(
                children: [
                  _MobileHeader(title: title, description: description),
                  const SizedBox(height: 18),
                  _FormCard(eyebrow: eyebrow, child: child),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.title, required this.description});
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B0E12), Color(0xFF151A21), Color(0xFF24150B)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _AuthGrid()),
          const Positioned(top: -110, right: -80, child: _Glow(size: 360, opacity: .15)),
          const Positioned(bottom: -170, left: -100, child: _Glow(size: 420, opacity: .10)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(54, 34, 54, 42),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BrandHeader(onTap: () => context.go(RoutePaths.home)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.07),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withOpacity(.09)),
                    ),
                    child: const Text(
                      'MALTA WASH',
                      style: TextStyle(color: Color(0xFFFFA15F), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 46, height: 1.02, fontWeight: FontWeight.w900, letterSpacing: -1.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 590),
                    child: Text(
                      description,
                      style: TextStyle(color: Colors.white.withOpacity(.65), fontSize: 16, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _CarWashScene(),
                  const Spacer(),
                  Row(
                    children: [
                      Container(width: 30, height: 3, decoration: BoxDecoration(color: AuthLayout._orange, borderRadius: BorderRadius.circular(999))),
                      const SizedBox(width: 10),
                      Text('Malta Wash', style: TextStyle(color: Colors.white.withOpacity(.42), fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarWashScene extends StatefulWidget {
  const _CarWashScene();

  @override
  State<_CarWashScene> createState() => _CarWashSceneState();
}

class _CarWashSceneState extends State<_CarWashScene> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
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
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final enter = _segment(t, 0.00, 0.22);
        final exit = _segment(t, 0.68, 0.94);
        final washPulse = t >= .24 && t <= .70 ? (math.sin((t - .24) * math.pi * 13).abs()) : 0.0;
        final carX = enter * .56 + exit * .48;

        return Container(
          height: 230,
          constraints: const BoxConstraints(maxWidth: 620),
          decoration: BoxDecoration(
            color: const Color(0xFF10151D).withOpacity(.78),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(.07)),
            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 32, offset: Offset(0, 18))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(27),
            child: Stack(
              children: [
                const Positioned.fill(child: _SceneGrid()),
                Positioned(left: 22, top: 18, child: _SceneLabel(active: t < .23, text: 'CHEGANDO', color: Color(0xFF2563EB))),
                Positioned(left: 22, top: 52, child: _SceneLabel(active: t >= .23 && t < .70, text: 'LAVANDO', color: Color(0xFFFF6A00))),
                Positioned(left: 22, top: 86, child: _SceneLabel(active: t >= .70, text: 'PRONTO', color: Color(0xFF22C55E))),
                Positioned(
                  right: 24,
                  top: 22,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.05), borderRadius: BorderRadius.circular(999)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.autorenew_rounded, color: Color(0xFFFF8A38), size: 15),
                      SizedBox(width: 6),
                      Text('loop ao vivo', style: TextStyle(color: Colors.white54, fontSize: 10.5, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
                Positioned(
                  left: 118,
                  right: 52,
                  bottom: 38,
                  child: Container(height: 2, color: Colors.white.withOpacity(.08)),
                ),
                Positioned(
                  left: 150,
                  bottom: 52,
                  child: Opacity(
                    opacity: t >= .20 && t <= .72 ? .9 : .25,
                    child: const _WashArch(),
                  ),
                ),
                if (t >= .20 && t <= .72) ...[
                  Positioned(left: 208, bottom: 72, child: _Bubble(size: 9 + washPulse * 5, opacity: .35 + washPulse * .45)),
                  Positioned(left: 246, bottom: 96, child: _Bubble(size: 7 + washPulse * 4, opacity: .25 + washPulse * .40)),
                  Positioned(left: 292, bottom: 78, child: _Bubble(size: 11 + washPulse * 5, opacity: .30 + washPulse * .45)),
                  Positioned(left: 330, bottom: 104, child: _Bubble(size: 6 + washPulse * 3, opacity: .25 + washPulse * .35)),
                  Positioned(left: 360, bottom: 82, child: _Bubble(size: 9 + washPulse * 4, opacity: .25 + washPulse * .4)),
                ],
                Positioned(
                  left: -80 + carX * 560,
                  bottom: 33,
                  child: Transform.scale(
                    scale: .96 + washPulse * .025,
                    child: const _Car(),
                  ),
                ),
              ],
            ),
          ),
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
          Positioned(
            left: 15,
            right: 0,
            bottom: 12,
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF6A00), Color(0xFFFF8A38)]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [BoxShadow(color: Color(0x55FF6A00), blurRadius: 18, offset: Offset(0, 7))],
              ),
            ),
          ),
          Positioned(
            left: 52,
            bottom: 44,
            child: Container(
              width: 76,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFF233044),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(24)),
              ),
            ),
          ),
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
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: const Color(0xFF080B10),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF3A4657), width: 4),
      ),
    );
  }
}

class _WashArch extends StatelessWidget {
  const _WashArch();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 128,
      child: Stack(
        children: [
          Positioned(left: 0, bottom: 0, child: Container(width: 12, height: 98, decoration: BoxDecoration(color: const Color(0xFF27303B), borderRadius: BorderRadius.circular(999)))),
          Positioned(right: 0, bottom: 0, child: Container(width: 12, height: 98, decoration: BoxDecoration(color: const Color(0xFF27303B), borderRadius: BorderRadius.circular(999)))),
          Positioned(left: 0, right: 0, top: 4, child: Container(height: 13, decoration: BoxDecoration(color: const Color(0xFF27303B), borderRadius: BorderRadius.circular(999)))),
          const Positioned(left: 55, top: 26, child: _Spray()),
          const Positioned(left: 115, top: 26, child: _Spray()),
          const Positioned(left: 175, top: 26, child: _Spray()),
        ],
      ),
    );
  }
}

class _Spray extends StatelessWidget {
  const _Spray();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(width: 7, height: 16, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(999))),
      const SizedBox(height: 2),
      Container(width: 2, height: 40, decoration: BoxDecoration(color: const Color(0xFF67B7FF).withOpacity(.55), borderRadius: BorderRadius.circular(999))),
    ]);
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity.clamp(0, 1)),
        border: Border.all(color: const Color(0xFF9ED5FF).withOpacity(.45)),
      ),
    );
  }
}

class _SceneLabel extends StatelessWidget {
  const _SceneLabel({required this.active, required this.text, required this.color});
  final bool active;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(.15) : Colors.white.withOpacity(.025),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: active ? color.withOpacity(.5) : Colors.white.withOpacity(.05)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: active ? color : Colors.white24, shape: BoxShape.circle)),
        const SizedBox(width: 7),
        Text(text, style: TextStyle(color: active ? Colors.white : Colors.white38, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: .8)),
      ]),
    );
  }
}

class _AuthGrid extends StatelessWidget {
  const _AuthGrid();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GridPainter(opacity: .07));
}

class _SceneGrid extends StatelessWidget {
  const _SceneGrid();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GridPainter(opacity: .05, gap: 24));
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.opacity, this.gap = 34});
  final double opacity;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = .6;
    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FormSide extends StatelessWidget {
  const _FormSide({required this.eyebrow, required this.child});
  final String eyebrow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 34),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height - 68),
          child: Center(child: _FormCard(eyebrow: eyebrow, child: child)),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.eyebrow, required this.child});
  final String eyebrow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.fromLTRB(34, 30, 34, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8EBF0)),
        boxShadow: const [BoxShadow(color: Color(0x120F172A), blurRadius: 42, offset: Offset(0, 18))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const BrandLogo(size: 48),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Malta Wash', style: TextStyle(color: AuthLayout._ink, fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: -.2)),
              ),
              TextButton.icon(
                onPressed: () => context.go(RoutePaths.home),
                icon: const Icon(Icons.arrow_back_rounded, size: 17),
                label: const Text('Voltar'),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            eyebrow.toUpperCase(),
            style: const TextStyle(color: AuthLayout._orange, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.15),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader({required this.title, required this.description});
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0B0E12), Color(0xFF23150B)]),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _SceneGrid()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BrandHeader(onTap: () => context.go(RoutePaths.home)),
              const SizedBox(height: 28),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 31, height: 1.06, fontWeight: FontWeight.w900, letterSpacing: -.7)),
              const SizedBox(height: 12),
              Text(description, style: TextStyle(color: Colors.white.withOpacity(.68), height: 1.5)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandLogo(size: 46),
            SizedBox(width: 12),
            Text('Malta Wash', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: AuthLayout._orange.withOpacity(opacity)),
      ),
    );
  }
}
