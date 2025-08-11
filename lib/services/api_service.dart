import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'api_config.dart';
import 'api_response.dart';

class ApiService extends GetxService {
  static ApiService get instance => Get.find<ApiService>();

  // Cliente HTTP con configuración personalizada
  late http.Client _client;

  @override
  void onInit() {
    super.onInit();
    _client = http.Client();
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }

  /// Método GET genérico
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
    bool useAuthHeaders = false,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final response = await _client
          .get(
            uri,
            headers: _buildHeaders(headers, useAuthHeaders),
          )
          .timeout(timeout ?? ApiConfig.defaultTimeout);

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Método POST genérico
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
    bool useAuthHeaders = false,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(headers, useAuthHeaders),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout ?? ApiConfig.defaultTimeout);

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Método PUT genérico
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
    bool useAuthHeaders = false,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final response = await _client
          .put(
            uri,
            headers: _buildHeaders(headers, useAuthHeaders),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout ?? ApiConfig.defaultTimeout);

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Método DELETE genérico
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
    bool useAuthHeaders = false,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final response = await _client
          .delete(
            uri,
            headers: _buildHeaders(headers, useAuthHeaders),
          )
          .timeout(timeout ?? ApiConfig.defaultTimeout);

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Construir URI con parámetros de consulta
  Uri _buildUri(String endpoint, Map<String, String>? queryParameters) {
    final baseUri = Uri.parse(ApiConfig.baseUrl);
    final fullPath = '${baseUri.path}$endpoint';

    return Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.port,
      path: fullPath,
      queryParameters: queryParameters,
    );
  }

  /// Construir headers con valores por defecto
  Map<String, String> _buildHeaders(
      Map<String, String>? customHeaders, bool useAuthHeaders) {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  /// Manejar respuesta HTTP
  ApiResponse<T> _handleResponse<T>(http.Response response) {
    _logResponse(response);

    try {
      final dynamic decodedData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Verificar si la respuesta de la API indica éxito
        if (decodedData is Map<String, dynamic> &&
            decodedData['success'] == false) {
          // La API devuelve success: false, tratarlo como error
          return ApiResponse<T>.error(
            message: decodedData['message'] ?? 'Error desconocido',
            details: decodedData['details'] ?? 'Sin detalles adicionales',
            statusCode: response.statusCode,
            errorCode: decodedData['errorCode'],
          );
        }

        // Respuesta exitosa
        return ApiResponse<T>.success(
          data: decodedData,
          statusCode: response.statusCode,
          message: 'Operación exitosa',
        );
      } else {
        // Error HTTP (4xx, 5xx)
        String errorMessage = 'Error del servidor';
        String errorDetails = 'Sin detalles adicionales';
        String? errorCode;

        if (decodedData is Map<String, dynamic>) {
          errorMessage =
              decodedData['message'] ?? _getErrorMessage(response.statusCode);
          errorDetails =
              decodedData['details'] ?? 'Error HTTP ${response.statusCode}';
          errorCode = decodedData['errorCode'];
        } else {
          errorMessage = _getErrorMessage(response.statusCode);
          errorDetails = 'Error HTTP ${response.statusCode}';
        }

        return ApiResponse<T>.error(
          message: errorMessage,
          details: errorDetails,
          statusCode: response.statusCode,
          errorCode: errorCode,
        );
      }
    } catch (e) {
      return ApiResponse<T>.error(
        message: 'Error al decodificar la respuesta',
        details: 'Error de parsing JSON: $e',
        statusCode: response.statusCode,
      );
    }
  }

  /// Obtener mensaje de error según código de estado
  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Solicitud incorrecta';
      case 401:
        return 'No autorizado';
      case 403:
        return 'Acceso prohibido';
      case 404:
        return 'Recurso no encontrado';
      case 500:
        return 'Error interno del servidor';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Servicio no disponible';
      default:
        return 'Error desconocido (Código: $statusCode)';
    }
  }

  /// Manejar errores de red/conexión
  ApiResponse<T> _handleError<T>(dynamic error) {
    _logError(error);

    if (error is SocketException) {
      return ApiResponse<T>.error(
        message: 'Sin conexión a internet',
        details: 'Verifique su conexión de red',
        statusCode: 0,
      );
    } else if (error is HttpException) {
      return ApiResponse<T>.error(
        message: 'Error de servidor',
        details: 'Error de comunicación HTTP',
        statusCode: 500,
      );
    } else if (error.toString().contains('TimeoutException')) {
      return ApiResponse<T>.error(
        message: 'Tiempo de espera agotado',
        details: 'La solicitud tardó demasiado en responder',
        statusCode: 408,
      );
    } else {
      return ApiResponse<T>.error(
        message: 'Error inesperado',
        details: error.toString(),
        statusCode: -1,
      );
    }
  }

  /// Log de respuesta (solo en desarrollo)
  void _logResponse(http.Response response) {
    if (ApiConfig.isDevelopment) {}
  }

  /// Log de error (solo en desarrollo)
  void _logError(dynamic error) {
    if (ApiConfig.isDevelopment) {
      print('❌ API Error: $error');
    }
  }
}
