import 'package:get/get.dart';
import 'api_service.dart';
import 'api_response.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.find<AuthService>();

  final ApiService _apiService = ApiService.instance;

  /// Realizar login con usuario y contraseña
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String username,
    required String password,
  }) async {
    try {
      // Codificar la contraseña para URL (reemplazar caracteres especiales)
      final encodedPassword = Uri.encodeComponent(password);

      // Construir el endpoint con parámetros
      final endpoint = 'DS_Seguridad_Procedures/USP_LOGIN_PORTAL_APP_CORE';

      // Parámetros de consulta
      final queryParams = {
        'nameUser': username,
        'pass': encodedPassword,
      };

      // Realizar petición GET
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: queryParams,
        useAuthHeaders: true,
      );

      if (response.isSuccess) {
        return _processLoginResponse(response);
      } else {
        print('❌ Login fallido: ${response.message}');
        return response;
      }
    } catch (e) {
      print('❌ Error en login: $e');
      return ApiResponse.error(
        message: 'Error inesperado en el login: $e',
        details: 'Error',
        statusCode: -1,
      );
    }
  }

  /// Procesar respuesta del login
  ApiResponse<Map<String, dynamic>> _processLoginResponse(
      ApiResponse<Map<String, dynamic>> response) {
    try {
      final data = response.data;

      if (data == null) {
        return ApiResponse.error(
          message: 'Respuesta vacía del servidor',
          details: 'Error',
          statusCode: response.statusCode,
        );
      }

      final dataList = data['data'];
      if (dataList is List && dataList.isNotEmpty) {
        final firstItem = dataList.first;
        final errorMessage = firstItem['erroR_MESSAGE'];
        final errorNumber = firstItem['erroR_NUMBER'];

        if (errorNumber != null && errorNumber != 0) {
          return ApiResponse.error(
            message: errorMessage ?? 'Error en las credenciales',
            details: 'Error',
            statusCode: response.statusCode,
          );
        }

        // Si llegó aquí, es un login exitoso
        return ApiResponse.success(
          data: data,
          statusCode: response.statusCode,
          message: 'Login exitoso',
        );
      } else {
        return ApiResponse.error(
          message: 'Formato de respuesta inesperado',
          details: 'Error',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Error al procesar respuesta del login: $e',
        details: 'Error',
        statusCode: response.statusCode,
      );
    }
  }

  /// Logout (si es necesario)
  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    try {
      // Implementar logout si tu API lo requiere
      // Por ahora solo limpiamos datos locales

      return ApiResponse.success(
        data: {'message': 'Logout exitoso'},
        statusCode: 200,
        message: 'Sesión cerrada correctamente',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Error al cerrar sesión: $e',
        details: 'Error',
        statusCode: -1,
      );
    }
  }

  /// Validar token (si tu API usa tokens)
  Future<ApiResponse<Map<String, dynamic>>> validateToken(String token) async {
    try {
      // Implementar validación de token si es necesario
      // Por ahora retornamos éxito por defecto

      return ApiResponse.success(
        data: {'valid': true},
        statusCode: 200,
        message: 'Token válido',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Error al validar token: $e',
        details: 'Error',
        statusCode: -1,
      );
    }
  }
}
