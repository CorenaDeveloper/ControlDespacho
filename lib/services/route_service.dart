import 'package:get/get.dart';
import 'api_service.dart';
import 'api_response.dart';

class RouteService extends GetxService {
  static RouteService get instance => Get.find<RouteService>();

  final ApiService _apiService = ApiService.instance;

  /// Obtener historial de despachos por usuario
  /// @param codigoUser: Código del usuario
  /// @param estado: 1=Activos, 2=Finalizados, 3=Todos
  Future<ApiResponse<Map<String, dynamic>>> getDespachoHistory({
    required String codigoUser,
    required int estado,
  }) async {
    try {
      // Construir el endpoint
      final endpoint =
          'DS_PORTAL_DTRACK_Hoja_Despacho_SV/Session_Despacho_Usuario';

      // Parámetros de consulta el codigo de usuario
      // muestra solo las creadas por ese usuario en el dia
      final queryParams = {
        'codigoUser': codigoUser,
        'estado': estado.toString(),
      };

      // Realizar petición GET
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: queryParams,
        useAuthHeaders: true,
      );

      if (response.isSuccess) {
        return response;
      } else {
        print('❌ Error al obtener historial: ${response.message}');
        return response;
      }
    } catch (e) {
      print('❌ Error inesperado en getDespachoHistory: $e');
      return ApiResponse.error(
        message: 'Error inesperado al obtener historial: $e',
        details: 'Error',
        statusCode: -1,
      );
    }
  }

  /// Obtener una session unica
  /// @param codigoUser: id ruta
  Future<ApiResponse<Map<String, dynamic>>> getSessionDespachoUnica({
    required String idRuta,
  }) async {
    try {
      final endpoint =
          'DS_PORTAL_DTRACK_Hoja_Despacho_SV/Session_Despacho_Usuario_Unica';
      final queryParams = {
        'idRuta': idRuta,
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: queryParams,
        useAuthHeaders: true,
      );

      if (response.isSuccess) {
      } else {
        print('❌ Error al obtener sesión única: ${response.message}');
      }

      return response;
    } catch (e) {
      print('❌ Error inesperado al obtener sesión única: $e');
      return ApiResponse.error(
        message: 'Error inesperado al buscar la ruta: $e',
        details: 'Error',
        statusCode: -1,
      );
    }
  }

