import 'dart:convert';

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
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;
  final double? porcentajeCompletado;
  final double? porcentajeCajasCompletado;
  final String? detalleProductosJson;
  final int? totalProductosDetalle;
  final int? productosCompletados;
  final int? productosConProblemas;
  final int? errorNumber;
  final String? errorMessage;

  SesionDespacho({
    this.id,
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
    this.fechaCreacion,
    this.fechaActualizacion,
    this.porcentajeCompletado,
    this.porcentajeCajasCompletado,
    this.detalleProductosJson,
    this.totalProductosDetalle,
    this.productosCompletados,
    this.productosConProblemas,
    this.errorNumber,
    this.errorMessage,
  });

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
        observacionesGenerales: json['observacioneS_GENERALES']?.toString(),
        fechaCreacion: _parseDateTime(json['fechA_CREACION']),
        fechaActualizacion: _parseDateTime(json['fechA_ACTUALIZACION']),
        porcentajeCompletado:
            (json['porcentajE_COMPLETADO'] as num?)?.toDouble(),
        porcentajeCajasCompletado:
            (json['porcentajE_CAJAS_COMPLETADO'] as num?)?.toDouble(),
        detalleProductosJson: json['detallE_PRODUCTOS']?.toString(),
        totalProductosDetalle:
            (json['totaL_PRODUCTOS_DETALLE'] as num?)?.toInt(),
        productosCompletados: (json['productoS_COMPLETADOS'] as num?)?.toInt(),
        productosConProblemas:
            (json['productoS_CON_PROBLEMAS'] as num?)?.toInt(),
        errorNumber: (json['erroR_NUMBER'] as num?)?.toInt(),
        errorMessage: json['erroR_MESSAGE']?.toString(),
      );
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

  bool get tieneErrores => (errorNumber ?? 0) > 0;

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

  List<DetalleProducto> get detalleProductos {
    if (detalleProductosJson == null || detalleProductosJson!.isEmpty) {
      return [];
    }

    try {
      // Verificar si ya es una lista de objetos o un string JSON
      dynamic jsonData;
      if (detalleProductosJson is String) {
        jsonData = jsonDecode(detalleProductosJson!);
      } else {
        jsonData = detalleProductosJson;
      }

      if (jsonData is List) {
        return jsonData
            .map((item) => DetalleProducto.fromJson(item))
            .where(
                (producto) => producto.id != null) // Filtrar productos válidos
            .toList();
      } else {
        print('❌ detallE_PRODUCTOS no es una lista: ${jsonData.runtimeType}');
        return [];
      }
    } catch (e) {
      print('❌ Error parsing detalle productos: $e');
      print('❌ JSON problemático: $detalleProductosJson');
      return [];
    }
  }

  Duration? get tiempoTranscurrido {
    if (fechaInicio == null) return null;
    final fechaFin = fechaFinalizacion ?? DateTime.now();
    return fechaFin.difference(fechaInicio!);
  }

  String get tiempoTranscurridoTexto {
    final tiempo = tiempoTranscurrido;
    if (tiempo == null) return 'N/A';

    final horas = tiempo.inHours;
    final minutos = tiempo.inMinutes.remainder(60);

    if (horas > 0) {
      return '${horas}h ${minutos}m';
    } else {
      return '${minutos}m';
    }
  }

  @override
  String toString() {
    return 'SesionDespacho{id: $id, idRuta: $idRuta, estadoSesion: $estadoSesion, productos: ${detalleProductos.length}}';
  }
}

class DetalleProducto {
  final int? id;
  final int? idSesionDespacho;
  final String? itemId;
  final String? codigoBarra;
  final String? nombreProducto;
  final int? factor;
  final String? lote;
  final DateTime? fechaVencimiento;
  final int? unidadesRuta;
  final double? cajasRuta;
  final double? kilogramosRuta;
  final int? unidadesProcesadas;
  final double? cajasProcesadas;
  final double? kilogramosProcesados;
  final String? estadoProducto;
  final DateTime? tiempoInicioEscaneo;
  final DateTime? tiempoFinEscaneo;
  final int? cantidadEscaneos;
  final String? observaciones;
  final bool? tieneProblemas;
  final String? descripcionProblema;
  final DateTime? detalleFechaCreacion;
  final DateTime? detalleFechaActualizacion;
  final double? porcentajeUnidadesProcesadas;
  final double? porcentajeCajasProcesadas;
  final int? tiempoProcesamintoMinutos;

  DetalleProducto({
    this.id,
    this.idSesionDespacho,
    this.itemId,
    this.codigoBarra,
    this.nombreProducto,
    this.factor,
    this.lote,
    this.fechaVencimiento,
    this.unidadesRuta,
    this.cajasRuta,
    this.kilogramosRuta,
    this.unidadesProcesadas,
    this.cajasProcesadas,
    this.kilogramosProcesados,
    this.estadoProducto,
    this.tiempoInicioEscaneo,
    this.tiempoFinEscaneo,
    this.cantidadEscaneos,
    this.observaciones,
    this.tieneProblemas,
    this.descripcionProblema,
    this.detalleFechaCreacion,
    this.detalleFechaActualizacion,
    this.porcentajeUnidadesProcesadas,
    this.porcentajeCajasProcesadas,
    this.tiempoProcesamintoMinutos,
  });

