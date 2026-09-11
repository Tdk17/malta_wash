import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Features/auth/presentation/controllers/auth_controller.dart';
import 'package:malta_wash/Src/Shared/widgets/brand_logo.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.mode});
  final Widget child;
  final ShellMode mode;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 980;
    final content = _CenterCanvas(child: child);

    if (!desktop) {
      return Scaffold(
        backgroundColor: const Color(0xFFEEF2F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0D12),
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 8,
          title: const Row(children: [
            BrandLogo(size: 34),
            SizedBox(width: 10),
            Expanded(child: Text('Malta Wash', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
          ]),
        ),
        drawer: Drawer(width: 286, backgroundColor: Colors.transparent, child: SafeArea(child: _Navigation(mode: mode))),
        body: content,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      body: Row(children: [
        SizedBox(width: 258, child: _Navigation(mode: mode)),
        Expanded(child: content),
      ]),
    );
  }
}

class _CenterCanvas extends StatelessWidget {
  const _CenterCanvas({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFEEF4FF), Color(0xFFFFF7ED)],
                stops: [0, .42, .74, 1],
              ),
            ),
          ),
          const Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _CenterGridPainter()))),
          Positioned(top: -170, right: -130, child: IgnorePointer(child: Container(width: 390, height: 390, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF2563EB).withOpacity(.055))))),
          Positioned(bottom: -190, left: -130, child: IgnorePointer(child: Container(width: 420, height: 420, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFF6A00).withOpacity(.05))))),
          child,
        ],
      ),
    );
  }
}

enum ShellMode { client, admin, superAdmin }

class _Navigation extends StatelessWidget {
  const _Navigation({required this.mode});
  final ShellMode mode;

  @override
  Widget build(BuildContext context) {
    final items = switch (mode) {
      ShellMode.client => _clientItems,
      ShellMode.admin => _adminItems,
      ShellMode.superAdmin => _superItems,
    };

    return ClipRect(
      child: Stack(
        children: [
          const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF11161E), Color(0xFF080B10)])))),
          const Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(top: -90, right: -80, child: IgnorePointer(child: Container(width: 240, height: 240, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFF6A00).withOpacity(.10))))),
          Positioned(bottom: 80, left: -120, child: IgnorePointer(child: Container(width: 260, height: 260, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF2563EB).withOpacity(.08))))),
          Column(children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 22, 18, 18),
              child: Row(children: [
                BrandLogo(size: 44),
                SizedBox(width: 12),
                Expanded(child: Text('Malta Wash', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17))),
              ]),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Container(height: 1, color: Colors.white.withOpacity(.07))),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(mode == ShellMode.client ? 'NAVEGAÇÃO' : 'OPERAÇÃO', style: const TextStyle(color: Color(0xFF606C7B), fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1.25)),
              ),
            ),
            const SizedBox(height: 9),
            Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 10), children: items.map((item) => _NavTile(item: item)).toList())),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
              child: InkWell(
                onTap: () async {
                  await sl<AuthController>().logout();
                  if (context.mounted) context.go(RoutePaths.login);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(.06)), color: Colors.white.withOpacity(.025)),
                  child: const Row(children: [Icon(Icons.logout_rounded, color: Color(0xFF8D98A8), size: 19), SizedBox(width: 11), Text('Sair', style: TextStyle(color: Color(0xFFA8B1BE), fontWeight: FontWeight.w700, fontSize: 13))]),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  static const _clientItems = [
    _NavItem('Início', Icons.home_rounded, RoutePaths.client),
    _NavItem('Agendar lavagem', Icons.calendar_month_rounded, RoutePaths.clientBooking),
    _NavItem('Meus agendamentos', Icons.event_note_rounded, RoutePaths.clientAppointments),
    _NavItem('Meus veículos', Icons.directions_car_filled_rounded, RoutePaths.clientVehicles),
    _NavItem('Meu plano', Icons.workspace_premium_rounded, RoutePaths.clientPlans),
    _NavItem('Perfil', Icons.person_rounded, RoutePaths.clientProfile),
  ];

  static const _adminItems = [
    _NavItem('Início', Icons.space_dashboard_rounded, RoutePaths.admin),
    _NavItem('Agendamentos', Icons.event_available_rounded, RoutePaths.adminAppointments),
    _NavItem('Atendimentos', Icons.local_car_wash_rounded, RoutePaths.adminOperation),
    _NavItem('Clientes', Icons.people_alt_rounded, RoutePaths.adminCustomers),
    _NavItem('Serviços', Icons.cleaning_services_rounded, RoutePaths.adminServices),
    _NavItem('Planos de fidelidade', Icons.loyalty_rounded, RoutePaths.adminPlans),
    _NavItem('Configurações', Icons.settings_rounded, RoutePaths.adminSettings),
  ];

  static const _superItems = [
    _NavItem('Visão global', Icons.public, RoutePaths.superAdmin),
    _NavItem('Empresas', Icons.apartment_outlined, RoutePaths.superAdminTenants),
    _NavItem('Planos SaaS', Icons.layers_outlined, RoutePaths.superAdminPlans),
    _NavItem('Cobranças', Icons.credit_card_outlined, RoutePaths.superAdminBilling),
    _NavItem('Feature flags', Icons.flag_outlined, RoutePaths.superAdminFlags),
    _NavItem('Auditoria', Icons.policy_outlined, RoutePaths.superAdminAudit),
  ];
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.item});
  final _NavItem item;
  @override
  Widget build(BuildContext context) {
    final active = GoRouterState.of(context).uri.path == item.route;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(item.route),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: active ? const LinearGradient(colors: [Color(0xFFFF6A00), Color(0xFFFF8734)]) : null,
              color: active ? null : Colors.transparent,
              border: Border.all(color: active ? const Color(0xFFFFA362) : Colors.transparent),
              boxShadow: active ? const [BoxShadow(color: Color(0x33FF6A00), blurRadius: 18, offset: Offset(0, 7))] : null,
            ),
            child: Row(children: [
              Container(width: 31, height: 31, decoration: BoxDecoration(color: active ? Colors.white.withOpacity(.15) : Colors.white.withOpacity(.04), borderRadius: BorderRadius.circular(10)), child: Icon(item.icon, color: active ? Colors.white : const Color(0xFF8995A5), size: 18)),
              const SizedBox(width: 10),
              Expanded(child: Text(item.label, style: TextStyle(color: active ? Colors.white : const Color(0xFFB5BDC8), fontSize: 13, fontWeight: active ? FontWeight.w900 : FontWeight.w600))),
              if (active) const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 18),
            ]),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF334155).withOpacity(.13)..strokeWidth = .6;
    const gap = 28.0;
    for (double x = 0; x <= size.width; x += gap) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y <= size.height; y += gap) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CenterGridPainter extends CustomPainter {
  const _CenterGridPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF64748B).withOpacity(.045)..strokeWidth = .55;
    const gap = 36.0;
    for (double x = 0; x <= size.width; x += gap) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y <= size.height; y += gap) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}
