import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/auth/session_storage.dart';
import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Features/auth/presentation/pages/company_register_page.dart';
import 'package:malta_wash/Src/Features/auth/presentation/pages/forgot_password_page.dart';
import 'package:malta_wash/Src/Features/auth/presentation/pages/login_page.dart';
import 'package:malta_wash/Src/Features/auth/presentation/pages/register_page.dart';
import 'package:malta_wash/Src/Features/booking/presentation/pages/booking_page.dart';
import 'package:malta_wash/Src/Features/client_home/presentation/pages/client_home_page.dart';
import 'package:malta_wash/Src/Features/common/presentation/pages/resource_detail_page.dart';
import 'package:malta_wash/Src/Features/common/presentation/pages/resource_list_page.dart';
import 'package:malta_wash/Src/Features/common/presentation/pages/resource_tabs_page.dart';
import 'package:malta_wash/Src/Features/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:malta_wash/Src/Features/operation/presentation/pages/admin_commercial_config_page.dart';
import 'package:malta_wash/Src/Features/operation/presentation/pages/admin_directory_page.dart';
import 'package:malta_wash/Src/Features/operation/presentation/pages/admin_schedule_page.dart';
import 'package:malta_wash/Src/Features/operation/presentation/pages/admin_services_page.dart';
import 'package:malta_wash/Src/Features/operation/presentation/pages/admin_settings_page.dart';
import 'package:malta_wash/Src/Features/operation/presentation/pages/operation_board_page.dart';
import 'package:malta_wash/Src/Features/public/presentation/pages/home_page.dart';
import 'package:malta_wash/Src/Features/vehicles/presentation/pages/vehicles_page.dart';
import 'package:malta_wash/Src/Shared/layouts/app_shell.dart';

class AppRouter {
  AppRouter(this._sessionStorage);
  final SessionStorage _sessionStorage;

