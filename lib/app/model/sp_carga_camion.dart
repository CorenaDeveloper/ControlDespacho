class DespachoResponse {
  final bool success;
  final String message;
  final List<SesionDespacho> data;
  final ResponseMetadata? metadata;

  DespachoResponse({
    required this.success,
    required this.message,
    required this.data,
    this.metadata,
  });

  factory DespachoResponse.fromJson(Map<String, dynamic> json) {
    try {
      return DespachoResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: (json['data'] as List<dynamic>?)
                ?.map((item) => SesionDespacho.fromJson(item))
                .toList() ??
            [],
        metadata: json['metadata'] != null
            ? ResponseMetadata.fromJson(json['metadata'])
            : null,
      );
    } catch (e) {
      print('❌ Error parsing DespachoResponse: $e');
      return DespachoResponse(
        success: false,
        message: 'Error parsing response',
        data: [],
        metadata: null,
      );
    }
  }
}

class ResponseMetadata {
  final String timestamp;
  final String environment;
  final String version;
  final String endpoint;
  final String method;
  final int statusCode;

  ResponseMetadata({
    required this.timestamp,
    required this.environment,
    required this.version,
    required this.endpoint,
    required this.method,
    required this.statusCode,
  });

  factory ResponseMetadata.fromJson(Map<String, dynamic> json) {
    return ResponseMetadata(
      timestamp: json['timestamp']?.toString() ?? '',
      environment: json['environment']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      endpoint: json['endpoint']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 0,
    );
  }
}

class SesionDespacho {
  final int? id;
  final String? idRuta;
  final String? codigoUser;
  final DateTime? fechaInicio;
  final DateTime? fechaFinalizacion;
  final String? estadoSesion;
  final int? totalProductosRuta;
  final int? totalProductosProcesados;
  final double? totalCajasRuta;
  final double? totalCajasProcesadas;
  final String? observacionesGenerales;
  final int? productosConProblemas;

  SesionDespacho(
      {this.id,
      this.idRuta,
      this.codigoUser,
      this.fechaInicio,
      this.fechaFinalizacion,
      this.estadoSesion,
      this.totalProductosRuta,
      this.totalProductosProcesados,
      this.totalCajasRuta,
      this.totalCajasProcesadas,
      this.observacionesGenerales,
      this.productosConProblemas});

  factory SesionDespacho.fromJson(Map<String, dynamic> json) {
    try {
      return SesionDespacho(
          id: (json['id'] as num?)?.toInt(),
          idRuta: json['iD_RUTA']?.toString(),
          codigoUser: json['codigO_USER']?.toString(),
          fechaInicio: _parseDateTime(json['fechA_INICIO']),
          fechaFinalizacion: _parseDateTime(json['fechA_FINALIZACION']),
          estadoSesion: json['estadO_SESION']?.toString(),
          totalProductosRuta: (json['totaL_PRODUCTOS_RUTA'] as num?)?.toInt(),
          totalProductosProcesados:
              (json['totaL_PRODUCTOS_PROCESADOS'] as num?)?.toInt(),
          totalCajasRuta: (json['totaL_CAJAS_RUTA'] as num?)?.toDouble(),
          totalCajasProcesadas:
              (json['totaL_CAJAS_PROCESADAS'] as num?)?.toDouble(),
          observacionesGenerales: json['observacioneS_GENERALES']?.toString());
    } catch (e) {
      print('❌ Error parsing SesionDespacho: $e');
      return SesionDespacho();
    }
  }

  // Helper method para parsear fechas de manera segura
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      print('❌ Error parsing datetime: $value - $e');
      return null;
    }
  }

  // Propiedades computadas
  bool get esActivo =>
      estadoSesion?.toUpperCase() == 'EN_PROCESO' ||
      estadoSesion?.toUpperCase() == 'ACTIVO';

  bool get esFinalizado => estadoSesion?.toUpperCase() == 'FINALIZADA';

  String get estadoDescripcion {
    switch (estadoSesion?.toUpperCase()) {
      case 'EN_PROCESO':
        return 'En Proceso';
      case 'ACTIVO':
        return 'Activo';
      case 'PAUSADO':
        return 'Pausado';
      case 'FINALIZADA':
        return 'Finalizado';
      default:
        return 'Desconocido';
    }
  }

  @override
  String toString() {
    return 'SesionDespacho{id: $id, idRuta: $idRuta, estadoSesion: $estadoSesion}';
  }
}