// Agregar este método a la clase RouteService en route_service.dart

  /// Obtener consolidados de despacho
  Future<ApiResponse<Map<String, dynamic>>> getConsolidados({
    required String fechaInicio,
    required String fechaFin,
    String? estado,
    String? bodega,
    String? idConsolidado,
  }) async {
    try {
      // Construir el endpoint
      final endpoint =
          'DS_PORTAL_DTRACK_Hoja_Despacho_SV/USP_GET_CONSOLIDADOS_DESPACHO';

      // Parámetros de consulta
      final queryParams = <String, String>{
        'fechaInicio': fechaInicio,
        'fechaFin': fechaFin,
      };

      // Agregar parámetros opcionales solo si no son null
      if (estado != null && estado.isNotEmpty) {
        queryParams['estado'] = estado;
      }
      if (bodega != null && bodega.isNotEmpty) {
        queryParams['bodega'] = bodega;
      }
      if (idConsolidado != null && idConsolidado.isNotEmpty) {
        queryParams['id_consolidado'] = idConsolidado;
      }

      print('🔍 Consultando consolidados con parámetros: $queryParams');

      // Realizar petición GET
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: queryParams,
        useAuthHeaders: true,
      );

      if (response.isSuccess) {
        print('✅ Consolidados obtenidos exitosamente');
        return response;
      } else {
        print('❌ Error al obtener consolidados: ${response.message}');
        return response;
      }
    } catch (e) {
      print('❌ Error inesperado al obtener consolidados: $e');
      return ApiResponse.error(
        message: 'Error inesperado al obtener consolidados: $e',
        details: 'Error',
        statusCode: -1,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getConsolidadoDetalle({
    required int idConsolidado,
  }) async {
    try {
      final endpoint =
          'DS_PORTAL_DTRACK_Hoja_Despacho_SV/USP_GET_DETALLE_CONSOLIDADO_DESPACHO';
      final queryParams = {
        'id_Consolidado': idConsolidado.toString(),
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: queryParams,
        useAuthHeaders: true,
      );

      if (response.isSuccess) {
        return response;
      } else {
        print('❌ Error al obtener detalle consolidado: ${response.message}');
        return response;
      }
    } catch (e) {
      print('❌ Error inesperado al obtener detalle consolidado: $e');
      return ApiResponse.error(
        message: 'Error inesperado al obtener detalle del consolidado: $e',
        details: 'Error',
        statusCode: -1,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> procesarProductoConsolidado({
    required int idConsolidado,
    required String idProducto,
    required String codigoBarra,
    required num cantidadProcesada,
    String? observaciones,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        'DS_PORTAL_DTRACK_Hoja_Despacho_SV/ProcesarEscaneoConsolidado',
        body: {
          'idSesionConsolidado': idConsolidado,
          'itemId': idProducto,
          'lote': codigoBarra,
          'cantidadPreparada': cantidadProcesada,
          if (observaciones != null && observaciones.isNotEmpty)
            'observaciones': observaciones,
        },
        useAuthHeaders: true,
      );

      if (response.isSuccess) {
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Error inesperado al procesar producto: $e',
        details: 'Error',
        statusCode: -1,
      );
    }
  }

  /// Buscar hoja de despacho por ID de ruta
  Future<ApiResponse<Map<String, dynamic>>> getRouteDispatch({
    required String routeId,
  }) async {
    try {
      // Construir el endpoint
      final endpoint = 'DS_PORTAL_DTRACK_Hoja_Despacho_SV/Hoja_Despacho';

      // Parámetros de consulta
      final queryParams = {
        'idrouta': routeId,
      };
      // Realizar petición GET
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: queryParams,
        useAuthHeaders: true,
      );

      if (response.isSuccess) {
        return _processRouteResponse(response);
      } else {
        return response;
      }
    } catch (e) {
      print('❌ Error en búsqueda de ruta: $e');
      return ApiResponse.error(
        message: 'Error inesperado al buscar la ruta: $e',
        details: 'Error',
        statusCode: -1,
      );
    }
  }

  /// Procesar respuesta de la ruta
  ApiResponse<Map<String, dynamic>> _processRouteResponse(
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

      // Verificar si tiene la estructura esperada
      final success = data['success'];
      final dataList = data['data'];

      if (success == true && dataList is List) {
        return ApiResponse.success(
          data: data,
          statusCode: response.statusCode,
          message: 'Hoja de despacho obtenida exitosamente',
        );
      } else {
        return ApiResponse.error(
          message: 'No se encontraron productos para esta ruta',
          details: 'Error',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Error al procesar respuesta de la ruta: $e',
        details: 'Error',
        statusCode: response.statusCode,
      );
    }
  }

  /// Procesar escaneo de producto
  Future<ApiResponse<Map<String, dynamic>>> procesarEscaneoProducto({
    required int idSesion,
    required String itemId,
    required String lote,
    required int cantidadCargada,
    String? observaciones,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        'DS_PORTAL_DTRACK_Hoja_Despacho_SV/ProcesarEscaneoProducto',
        body: {
          'idSesion': idSesion,
          'itemId': itemId,
          'lote': lote,
          'cantidadCargada': cantidadCargada,
          if (observaciones != null && observaciones.isNotEmpty)
            'observaciones': observaciones,
        },
        useAuthHeaders: true,
      );
      if (response.isSuccess) {
        return response;
      } else {
        print('❌ Error al procesar escaneo: ${response.message}');
        return response;
      }
    } catch (e) {
      print('❌ Error inesperado al procesar escaneo: $e');
      return ApiResponse.error(
        message: 'Error inesperado al procesar escaneo: $e',
        details: 'Error',
        statusCode: -1,
      );
    }
  }

  /// Marcar producto con problema
  Future<ApiResponse<Map<String, dynamic>>> marcarProblema({
    required int idDetalle,
    required bool tieneProblemas,
    String? descripcionProblema,
    String? observaciones,
  }) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        'DS_PORTAL_DTRACK_Productos_Despacho/MarcarProblema',
        body: {
          'idDetalle': idDetalle,
          'tieneProblemas': tieneProblemas,
          if (descripcionProblema != null && descripcionProblema.isNotEmpty)
            'descripcionProblema': descripcionProblema,
          if (observaciones != null && observaciones.isNotEmpty)
            'observaciones': observaciones,
        },
        useAuthHeaders: true,
      );

      if (response.isSuccess) {
        return response;
      } else {
        print('❌ Error al marcar problema: ${response.message}');
        return response;
      }
    } catch (e) {
      print('❌ Error inesperado al marcar problema: $e');
      return ApiResponse.error(
        message: 'Error inesperado al marcar problema: $e',
        details: 'Error',
        statusCode: -1,
      );
    }
  }

  /// Obtener resumen de la ruta
  RouteInfo getRouteSummary(Map<String, dynamic> routeData) {
    try {
      final dataList = routeData['data'] as List;

      double totalKilogramos = 0;
      double totalToneladas = 0;
      int totalUnidades = 0;
      double totalBoxes = 0;

      for (var item in dataList) {
        totalKilogramos += _toDouble(item['kilogramos']);
        totalToneladas += _toDouble(item['toneladas']);
        final unidades = _toInt(item['unidades']);
        totalUnidades += unidades;
        final factor = _toInt(item['factor']);
        if (factor > 0) {
          final cajasCalculadas = unidades / factor.toDouble();
          totalBoxes += cajasCalculadas;
        } else {
          totalBoxes += _toDouble(item['boX_ROUND']);
        }
      }

      return RouteInfo(
        totalItems: dataList.length,
        totalKilogramos: totalKilogramos,
        totalToneladas: totalToneladas,
        totalUnidades: totalUnidades,
        totalBoxes: totalBoxes, // Ahora incluye el cálculo correcto
        products: dataList.map((item) => ProductInfo.fromJson(item)).toList(),
      );
    } catch (e) {
      throw Exception('Error al procesar resumen de ruta: $e');
    }
  }

  /// Helper para convertir a double de forma segura
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Helper para convertir a int de forma segura
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round(); // Redondear si es double
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

