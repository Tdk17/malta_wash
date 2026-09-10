import 'package:get_it/get_it.dart';
import 'package:malta_wash/Src/Core/auth/session_storage.dart';
import 'package:malta_wash/Src/Core/http/http_manager.dart';
import 'package:malta_wash/Src/Core/router/app_router.dart';
import 'package:malta_wash/Src/Core/storage/secure_storage_service.dart';
import 'package:malta_wash/Src/Features/auth/data/remote_auth_repository.dart';
import 'package:malta_wash/Src/Features/auth/domain/auth_repository.dart';
import 'package:malta_wash/Src/Features/auth/presentation/controllers/auth_controller.dart';
import 'package:malta_wash/Src/Features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:malta_wash/Src/Features/auth/presentation/controllers/login_controller.dart';
import 'package:malta_wash/Src/Features/auth/presentation/controllers/register_controller.dart';
import 'package:malta_wash/Src/Features/booking/data/remote_booking_repository.dart';
import 'package:malta_wash/Src/Features/booking/domain/booking_repository.dart';
import 'package:malta_wash/Src/Features/booking/presentation/controllers/booking_controller.dart';
import 'package:malta_wash/Src/Features/branding/presentation/controllers/branding_controller.dart';
import 'package:malta_wash/Src/Features/common/data/remote_resource_repository.dart';
import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';
import 'package:malta_wash/Src/Features/dashboard/data/remote_dashboard_repository.dart';
import 'package:malta_wash/Src/Features/dashboard/domain/dashboard_repository.dart';
import 'package:malta_wash/Src/Features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:malta_wash/Src/Features/vehicles/data/remote_vehicles_repository.dart';
import 'package:malta_wash/Src/Features/vehicles/domain/vehicles_repository.dart';
import 'package:malta_wash/Src/Features/vehicles/presentation/controllers/vehicles_controller.dart';

final GetIt sl = GetIt.instance;

void setupDependencies() {
  if (sl.isRegistered<AuthController>()) return;

  sl.registerLazySingleton<SecureStorageService>(() => const FlutterSecureStorageService());
  sl.registerLazySingleton<SessionStorage>(() => SessionStorage(sl()));
  sl.registerLazySingleton<HttpManager>(() => HttpManager(sessionStorage: sl()));

  sl.registerLazySingleton<AuthRepository>(() => RemoteAuthRepository(httpManager: sl(), sessionStorage: sl()));
  sl.registerLazySingleton<ResourceRepository>(() => RemoteResourceRepository(sl()));
  sl.registerLazySingleton<VehiclesRepository>(() => RemoteVehiclesRepository(sl()));
  sl.registerLazySingleton<BookingRepository>(() => RemoteBookingRepository(sl()));
  sl.registerLazySingleton<DashboardRepository>(() => RemoteDashboardRepository(sl()));

  sl.registerLazySingleton<AuthController>(() => AuthController(sl(), sl()));
  sl.registerLazySingleton<BrandingController>(() => BrandingController(sl()));
  sl.registerLazySingleton<LoginController>(() => LoginController(sl()));
  sl.registerLazySingleton<RegisterController>(() => RegisterController(sl()));
  sl.registerLazySingleton<ForgotPasswordController>(() => ForgotPasswordController(sl()));
  sl.registerLazySingleton<VehiclesController>(() => VehiclesController(sl()));
  sl.registerFactory<BookingController>(() => BookingController(sl(), sl()));
  sl.registerLazySingleton<DashboardController>(() => DashboardController(sl()));
  sl.registerLazySingleton<AppRouter>(() => AppRouter(sl()));
}
