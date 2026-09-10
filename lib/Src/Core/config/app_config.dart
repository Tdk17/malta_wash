abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static void validate() {
    if (apiBaseUrl.trim().isEmpty) {
      throw StateError('API_BASE_URL não foi configurada.');
    }
  }
}
