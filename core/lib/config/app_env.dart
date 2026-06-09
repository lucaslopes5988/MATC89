class AppEnv {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.exemplo.com',
  );
}
