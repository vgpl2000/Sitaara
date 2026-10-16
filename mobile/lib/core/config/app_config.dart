class AppConfig {
  const AppConfig._();

  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'production',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sitaara-production.up.railway.app',
  );

  static Uri get apiUri {
    final uri = Uri.parse(apiBaseUrl);
    if (!uri.hasScheme || !uri.hasAuthority) {
      throw StateError('API_BASE_URL must be an absolute URL.');
    }

    if (uri.scheme == 'https') return uri;

    const localHosts = {'localhost', '127.0.0.1', '10.0.2.2'};
    final isLocalHttp =
        environment == 'local' &&
        uri.scheme == 'http' &&
        localHosts.contains(uri.host);
    if (!isLocalHttp) {
      throw StateError(
        'API_BASE_URL must use HTTPS outside local development.',
      );
    }

    return uri;
  }
}
