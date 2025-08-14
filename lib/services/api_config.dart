class ApiConfig {
  // Flag para alternar entre desarrollo y producción
  static const bool _isDevelopment = false; // Cambiar a false para producción

  // URLs base
  static const String _devBaseUrl =
      'http://apids.dev.disal.com.sv:8080/api/v2/';
  static const String _prodBaseUrl =
      'https://apids.portaldisal.com:8001/api/v2/';

  // Tokens de API
  static const String _devApiToken = '';
  static const String _prodApiToken = r'F6CTEBBdJ^&&$NCrqhGGc8';

  // URL base actual según el entorno
  static String get baseUrl => _isDevelopment ? _devBaseUrl : _prodBaseUrl;

  // Token actual según el entorno
  static String get apiToken => _isDevelopment ? _devApiToken : _prodApiToken;

  // Endpoints específicos
  static const String _loginEndpoint =
      'DS_Seguridad_Procedures/USP_LOGIN_PORTAL_APP_CORE';

  // URLs completas para cada endpoint
  static String get loginUrl => '$baseUrl$_loginEndpoint';

  // Headers por defecto
  static Map<String, String> get defaultHeaders {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Agregar token solo en producción
    if (isProduction && apiToken.isNotEmpty) {
      headers['X-AUTH-TOKEN'] = apiToken;
    }

    return headers;
  }

  // Headers específicos para autenticación
  static Map<String, String> get authHeaders {
    final headers = Map<String, String>.from(defaultHeaders);

    // En producción, asegurar que el token esté presente
    if (isProduction && apiToken.isNotEmpty) {
      headers['X-AUTH-TOKEN'] = apiToken;
    }

    return headers;
  }

  // Timeout por defecto
  static const Duration defaultTimeout = Duration(seconds: 180);

  // Información del entorno actual
  static String get environment => _isDevelopment ? 'DESARROLLO' : 'PRODUCCIÓN';
  static bool get isDevelopment => _isDevelopment;
  static bool get isProduction => !_isDevelopment;
}
