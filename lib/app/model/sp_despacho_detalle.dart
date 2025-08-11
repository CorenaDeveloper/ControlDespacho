import 'dart:convert';

class SPDespachoDetalleResponse {
  final bool success;
  final String message;
  final List<SPDespachoDetalle> data;
  final ResponseMetadata? metadata;

  SPDespachoDetalleResponse({
    required this.success,
    required this.message,
    required this.data,
    this.metadata,
  });

  factory SPDespachoDetalleResponse.fromJson(Map<String, dynamic> json) {
    try {
      return SPDespachoDetalleResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: (json['data'] as List<dynamic>?)
                ?.map((item) => SPDespachoDetalle.fromJson(item))
                .toList() ??
            [],
        metadata: json['metadata'] != null
            ? ResponseMetadata.fromJson(json['metadata'])
            : null,
      );
    } catch (e) {
      print('❌ Error parsing SPDespachoDetalleResponse: $e');
      return SPDespachoDetalleResponse(
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

class SPDespachoDetalle {
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

  SPDespachoDetalle({
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

  factory SPDespachoDetalle.fromJson(Map<String, dynamic> json) {
    try {
      return SPDespachoDetalle(
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
      print('❌ Error parsing SPDespachoDetalle: $e');
      return SPDespachoDetalle();
    }
  }

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

  bool get esFinalizado =>
      estadoSesion?.toUpperCase() == 'FINALIZADO' ||
      estadoSesion?.toUpperCase() == 'COMPLETADO';

  bool get tieneErrores => (errorNumber ?? 0) > 0;

  String get estadoDescripcion {
    switch (estadoSesion?.toUpperCase()) {
      case 'EN_PROCESO':
        return 'En Proceso';
      case 'ACTIVO':
        return 'Activo';
      case 'PAUSADO':
        return 'Pausado';
      case 'FINALIZADO':
        return 'Finalizado';
      case 'COMPLETADO':
        return 'Completado';
      default:
        return 'Desconocido';
    }
  }

  List<SPProductoDetalle> get productos {
    if (detalleProductosJson == null || detalleProductosJson!.isEmpty) {
      return [];
    }

    try {
      dynamic jsonData;
      if (detalleProductosJson is String) {
        jsonData = jsonDecode(detalleProductosJson!);
      } else {
        jsonData = detalleProductosJson;
      }

      if (jsonData is List) {
        return jsonData
            .map((item) => SPProductoDetalle.fromJson(item))
            .where((producto) => producto.id != null)
            .toList();
      } else {
        print('❌ detallE_PRODUCTOS no es una lista: ${jsonData.runtimeType}');
        return [];
      }
    } catch (e) {
      print('❌ Error parsing productos: $e');
      return [];
    }
  }

  Duration? get tiempoTranscurrido {
    if (fechaInicio == null) return null;
    final fechaFin = fechaFinalizacion ?? DateTime.now();
    return fechaFin.difference(fechaInicio!);
  }

  String get tiempoTexto {
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
    return 'SPDespachoDetalle{id: $id, idRuta: $idRuta, estado: $estadoSesion, productos: ${productos.length}}';
  }
}

class SPProductoDetalle {
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
  final int? cantidadEscaneos;
  final bool? tieneProblemas;
  final DateTime? detalleFechaCreacion;
  final DateTime? detalleFechaActualizacion;
  final double? porcentajeUnidadesProcesadas;
  final double? porcentajeCajasProcesadas;

  SPProductoDetalle({
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
    this.cantidadEscaneos,
    this.tieneProblemas,
    this.detalleFechaCreacion,
    this.detalleFechaActualizacion,
    this.porcentajeUnidadesProcesadas,
    this.porcentajeCajasProcesadas,
  });

  factory SPProductoDetalle.fromJson(Map<String, dynamic> json) {
    try {
      return SPProductoDetalle(
        id: (json['ID'] as num?)?.toInt(),
        idSesionDespacho: (json['ID_SESION_DESPACHO'] as num?)?.toInt(),
        itemId: json['ITEM_ID']?.toString(),
        codigoBarra: json['CODIGO_BARRA']?.toString(),
        nombreProducto: json['NOMBRE_PRODUCTO']?.toString(),
        factor: (json['FACTOR'] as num?)?.toInt(),
        lote: json['LOTE']?.toString(),
        fechaVencimiento:
            SPDespachoDetalle._parseDateTime(json['FECHA_VENCIMIENTO']),
        unidadesRuta: (json['UNIDADES_RUTA'] as num?)?.toInt(),
        cajasRuta: (json['CAJAS_RUTA'] as num?)?.toDouble(),
        kilogramosRuta: (json['KILOGRAMOS_RUTA'] as num?)?.toDouble(),
        unidadesProcesadas: (json['UNIDADES_PROCESADAS'] as num?)?.toInt(),
        cajasProcesadas: (json['CAJAS_PROCESADAS'] as num?)?.toDouble(),
        kilogramosProcesados:
            (json['KILOGRAMOS_PROCESADOS'] as num?)?.toDouble(),
        estadoProducto: json['ESTADO_PRODUCTO']?.toString(),
        cantidadEscaneos: (json['CANTIDAD_ESCANEOS'] as num?)?.toInt(),
        tieneProblemas: json['TIENE_PROBLEMAS'] as bool?,
        detalleFechaCreacion:
            SPDespachoDetalle._parseDateTime(json['DETALLE_FECHA_CREACION']),
        detalleFechaActualizacion: SPDespachoDetalle._parseDateTime(
            json['DETALLE_FECHA_ACTUALIZACION']),
        porcentajeUnidadesProcesadas:
            (json['PORCENTAJE_UNIDADES_PROCESADAS'] as num?)?.toDouble(),
        porcentajeCajasProcesadas:
            (json['PORCENTAJE_CAJAS_PROCESADAS'] as num?)?.toDouble(),
      );
    } catch (e) {
      print('❌ Error parsing SPProductoDetalle: $e');
      return SPProductoDetalle();
    }
  }

  // Propiedades computadas
  bool get estaCompletado =>
      (estadoProducto?.toUpperCase() ?? '') == 'COMPLETO';
  bool get estaPendiente =>
      (estadoProducto?.toUpperCase() ?? '') == 'PENDIENTE';
  bool get estaEnProceso => (estadoProducto?.toUpperCase() ?? '') == 'PARCIAL';

  String get estadoDescripcion {
    switch (estadoProducto?.toUpperCase()) {
      case 'COMPLETO':
        return 'Completado';
      case 'PENDIENTE':
        return 'Pendiente';
      case 'PARCIAL':
        return 'En Proceso';
      case 'PROBLEMA':
        return 'Con Problema';
      default:
        return 'Sin Estado';
    }
  }

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

  String get nombreSeguro => nombreProducto ?? 'Producto sin nombre';
  String get codigoSeguro => codigoBarra ?? 'Sin código';
  String get itemSeguro => itemId ?? 'Sin ID';

  String get loteSeguro {
    if (lote == null || lote!.isEmpty) return 'Sin lote';

    // Dividir por comas, eliminar duplicados y espacios en blanco
    final lotesUnicos = lote!
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    return lotesUnicos.join(', ');
  }

  // Nueva propiedad para fechas de vencimiento únicas
  String get vencimientoSeguro {
    if (fechaVencimiento == null) return 'Sin vencimiento';

    // Verificar si la fecha es válida (no es fecha por defecto)
    if (fechaVencimiento!.year == 1900) return 'Sin vencimiento';

    return _formatearFecha(fechaVencimiento!);
  }

  // Método para procesar vencimientos múltiples (si vienen como string)
  String procesarVencimientoMultiple(String vencimientoString) {
    if (vencimientoString.isEmpty) return 'Sin vencimiento';

    // Si solo hay una fecha, devolverla formateada
    if (!vencimientoString.contains(',')) {
      final fecha = _parsearFecha(vencimientoString.trim());
      return fecha != null ? _formatearFecha(fecha) : 'Fecha inválida';
    }

    // Si hay múltiples fechas separadas por comas
    final fechasTexto = vencimientoString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Parsear y filtrar fechas válidas
    final fechasParsed = fechasTexto
        .map((fechaTexto) => _parsearFecha(fechaTexto))
        .where((fecha) => fecha != null)
        .cast<DateTime>()
        .toList();

    if (fechasParsed.isEmpty) return 'Sin fechas válidas';

    // Eliminar duplicados y ordenar
    final fechasUnicas = fechasParsed.toSet().toList();
    fechasUnicas.sort();

    // Si todas las fechas son iguales, mostrar solo una
    if (fechasUnicas.length == 1) {
      return _formatearFecha(fechasUnicas.first);
    }

    // Si hay fechas diferentes, mostrar todas
    return fechasUnicas.map((fecha) => _formatearFecha(fecha)).join(', ');
  }

  // Método auxiliar para parsear fechas de manera segura
  DateTime? _parsearFecha(String fechaTexto) {
    if (fechaTexto.isEmpty) return null;

    // Filtrar fechas por defecto que no son válidas
    if (fechaTexto.startsWith('1900-01-01')) return null;

    try {
      return DateTime.parse(fechaTexto);
    } catch (e) {
      print('❌ Error parseando fecha: $fechaTexto - $e');
      return null;
    }
  }

  // Método auxiliar para formatear fechas
  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = fecha.difference(ahora).inDays;

    final fechaFormateada = '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';

    if (diferencia < 0) {
      return '$fechaFormateada (Vencido)';
    } else if (diferencia == 0) {
      return '$fechaFormateada (Hoy)';
    } else if (diferencia <= 7) {
      return '$fechaFormateada (${diferencia} días)';
    } else {
      return fechaFormateada;
    }
  }

  // Propiedades adicionales para verificar estado de vencimiento
  bool get tieneVencimientoProximo {
    if (fechaVencimiento == null || fechaVencimiento!.year == 1900)
      return false;

    final ahora = DateTime.now();
    final diasLimite = 7; // Considerar próximo a vencer si es en 7 días o menos

    return fechaVencimiento!.difference(ahora).inDays <= diasLimite &&
        fechaVencimiento!.difference(ahora).inDays >= 0;
  }

  bool get estaVencido {
    if (fechaVencimiento == null || fechaVencimiento!.year == 1900)
      return false;

    final ahora = DateTime.now();
    return fechaVencimiento!.isBefore(ahora);
  }

  bool get tieneVencimientoValido {
    return fechaVencimiento != null && fechaVencimiento!.year != 1900;
  }

  @override
  String toString() {
    return 'SPProductoDetalle{id: $id, itemId: $itemId, nombre: $nombreProducto, estado: $estadoProducto}';
  }
}
