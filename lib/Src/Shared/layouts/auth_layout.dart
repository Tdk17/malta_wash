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
                  const SizedBox(height: 22),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 50, height: 1.04, fontWeight: FontWeight.w900, letterSpacing: -1.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 590),
                    child: Text(
                      description,
                      style: TextStyle(color: Colors.white.withOpacity(.68), fontSize: 17, height: 1.55),
                    ),
                  ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandHeader(onTap: () => context.go(RoutePaths.home)),
          const SizedBox(height: 28),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 31, height: 1.06, fontWeight: FontWeight.w900, letterSpacing: -.7)),
          const SizedBox(height: 12),
          Text(description, style: TextStyle(color: Colors.white.withOpacity(.68), height: 1.5)),
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
