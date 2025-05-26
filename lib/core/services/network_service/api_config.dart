class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(milliseconds: 5000),
    this.receiveTimeout = const Duration(milliseconds: 3000),
    this.headers = const <String, String>{'Content-Type': 'application/json'},
  });

  factory ApiConfig.defaultConfig() =>
      const ApiConfig(baseUrl: 'https://nyaa.si');

  factory ApiConfig.development() => const ApiConfig(
    baseUrl: 'https://nyaa.si',
    connectTimeout: Duration(milliseconds: 30000),
    receiveTimeout: Duration(milliseconds: 18000),
  );

  factory ApiConfig.production() => const ApiConfig(
    baseUrl: 'https://nyaa.si',
  );

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Map<String, dynamic> headers;
}
