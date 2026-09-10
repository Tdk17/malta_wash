import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/auth/session_storage.dart';
import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Features/auth/presentation/pages/forgot_password_page.dart';
import 'package:malta_wash/Src/Features/auth/presentation/pages/login_page.dart';
import 'package:malta_wash/Src/Features/auth/presentation/pages/register_page.dart';
import 'package:malta_wash/Src/Features/booking/presentation/pages/booking_page.dart';
import 'package:malta_wash/Src/Features/client_home/presentation/pages/client_home_page.dart';
import 'package:malta_wash/Src/Features/common/presentation/pages/resource_detail_page.dart';
import 'package:malta_wash/Src/Features/common/presentation/pages/resource_list_page.dart';
import 'package:malta_wash/Src/Features/common/presentation/pages/resource_tabs_page.dart';
import 'package:malta_wash/Src/Features/dashboard/presentation/pages/admin_dashboard_page.dart';
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
        RoutePaths.resetPassword,
      };
      final hasSession = await _sessionStorage.hasSession();
      if (public.contains(path)) return null;
      if (!hasSession) return RoutePaths.login;

      final role = (await _sessionStorage.role())?.toUpperCase();
      if (role == null || role.isEmpty) return null;

      final isSuperAdmin = role.contains('SUPER');
      final isAdmin = isSuperAdmin ||
          role.contains('ADMIN') ||
          role.contains('MANAGER') ||
          role.contains('GERENTE') ||
          role.contains('ATENDENTE') ||
          role.contains('TECH') ||
          role.contains('LAVADOR');

      if (path.startsWith('/super-admin') && !isSuperAdmin) {
        return isAdmin ? RoutePaths.admin : RoutePaths.client;
      }
      if (path.startsWith('/admin') && !isAdmin) {
        return RoutePaths.client;
      }
      if (path.startsWith('/cliente') && isAdmin) {
        return isSuperAdmin ? RoutePaths.superAdmin : RoutePaths.admin;
      }
      return null;
    },
    routes: [
      GoRoute(path: RoutePaths.home, builder: (_, __) => const HomePage()),
      GoRoute(path: RoutePaths.login, builder: (_, __) => const LoginPage()),
      GoRoute(path: RoutePaths.register, builder: (_, __) => const RegisterPage()),
      GoRoute(path: RoutePaths.resetPassword, builder: (_, __) => const ForgotPasswordPage()),

      ShellRoute(builder: (_, __, child) => AppShell(mode: ShellMode.client, child: child), routes: [
        GoRoute(path: RoutePaths.client, builder: (_, __) => const ClientHomePage()),
        GoRoute(path: RoutePaths.clientVehicles, builder: (_, __) => const VehiclesPage()),
        GoRoute(path: RoutePaths.clientBooking, builder: (_, __) => const BookingPage()),
        GoRoute(path: RoutePaths.clientAppointments, builder: (_, __) => const ResourceListPage(title: 'Meus agendamentos', subtitle: 'Próximos, concluídos, cancelados e reagendamentos.', endpoint: Endpoints.appointments)),
        GoRoute(
          path: RoutePaths.clientPlans,
          builder: (_, __) => const ResourceTabsPage(tabs: [
            ResourceTabDefinition(label: 'Planos', title: 'Planos disponíveis', subtitle: 'Planos mensais/anuais e benefícios.', endpoint: Endpoints.plans),
            ResourceTabDefinition(label: 'Assinaturas', title: 'Minhas assinaturas', subtitle: 'Status, ciclo e consumo de benefícios.', endpoint: Endpoints.subscriptions),
          ]),
        ),
        GoRoute(path: RoutePaths.clientPackages, builder: (_, __) => const ResourceListPage(title: 'Pacotes e créditos', subtitle: 'Combos pré-pagos, créditos, validade e consumo.', endpoint: Endpoints.packages)),
        GoRoute(
          path: RoutePaths.clientBenefits,
          builder: (_, __) => const ResourceTabsPage(tabs: [
            ResourceTabDefinition(label: 'Cupons', title: 'Cupons e benefícios', subtitle: 'Cupons válidos e regras promocionais.', endpoint: Endpoints.coupons),
            ResourceTabDefinition(label: 'Fidelidade', title: 'Fidelidade', subtitle: 'Saldo, pontos, cashback ou benefícios configurados.', endpoint: Endpoints.loyalty),
          ]),
        ),
        GoRoute(path: RoutePaths.clientPayments, builder: (_, __) => const ResourceListPage(title: 'Pagamentos', subtitle: 'Histórico e status dos pagamentos.', endpoint: Endpoints.payments)),
        GoRoute(path: RoutePaths.clientNotifications, builder: (_, __) => const ResourceListPage(title: 'Notificações', subtitle: 'Confirmações, lembretes e atualizações.', endpoint: Endpoints.notifications)),
        GoRoute(path: RoutePaths.clientProfile, builder: (_, __) => const ResourceDetailPage(title: 'Perfil', subtitle: 'Dados pessoais e preferências.', endpoint: Endpoints.profile)),
        GoRoute(
          path: RoutePaths.clientSupport,
          builder: (_, __) => const ResourceTabsPage(tabs: [
            ResourceTabDefinition(label: 'FAQ', title: 'Perguntas frequentes', subtitle: 'Ajuda e orientações da empresa.', endpoint: Endpoints.supportFaqs),
            ResourceTabDefinition(label: 'Solicitações', title: 'Suporte', subtitle: 'Abertura e acompanhamento de solicitações.', endpoint: Endpoints.supportTickets),
          ]),
        ),
      ]),

      ShellRoute(builder: (_, __, child) => AppShell(mode: ShellMode.admin, child: child), routes: [
        GoRoute(path: RoutePaths.admin, builder: (_, __) => const AdminDashboardPage()),
        GoRoute(path: RoutePaths.adminCalendar, builder: (_, __) => const ResourceListPage(title: 'Agenda', subtitle: 'Agendamentos por dia/semana e disponibilidade.', endpoint: Endpoints.appointments)),
        GoRoute(path: RoutePaths.adminOperation, builder: (_, __) => const OperationBoardPage()),
        GoRoute(path: RoutePaths.adminAppointments, builder: (_, __) => const ResourceListPage(title: 'Agendamentos', subtitle: 'Busca, filtros, detalhes, reagendamento, cancelamento e no-show.', endpoint: Endpoints.appointments)),
        GoRoute(path: RoutePaths.adminCustomers, builder: (_, __) => const ResourceListPage(title: 'Clientes', subtitle: 'Cadastro, contatos, consentimentos, histórico e gastos.', endpoint: Endpoints.customers)),
        GoRoute(path: RoutePaths.adminVehicles, builder: (_, __) => const ResourceListPage(title: 'Veículos', subtitle: 'Base de veículos, histórico, fotos e proprietário.', endpoint: Endpoints.vehicles)),
        GoRoute(path: RoutePaths.adminWorkOrders, builder: (_, __) => const ResourceListPage(title: 'Ordens de serviço', subtitle: 'Checklist, fotos, responsáveis, tempos e valores.', endpoint: Endpoints.workOrders)),
        GoRoute(path: RoutePaths.adminServices, builder: (_, __) => const ResourceListPage(title: 'Serviços', subtitle: 'Preço, duração, porte e disponibilidade.', endpoint: Endpoints.services)),
        GoRoute(path: RoutePaths.adminAddons, builder: (_, __) => const ResourceListPage(title: 'Adicionais', subtitle: 'Preço, duração incremental e compatibilidade.', endpoint: Endpoints.serviceAddons)),
        GoRoute(path: RoutePaths.adminPlans, builder: (_, __) => const ResourceListPage(title: 'Planos de assinatura', subtitle: 'Recorrência, limites, serviços e benefícios.', endpoint: Endpoints.plans)),
        GoRoute(path: RoutePaths.adminSubscriptions, builder: (_, __) => const ResourceListPage(title: 'Assinaturas', subtitle: 'Ativos, inadimplentes, cancelados e consumo.', endpoint: Endpoints.subscriptions)),
        GoRoute(path: RoutePaths.adminPackages, builder: (_, __) => const ResourceListPage(title: 'Pacotes', subtitle: 'Combos pré-pagos, validade e regras.', endpoint: Endpoints.packages)),
        GoRoute(path: RoutePaths.adminCoupons, builder: (_, __) => const ResourceListPage(title: 'Cupons', subtitle: 'Códigos, validade, limites e regras.', endpoint: Endpoints.coupons)),
        GoRoute(path: RoutePaths.adminLocations, builder: (_, __) => const ResourceListPage(title: 'Unidades', subtitle: 'Endereço, horários, capacidade, boxes e serviços.', endpoint: Endpoints.locations)),
        GoRoute(path: RoutePaths.adminTeam, builder: (_, __) => const ResourceListPage(title: 'Equipe', subtitle: 'Usuários, função, unidade, escala e produtividade.', endpoint: Endpoints.team)),
        GoRoute(
          path: RoutePaths.adminSchedules,
          builder: (_, __) => const ResourceTabsPage(tabs: [
            ResourceTabDefinition(label: 'Escalas', title: 'Escalas', subtitle: 'Expediente, equipe e horários de trabalho.', endpoint: Endpoints.shifts),
            ResourceTabDefinition(label: 'Bloqueios', title: 'Bloqueios e indisponibilidades', subtitle: 'Folgas, feriados, manutenção de box e indisponibilidades.', endpoint: Endpoints.blocks),
          ]),
        ),
        GoRoute(path: RoutePaths.adminLoyalty, builder: (_, __) => const ResourceListPage(title: 'Fidelidade', subtitle: 'Pontos, cashback, créditos e regras de recorrência.', endpoint: Endpoints.loyalty)),
        GoRoute(path: RoutePaths.adminFinance, builder: (_, __) => const ResourceListPage(title: 'Financeiro', subtitle: 'Receitas, pendências, estornos e conciliação.', endpoint: Endpoints.payments)),
        GoRoute(
          path: RoutePaths.adminReports,
          builder: (_, __) => const ResourceTabsPage(tabs: [
            ResourceTabDefinition(label: 'Vendas', title: 'Relatório de vendas', subtitle: 'Receita, ticket e vendas por período.', endpoint: Endpoints.reportSales),
            ResourceTabDefinition(label: 'Serviços', title: 'Relatório de serviços', subtitle: 'Volume e receita por serviço.', endpoint: Endpoints.reportServices),
            ResourceTabDefinition(label: 'Clientes', title: 'Relatório de clientes', subtitle: 'Novos, recorrentes e reativação.', endpoint: Endpoints.reportCustomers),
            ResourceTabDefinition(label: 'Ocupação', title: 'Ocupação da agenda', subtitle: 'Capacidade disponível versus reservada/executada.', endpoint: Endpoints.reportOccupancy),
            ResourceTabDefinition(label: 'Assinaturas', title: 'Relatório de assinaturas', subtitle: 'MRR, churn, base ativa e inadimplência.', endpoint: Endpoints.reportSubscriptions),
            ResourceTabDefinition(label: 'Equipe', title: 'Relatório de equipe', subtitle: 'Produtividade, tempo médio e receita atribuída.', endpoint: Endpoints.reportTeam),
          ]),
        ),
        GoRoute(path: RoutePaths.adminReviews, builder: (_, __) => const ResourceListPage(title: 'Avaliações', subtitle: 'NPS, notas, comentários e tratativas.', endpoint: Endpoints.adminReviews)),
        GoRoute(
          path: RoutePaths.adminMarketing,
          builder: (_, __) => const ResourceTabsPage(tabs: [
            ResourceTabDefinition(label: 'Campanhas', title: 'Marketing / CRM', subtitle: 'Campanhas, reativação e relacionamento.', endpoint: Endpoints.marketingCampaigns),
            ResourceTabDefinition(label: 'Segmentos', title: 'Segmentos', subtitle: 'Grupos de clientes para campanhas e automações.', endpoint: Endpoints.marketingSegments),
          ]),
        ),
        GoRoute(path: RoutePaths.adminSettings, builder: (_, __) => const ResourceDetailPage(title: 'Configurações', subtitle: 'Marca, horários, cancelamento, pagamentos e notificações.', endpoint: Endpoints.settings)),
        GoRoute(path: RoutePaths.adminUsers, builder: (_, __) => const ResourceListPage(title: 'Usuários e permissões', subtitle: 'RBAC, convites e auditoria de acesso.', endpoint: Endpoints.team)),
      ]),

      ShellRoute(builder: (_, __, child) => AppShell(mode: ShellMode.superAdmin, child: child), routes: [
        GoRoute(path: RoutePaths.superAdmin, builder: (_, __) => const ResourceListPage(title: 'Visão global da plataforma', subtitle: 'Empresas ativas, uso e visão SaaS.', endpoint: Endpoints.tenants)),
        GoRoute(path: RoutePaths.superAdminTenants, builder: (_, __) => const ResourceListPage(title: 'Empresas / tenants', subtitle: 'Criar, bloquear, suspender, trocar plano e consultar uso.', endpoint: Endpoints.tenants)),
        GoRoute(path: RoutePaths.superAdminPlans, builder: (_, __) => const ResourceListPage(title: 'Planos SaaS', subtitle: 'Limites por usuários, unidades, agendamentos e recursos.', endpoint: Endpoints.saasPlans)),
        GoRoute(path: RoutePaths.superAdminBilling, builder: (_, __) => const ResourceListPage(title: 'Cobranças SaaS', subtitle: 'Assinaturas e cobranças da própria plataforma.', endpoint: Endpoints.saasBilling)),
        GoRoute(path: RoutePaths.superAdminFlags, builder: (_, __) => const ResourceListPage(title: 'Feature flags', subtitle: 'Liberação de módulos por plano ou empresa.', endpoint: Endpoints.featureFlags)),
        GoRoute(path: RoutePaths.superAdminAudit, builder: (_, __) => const ResourceListPage(title: 'Auditoria e suporte', subtitle: 'Logs, auditoria e painel de suporte.', endpoint: Endpoints.auditLogs)),
      ]),
    ],
    errorBuilder: (_, state) => Scaffold(body: Center(child: Text('Rota não encontrada: ${state.uri.path}'))),
  );
}
