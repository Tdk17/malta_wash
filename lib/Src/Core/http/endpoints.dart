abstract final class Endpoints {
  static const register = '/v1/auth/register';
  static const login = '/v1/auth/login';
  static const logout = '/v1/auth/logout';
  static const me = '/v1/auth/me';
  static const passwordReset = '/v1/auth/password-reset';

  static const tenants = '/v1/tenants';
  static String tenant(String id) => '/v1/tenants/$id';
  static const locations = '/v1/locations';
  static String location(String id) => '/v1/locations/$id';

  static const customers = '/v1/customers';
  static String customer(String id) => '/v1/customers/$id';
  static String customerHistory(String id) => '/v1/customers/$id/history';
  static const vehicles = '/v1/vehicles';
  static String vehicle(String id) => '/v1/vehicles/$id';

  static const services = '/v1/services';
  static String service(String id) => '/v1/services/$id';
  static const serviceAddons = '/v1/service-addons';
  static const availability = '/v1/availability';

  static const appointments = '/v1/appointments';
  static String appointment(String id) => '/v1/appointments/$id';
  static String appointmentCancel(String id) => '/v1/appointments/$id/cancel';
  static String appointmentReschedule(String id) => '/v1/appointments/$id/reschedule';
  static String appointmentCheckIn(String id) => '/v1/appointments/$id/check-in';

  static const workOrders = '/v1/work-orders';
  static String workOrder(String id) => '/v1/work-orders/$id';
  static String workOrderStart(String id) => '/v1/work-orders/$id/start';
  static String workOrderStatus(String id) => '/v1/work-orders/$id/status';
  static String workOrderComplete(String id) => '/v1/work-orders/$id/complete';
  static String workOrderPhotos(String id) => '/v1/work-orders/$id/photos';

  static const plans = '/v1/plans';
  static String plan(String id) => '/v1/plans/$id';
  static const subscriptions = '/v1/subscriptions';
  static String subscription(String id) => '/v1/subscriptions/$id';
  static String subscriptionCancel(String id) => '/v1/subscriptions/$id/cancel';
  static String subscriptionPause(String id) => '/v1/subscriptions/$id/pause';
  static String subscriptionUsage(String id) => '/v1/subscriptions/$id/usage';

  static const packages = '/v1/packages';
  static String packagePurchase(String id) => '/v1/packages/$id/purchase';
  static const coupons = '/v1/coupons';
  static const couponValidate = '/v1/coupons/validate';

  static const payments = '/v1/payments';
  static const paymentIntent = '/v1/payments/intent';
  static String payment(String id) => '/v1/payments/$id';
  static String paymentRefund(String id) => '/v1/payments/$id/refund';

  static const team = '/v1/team';
  static String teamMember(String id) => '/v1/team/$id';
  static const shifts = '/v1/shifts';
  static const blocks = '/v1/blocks';

  static const dashboardMetrics = '/v1/dashboard/metrics';
  static const dashboardOperation = '/v1/dashboard/operation';
  static const reportSales = '/v1/reports/sales';
  static const reportServices = '/v1/reports/services';
  static const reportCustomers = '/v1/reports/customers';
  static const reportOccupancy = '/v1/reports/occupancy';
  static const reportSubscriptions = '/v1/reports/subscriptions';
  static const reportTeam = '/v1/reports/team';

  static const notifications = '/v1/notifications';
  static String notificationRead(String id) => '/v1/notifications/$id/read';
  static const notificationPreferences = '/v1/notification-preferences';
  static const reviews = '/v1/reviews';
  static const adminReviews = '/v1/admin/reviews';
  static const uploadPresign = '/v1/uploads/presign';

  // Contratos adicionais requeridos pelas telas completas do front.
  // Eles não estavam detalhados na tabela mínima do documento base e devem
  // ser implementados/confirmados no backend.
  static const profile = '/v1/profile';
  static const settings = '/v1/settings';
  static const supportFaqs = '/v1/support/faqs';
  static const supportTickets = '/v1/support/tickets';
  static const marketingSegments = '/v1/marketing/segments';
  static const marketingCampaigns = '/v1/marketing/campaigns';
  static const loyalty = '/v1/loyalty';
  static const saasPlans = '/v1/saas/plans';
  static const saasBilling = '/v1/saas/billing';
  static const featureFlags = '/v1/feature-flags';
  static const auditLogs = '/v1/audit-logs';
}