/// Modelo para información de la ruta
class RouteInfo {
  final int totalItems;
  final double totalKilogramos;
  final double totalToneladas;
  final num totalUnidades;
  final double totalBoxes;
  final List<ProductInfo> products;

  RouteInfo({
    required this.totalItems,
    required this.totalKilogramos,
    required this.totalToneladas,
    required this.totalUnidades,
    required this.totalBoxes,
    required this.products,
  });
}

/// Modelo para información del producto
class ProductInfo {
  final int boxRound;
  final double box;
  final String lote;
  final int unidades;
  final DateTime? vencimiento;
  final String itemId;
  final String itemName;
  final double libras;
  final double kilogramos;
  final double toneladas;
  final double mt3Cubicos;
  final double diferencia;
  final int factor;
  final String bodega;
  final String adtcodigobarra;
  final String adtduN14;

  ProductInfo(
      {required this.boxRound,
      required this.box,
      required this.lote,
      required this.unidades,
      this.vencimiento,
      required this.itemId,
      required this.itemName,
      required this.libras,
      required this.kilogramos,
      required this.toneladas,
      required this.mt3Cubicos,
      required this.diferencia,
      required this.factor,
      required this.bodega,
      required this.adtcodigobarra,
      required this.adtduN14});

  // 🆕 NUEVA PROPIEDAD COMPUTADA: Calcular cajas reales usando factor
  double get cajasCalculadas {
    if (factor > 0) {
      return unidades / factor.toDouble();
    }
    return box; // Fallback al valor original si no hay factor
  }

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    DateTime? vencimiento;
    try {
      final vencimientoStr = json['vencimiento'];
      if (vencimientoStr != null && vencimientoStr != '1900-01-01T00:00:00') {
        vencimiento = DateTime.parse(vencimientoStr);
      }
    } catch (e) {
      // Si hay error al parsear la fecha, se deja como null
    }

    return ProductInfo(
        boxRound: _safeToInt(json['boX_ROUND']),
        box: _safeToDouble(json['box']),
        lote: json['lote']?.toString() ?? '',
        unidades: _safeToInt(json['unidades']),
        vencimiento: vencimiento,
        itemId: json['itemid']?.toString() ?? '',
        itemName: json['itemname']?.toString() ?? '',
        libras: _safeToDouble(json['libras']),
        kilogramos: _safeToDouble(json['kilogramos']),
        toneladas: _safeToDouble(json['toneladas']),
        mt3Cubicos: _safeToDouble(json['mT3CUBICOS']),
        diferencia: _safeToDouble(json['diferencia']),
        factor: _safeToInt(json['factor']),
        bodega: json['bodega']?.toString() ?? '',
        adtcodigobarra: json['adtcodigobarra']?.toString() ?? '',
        adtduN14: json['adtduN14']?.toString() ?? '');
  }

  /// Helper estático para convertir a double de forma segura
  static double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// Helper estático para convertir a int de forma segura
  static int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final doubleValue = double.tryParse(value);
      if (doubleValue != null) {
        return doubleValue.round();
      }
      return int.tryParse(value) ?? 0;
    }
    final doubleValue = double.tryParse(value.toString());
    if (doubleValue != null) {
      return doubleValue.round();
    }
    return 0;
  }

  /// Indica si el producto está próximo a vencer (menos de 30 días)
  bool get isNearExpiry {
    if (vencimiento == null) return false;
    final now = DateTime.now();
    final difference = vencimiento!.difference(now).inDays;
    return difference <= 30 && difference >= 0;
  }

  /// Indica si el producto está vencido
  bool get isExpired {
    if (vencimiento == null) return false;
    return vencimiento!.isBefore(DateTime.now());
  }
}
