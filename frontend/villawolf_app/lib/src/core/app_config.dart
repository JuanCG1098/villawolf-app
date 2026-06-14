/// App configuration. The API base URL is injected at build/run time:
/// `--dart-define=API_BASE_URL=http://localhost:8080`.
class AppConfig {
  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');
}
