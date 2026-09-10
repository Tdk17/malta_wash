import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Features/auth/presentation/controllers/auth_controller.dart';
import 'package:malta_wash/Src/Features/branding/presentation/controllers/branding_controller.dart';
import 'package:malta_wash/Src/Shared/widgets/brand_logo.dart';
import 'package:signals/signals_flutter.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child, required this.mode});
  final Widget child;
  final ShellMode mode;

  @override
  State<AppShell> createState() => _AppShellState();
}

enum ShellMode { client, admin, superAdmin }

class _AppShellState extends State<AppShell> {
  late final BrandingController branding = sl();

  @override
  void initState() {
    super.initState();
    branding.load();
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 980;
    if (!desktop) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          titleSpacing: 8,
          title: Watch((_) => Row(children: [
                BrandLogo(size: 34, logoUrl: branding.branding.value.logoUrl),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    branding.branding.value.companyName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ])),
        ),
        drawer: Drawer(child: SafeArea(child: _Navigation(mode: widget.mode))),
        body: widget.child,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(children: [
        SizedBox(width: widget.mode == ShellMode.client ? 248 : 280, child: _Navigation(mode: widget.mode)),
        Expanded(child: widget.child),
      ]),
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation({required this.mode});
  final ShellMode mode;

  @override
  Widget build(BuildContext context) {
    final branding = sl<BrandingController>();
    final items = switch (mode) {
      ShellMode.client => _clientItems,
      ShellMode.admin => _adminItems,
      ShellMode.superAdmin => _superItems,
    };

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF10151C), Color(0xFF0B0F14)],
        ),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 25, 18, 20),
          child: Watch((_) => Row(children: [
                BrandLogo(size: 44, logoUrl: branding.branding.value.logoUrl),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      branding.branding.value.companyName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mode == ShellMode.client ? 'Área do cliente' : 'powered by Malta Wash',
                      style: const TextStyle(color: Colors.white38, fontSize: 10.5),
                    ),
                  ]),
                ),
              ])),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: Colors.white10, height: 1),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            children: items.map((item) => _NavTile(item: item)).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(11, 8, 11, 16),
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            leading: const Icon(Icons.logout_rounded, color: Colors.white54, size: 20),
            title: const Text('Sair', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w600)),
            onTap: () async {
              await sl<AuthController>().logout();
              if (context.mounted) context.go(RoutePaths.login);
            },
          ),
        ),
      ]),
    );
  }

  static const _clientItems = [
    _NavItem('Início', Icons.home_rounded, RoutePaths.client),
    _NavItem('Agendar', Icons.calendar_month_rounded, RoutePaths.clientBooking),
    _NavItem('Meus agendamentos', Icons.event_note_rounded, RoutePaths.clientAppointments),
    _NavItem('Meus veículos', Icons.directions_car_filled_rounded, RoutePaths.clientVehicles),
    _NavItem('Meu plano', Icons.workspace_premium_rounded, RoutePaths.clientPlans),
    _NavItem('Perfil', Icons.person_rounded, RoutePaths.clientProfile),
  ];

  static const _adminItems = [
    _NavItem('Dashboard', Icons.dashboard_outlined, RoutePaths.admin),
    _NavItem('Agenda', Icons.calendar_view_week_outlined, RoutePaths.adminCalendar),
    _NavItem('Fila operacional', Icons.local_car_wash_outlined, RoutePaths.adminOperation),
    _NavItem('Agendamentos', Icons.event_available_outlined, RoutePaths.adminAppointments),
    _NavItem('Clientes', Icons.groups_outlined, RoutePaths.adminCustomers),
    _NavItem('Veículos', Icons.directions_car_outlined, RoutePaths.adminVehicles),
    _NavItem('Ordens de serviço', Icons.receipt_long_outlined, RoutePaths.adminWorkOrders),
    _NavItem('Serviços', Icons.cleaning_services_outlined, RoutePaths.adminServices),
    _NavItem('Adicionais', Icons.add_circle_outline, RoutePaths.adminAddons),
    _NavItem('Planos', Icons.workspace_premium_outlined, RoutePaths.adminPlans),
    _NavItem('Assinaturas', Icons.autorenew, RoutePaths.adminSubscriptions),
    _NavItem('Pacotes', Icons.inventory_2_outlined, RoutePaths.adminPackages),
    _NavItem('Cupons', Icons.sell_outlined, RoutePaths.adminCoupons),
    _NavItem('Unidades', Icons.store_mall_directory_outlined, RoutePaths.adminLocations),
    _NavItem('Equipe', Icons.badge_outlined, RoutePaths.adminTeam),
    _NavItem('Escalas e bloqueios', Icons.schedule_outlined, RoutePaths.adminSchedules),
    _NavItem('Fidelidade', Icons.loyalty_outlined, RoutePaths.adminLoyalty),
    _NavItem('Financeiro', Icons.account_balance_wallet_outlined, RoutePaths.adminFinance),
    _NavItem('Relatórios', Icons.insights_outlined, RoutePaths.adminReports),
    _NavItem('Avaliações', Icons.star_outline, RoutePaths.adminReviews),
    _NavItem('Marketing / CRM', Icons.campaign_outlined, RoutePaths.adminMarketing),
    _NavItem('Configurações', Icons.settings_outlined, RoutePaths.adminSettings),
    _NavItem('Usuários e permissões', Icons.admin_panel_settings_outlined, RoutePaths.adminUsers),
  ];

  static const _superItems = [
    _NavItem('Visão global', Icons.public, RoutePaths.superAdmin),
    _NavItem('Empresas / tenants', Icons.apartment_outlined, RoutePaths.superAdminTenants),
    _NavItem('Planos SaaS', Icons.layers_outlined, RoutePaths.superAdminPlans),
    _NavItem('Cobranças SaaS', Icons.credit_card_outlined, RoutePaths.superAdminBilling),
    _NavItem('Feature flags', Icons.flag_outlined, RoutePaths.superAdminFlags),
    _NavItem('Auditoria e suporte', Icons.policy_outlined, RoutePaths.superAdminAudit),
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
      child: ListTile(
        minLeadingWidth: 22,
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 1),
        selected: active,
        selectedTileColor: const Color(0xFFFF6A00),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        leading: Icon(item.icon, color: active ? Colors.white : Colors.white54, size: 20),
        title: Text(
          item.label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white70,
            fontSize: 13.5,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        onTap: () => context.go(item.route),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}
