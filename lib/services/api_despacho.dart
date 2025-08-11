import 'package:get/get.dart';
import 'api_service.dart';
import 'api_response.dart';
import 'dart:convert';

class DespachoService extends GetxService {
  static DespachoService get instance => Get.find<DespachoService>();

  final ApiService _apiService = ApiService.instance;

  Future<ApiResponse<Map<String, dynamic>>> iniciarSesion({
    required String idRuta,
    required String codigoUser,
    required String productosRutaJson,
    String? observacionesIniciales,
  }) async {
    try {
      try {
        final parsed = jsonDecode(productosRutaJson);
      } catch (e) {
        print('❌ JSON inválido: $e');
        return ApiResponse.error(
          message: 'JSON de productos inválido: $e',
          details: 'Error',
          statusCode: -1,
        );
      }

      final requestBody = {
        'idRuta': idRuta,
        'codigoUser': codigoUser,
        'productosRuta': productosRutaJson,
        if (observacionesIniciales != null)
          'observacionesIniciales': observacionesIniciales,
      };
      final response = await _apiService.post<Map<String, dynamic>>(
        'DS_PORTAL_DTRACK_Hoja_Despacho_SV/IniciarSesion',
        body: requestBody,
        useAuthHeaders: true,
      );

      if (response.isSuccess) {
        return response;
      } else {
        print('❌ Error al iniciar sesión: ${response.message}');
        return response;
      }
    } catch (e) {
      print('❌ Error inesperado al iniciar sesión: $e');
      return ApiResponse.error(
        message: 'Error inesperado al iniciar sesión: $e',
        details: 'Error',
        statusCode: -1,
      );
    }
  }

  /// Obtener productos de sesión
  Future<ApiResponse<Map<String, dynamic>>> obtenerProductosSesion(
      int idSesion) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        'DS_PORTAL_DTRACK_Productos_Despacho/ObtenerProductosSesion/$idSesion',
        useAuthHeaders: true,
      );

      if (response.isSuccess) {
        return response;
      } else {
        print('❌ Error al obtener productos: ${response.message}');
        return response;
      }
    } catch (e) {
      print('❌ Error inesperado al obtener productos: $e');
      return ApiResponse.error(
        message: 'Error inesperado al obtener productos: $e',
        details: 'Error',
        statusCode: -1,
      );
    }
  }

  /// Finalizar sesión de despacho
  Future<ApiResponse<Map<String, dynamic>>> finalizarSesion({
    required int idSesion,
    String? observacionesGenerales,
  }) async {
    try {
      final requestBody = {
        'id': idSesion,
        if (observacionesGenerales != null)
          'observacionesGenerales': observacionesGenerales,
      };

      final response = await _apiService.put<Map<String, dynamic>>(
        'DS_PORTAL_DTRACK_Hoja_Despacho_SV/FinalizarSesion/$idSesion',
        body: requestBody,
        useAuthHeaders: true,
      );

      if (response.isSuccess) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      print('❌ Error inesperado al finalizar sesión: $e');
      return ApiResponse.error(
        message: 'Error inesperado al finalizar sesión: $e',
        details: 'Error',
        statusCode: -1,
      );
    }
  }

  /// Obtener estado de sesión
  Future<ApiResponse<Map<String, dynamic>>> obtenerEstadoSesion(
      int idSesion) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        'DS_PORTAL_DTRACK_Productos_Despacho/ObtenerEstadoSesion/$idSesion',
        useAuthHeaders: true,
      );

      if (response.isSuccess) {
        return response;
      } else {
        print('❌ Error al obtener estado: ${response.message}');
        return response;
      }
    } catch (e) {
      print('❌ Error inesperado al obtener estado: $e');
      return ApiResponse.error(
        message: 'Error inesperado al obtener estado: $e',
        details: 'Error',
        statusCode: -1,
      );
    }
  }
}
