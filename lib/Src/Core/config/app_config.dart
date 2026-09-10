class AppConfig {
  const AppConfig._();

  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const String parseServerUrl = String.fromEnvironment(
    'PARSE_SERVER_URL',
    defaultValue: 'https://parseapi.back4app.com',
  );

  static const String parseApplicationId = String.fromEnvironment(
    'PARSE_APPLICATION_ID',
  );

  // Chave de cliente destinada a aplicações cliente. Não usar Master Key
  // nem embutir REST API Key no Flutter Web/GitHub Pages.
  static const String parseClientKey = String.fromEnvironment(
    'PARSE_CLIENT_KEY',
  );

  static bool get isProduction =>
      environment == 'production' || environment == 'prod';

  static void validate() {
    if (parseServerUrl.trim().isEmpty || parseApplicationId.trim().isEmpty) {
      throw StateError(
        'PARSE_SERVER_URL e PARSE_APPLICATION_ID são obrigatórios.',
      );
    }
  }
}