  factory DetalleProducto.fromJson(Map<String, dynamic> json) {
    try {
      return DetalleProducto(
        id: (json['ID'] as num?)?.toInt(),
        idSesionDespacho: (json['ID_SESION_DESPACHO'] as num?)?.toInt(),
        itemId: json['ITEM_ID']?.toString(),
        codigoBarra: json['CODIGO_BARRA']?.toString(),
        nombreProducto: json['NOMBRE_PRODUCTO']?.toString(),
        factor: (json['FACTOR'] as num?)?.toInt(),
        lote: json['LOTE']?.toString(),
        fechaVencimiento: _parseDateTime(json['FECHA_VENCIMIENTO']),
        unidadesRuta: (json['UNIDADES_RUTA'] as num?)?.toInt(),
        cajasRuta: (json['CAJAS_RUTA'] as num?)?.toDouble(),
        kilogramosRuta: (json['KILOGRAMOS_RUTA'] as num?)?.toDouble(),
        unidadesProcesadas: (json['UNIDADES_PROCESADAS'] as num?)?.toInt(),
        cajasProcesadas: (json['CAJAS_PROCESADAS'] as num?)?.toDouble(),
        kilogramosProcesados:
            (json['KILOGRAMOS_PROCESADOS'] as num?)?.toDouble(),
        estadoProducto: json['ESTADO_PRODUCTO']?.toString(),
        tiempoInicioEscaneo: _parseDateTime(json['TIEMPO_INICIO_ESCANEO']),
        tiempoFinEscaneo: _parseDateTime(json['TIEMPO_FIN_ESCANEO']),
        cantidadEscaneos: (json['CANTIDAD_ESCANEOS'] as num?)?.toInt(),
        observaciones: json['OBSERVACIONES']?.toString(),
        tieneProblemas: json['TIENE_PROBLEMAS'] as bool?,
        descripcionProblema: json['DESCRIPCION_PROBLEMA']?.toString(),
        detalleFechaCreacion: _parseDateTime(json['DETALLE_FECHA_CREACION']),
        detalleFechaActualizacion:
            _parseDateTime(json['DETALLE_FECHA_ACTUALIZACION']),
        porcentajeUnidadesProcesadas:
            (json['PORCENTAJE_UNIDADES_PROCESADAS'] as num?)?.toDouble(),
        porcentajeCajasProcesadas:
            (json['PORCENTAJE_CAJAS_PROCESADAS'] as num?)?.toDouble(),
        tiempoProcesamintoMinutos:
            (json['TIEMPO_PROCESAMIENTO_MINUTOS'] as num?)?.toInt(),
      );
    } catch (e) {
      print('❌ Error parsing DetalleProducto: $e');
      print('❌ JSON problemático: $json');
      return DetalleProducto(); // Retorna instancia vacía en caso de error
    }
  }

  // Helper method para parsear fechas de manera segura
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  // Propiedades computadas con valores por defecto seguros
  bool get estaCompletado =>
      (estadoProducto?.toUpperCase() ?? '') == 'FINALIZADA';
  bool get estaPendiente =>
      (estadoProducto?.toUpperCase() ?? '') == 'PENDIENTE';
  bool get estaEnProceso =>
      (estadoProducto?.toUpperCase() ?? '') == 'EN_PROCESO';

  String get estadoDescripcion {
    switch (estadoProducto?.toUpperCase()) {
      case 'FINALIZADA':
        return 'Finalizado';
      case 'PENDIENTE':
        return 'Pendiente';
      case 'EN_PROCESO':
        return 'En Proceso';
      case 'PROBLEMA':
        return 'Con Problema';
      default:
        return 'Sin Estado';
    }
  }

  // Métodos de validación seguros
  double get progreso {
    final total = unidadesRuta ?? 0;
    final procesadas = unidadesProcesadas ?? 0;
    if (total <= 0) return 0.0;
    return (procesadas / total).clamp(0.0, 1.0);
  }

  bool get puedeSerCompletado {
    final total = unidadesRuta ?? 0;
    final procesadas = unidadesProcesadas ?? 0;
    return procesadas >= total && !estaCompletado;
  }

  bool get necesitaProcesamiento {
    final total = unidadesRuta ?? 0;
    final procesadas = unidadesProcesadas ?? 0;
    return procesadas < total && !estaCompletado;
  }

  @override
  String toString() {
    return 'DetalleProducto{id: $id, itemId: $itemId, nombreProducto: $nombreProducto, estadoProducto: $estadoProducto}';
  }
}