  late final GoRouter router = GoRouter(
    initialLocation: RoutePaths.home,
    redirect: (context, state) async {
      final path = state.uri.path;
      final public = {
        RoutePaths.home,
        RoutePaths.login,
        RoutePaths.register,
        RoutePaths.companyRegister,
        RoutePaths.resetPassword,
      };
      final hasSession = await _sessionStorage.hasSession();
      if (public.contains(path)) return null;
      if (!hasSession) return '${RoutePaths.login}?area=cliente';

      final role = (await _sessionStorage.role())?.toUpperCase();
      if (role == null || role.isEmpty) return null;
      final isSuperAdmin = role.contains('SUPER');
      final isAdmin = isSuperAdmin || role.contains('ADMIN') || role.contains('MANAGER') || role.contains('GERENTE') || role.contains('ATENDENTE') || role.contains('TECH') || role.contains('LAVADOR');
      if (path.startsWith('/super-admin') && !isSuperAdmin) return isAdmin ? RoutePaths.admin : RoutePaths.client;
      if (path.startsWith('/admin') && !isAdmin) return RoutePaths.client;
      if (path.startsWith('/cliente') && isAdmin) return isSuperAdmin ? RoutePaths.superAdmin : RoutePaths.admin;
      return null;
    },
    routes: [
      GoRoute(path: RoutePaths.home, builder: (_, __) => const HomePage()),
      GoRoute(path: RoutePaths.login, builder: (_, state) => LoginPage(initialArea: state.uri.queryParameters['area'])),
      GoRoute(path: RoutePaths.register, builder: (_, state) => RegisterPage(tenantSlug: state.uri.queryParameters['tenant'])),
      GoRoute(path: RoutePaths.companyRegister, builder: (_, __) => const CompanyRegisterPage()),
      GoRoute(path: RoutePaths.resetPassword, builder: (_, __) => const ForgotPasswordPage()),

      ShellRoute(builder: (_, __, child) => AppShell(mode: ShellMode.client, child: child), routes: [
        GoRoute(path: RoutePaths.client, builder: (_, __) => const ClientHomePage()),
        GoRoute(path: RoutePaths.clientVehicles, builder: (_, __) => const VehiclesPage()),
        GoRoute(path: RoutePaths.clientBooking, builder: (_, __) => const BookingPage()),
        GoRoute(path: RoutePaths.clientAppointments, builder: (_, __) => const ResourceListPage(title: 'Meus agendamentos', subtitle: 'Acompanhe seus próximos agendamentos e o histórico de lavagens.', endpoint: Endpoints.appointments)),
        GoRoute(path: RoutePaths.clientPlans, builder: (_, __) => const ResourceTabsPage(tabs: [
          ResourceTabDefinition(label: 'Planos', title: 'Planos disponíveis', subtitle: 'Escolha o plano que combina com a sua rotina.', endpoint: Endpoints.plans),
          ResourceTabDefinition(label: 'Minha assinatura', title: 'Minha assinatura', subtitle: 'Consulte status e benefícios da sua assinatura.', endpoint: Endpoints.subscriptions),
        ])),
        GoRoute(path: RoutePaths.clientProfile, builder: (_, __) => const ResourceDetailPage(title: 'Perfil', subtitle: 'Seus dados pessoais e preferências.', endpoint: Endpoints.profile)),
      ]),

      ShellRoute(builder: (_, __, child) => AppShell(mode: ShellMode.admin, child: child), routes: [
        GoRoute(path: RoutePaths.admin, builder: (_, __) => const AdminDashboardPage()),
        GoRoute(path: RoutePaths.adminCalendar, builder: (_, __) => const AdminSchedulePage(calendarMode: true)),
        GoRoute(path: RoutePaths.adminAppointments, builder: (_, __) => const AdminSchedulePage()),
        GoRoute(path: RoutePaths.adminOperation, builder: (_, __) => const OperationBoardPage()),
        GoRoute(path: RoutePaths.adminCustomers, builder: (_, __) => const AdminDirectoryPage()),
        GoRoute(path: RoutePaths.adminVehicles, builder: (_, __) => const AdminDirectoryPage(vehicleFocus: true)),
        GoRoute(path: RoutePaths.adminServices, builder: (_, __) => const AdminServicesPage()),
        GoRoute(path: RoutePaths.adminPlans, builder: (_, __) => const AdminCommercialConfigPage(mode: CommercialConfigMode.plans)),
        GoRoute(path: RoutePaths.adminLoyalty, builder: (_, __) => const AdminCommercialConfigPage(mode: CommercialConfigMode.loyalty)),
        GoRoute(path: RoutePaths.adminSettings, builder: (_, __) => const AdminSettingsPage()),
      ]),

      ShellRoute(builder: (_, __, child) => AppShell(mode: ShellMode.superAdmin, child: child), routes: [
        GoRoute(path: RoutePaths.superAdmin, builder: (_, __) => const ResourceListPage(title: 'Visão global da plataforma', subtitle: 'Empresas ativas, uso e visão SaaS.', endpoint: Endpoints.tenants)),
        GoRoute(path: RoutePaths.superAdminTenants, builder: (_, __) => const ResourceListPage(title: 'Empresas', subtitle: 'Empresas cadastradas na plataforma.', endpoint: Endpoints.tenants)),
        GoRoute(path: RoutePaths.superAdminPlans, builder: (_, __) => const ResourceListPage(title: 'Planos SaaS', subtitle: 'Planos e limites da plataforma.', endpoint: Endpoints.saasPlans)),
        GoRoute(path: RoutePaths.superAdminBilling, builder: (_, __) => const ResourceListPage(title: 'Cobranças SaaS', subtitle: 'Assinaturas e cobranças da plataforma.', endpoint: Endpoints.saasBilling)),
        GoRoute(path: RoutePaths.superAdminFlags, builder: (_, __) => const ResourceListPage(title: 'Feature flags', subtitle: 'Liberação de recursos por plano ou empresa.', endpoint: Endpoints.featureFlags)),
        GoRoute(path: RoutePaths.superAdminAudit, builder: (_, __) => const ResourceListPage(title: 'Auditoria', subtitle: 'Logs e suporte da plataforma.', endpoint: Endpoints.auditLogs)),
      ]),
    ],
    errorBuilder: (_, state) => Scaffold(body: Center(child: Text('Rota não encontrada: ${state.uri.path}'))),
  );
}
