// app/model/sp_consolidado_detalle.dart
import 'package:intl/intl.dart';

class DetalleResponseRuta {
  final bool success;
  final List<ProductoDetalleRuta> data;
  final int totalCount;
  final int idConsolidado;
  final String message;
  final String timestamp;

  DetalleResponseRuta({
    required this.success,
    required this.data,
    required this.totalCount,
    required this.idConsolidado,
    required this.message,
    required this.timestamp,
  });

  factory DetalleResponseRuta.fromJson(Map<String, dynamic> json) {
    return DetalleResponseRuta(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) =>
                  ProductoDetalleRuta.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
      idConsolidado: json['id_Consolidado'] ?? 0,
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class ProductoDetalleRuta {
  final int id;
  final int idSesionConsolidado;
  final String itemId;
  final String nombreProducto;
  final String codigoBarra;
  final String dun14;
  final int factor;
  final String lote;
  final String? fechaVencimiento;
  final String bodega;
  final int unidadesConsolidado;
  final double cajasConsolidado;
  final double kilogramosConsolidado;
  final double librasConsolidado;
  final double toneladasConsolidado;
  final double mT3Cubicos;
  final int unidadesPreparadas;
  final double cajasPreparadas;
  final double kilogramosPreparados;
  final String estadoProducto;
  final String? tiempoInicioPreparacion;
  final String? tiempoFinPreparacion;
  final String? usuarioPreparacion;
  final int cantidadEscaneos;
  final double diferenciaUnidades;
  final bool tieneProblemas;
  final String? descripcionProblema;
  final String? observaciones;
  final String fechaCreacion;
  final String fechaActualizacion;
  final int unidadesPendientes;
  final double cajasPendientes;
  final double porcentajeCompletitud;

  ProductoDetalleRuta({
    required this.id,
    required this.idSesionConsolidado,
    required this.itemId,
    required this.nombreProducto,
    required this.codigoBarra,
    required this.dun14,
    required this.factor,
    required this.lote,
    this.fechaVencimiento,
    required this.bodega,
    required this.unidadesConsolidado,
    required this.cajasConsolidado,
    required this.kilogramosConsolidado,
    required this.librasConsolidado,
    required this.toneladasConsolidado,
    required this.mT3Cubicos,
    required this.unidadesPreparadas,
    required this.cajasPreparadas,
    required this.kilogramosPreparados,
    required this.estadoProducto,
    this.tiempoInicioPreparacion,
    this.tiempoFinPreparacion,
    this.usuarioPreparacion,
    required this.cantidadEscaneos,
    required this.diferenciaUnidades,
    required this.tieneProblemas,
    this.descripcionProblema,
    this.observaciones,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    required this.unidadesPendientes,
    required this.cajasPendientes,
    required this.porcentajeCompletitud,
  });

  factory ProductoDetalleRuta.fromJson(Map<String, dynamic> json) {
    return ProductoDetalleRuta(
      id: json['id'] ?? 0,
      idSesionConsolidado: json['iD_SESION_CONSOLIDADO'] ?? 0,
      itemId: json['iteM_ID'] ?? '',
      nombreProducto: json['nombrE_PRODUCTO'] ?? '',
      codigoBarra: json['codigO_BARRA'] ?? '',
      dun14: json['duN14'] ?? '',
      factor: json['factor'] ?? 1,
      lote: json['lote'] ?? '',
      fechaVencimiento: json['fechA_VENCIMIENTO'],
      bodega: json['bodega'] ?? '',
      unidadesConsolidado: json['unidadeS_CONSOLIDADO'] ?? 0,
      cajasConsolidado: (json['cajaS_CONSOLIDADO'] ?? 0).toDouble(),
      kilogramosConsolidado: (json['kilogramoS_CONSOLIDADO'] ?? 0).toDouble(),
      librasConsolidado: (json['libraS_CONSOLIDADO'] ?? 0).toDouble(),
      toneladasConsolidado: (json['toneladaS_CONSOLIDADO'] ?? 0).toDouble(),
      mT3Cubicos: (json['mT3_CUBICOS'] ?? 0).toDouble(),
      unidadesPreparadas: json['unidadeS_PREPARADAS'] ?? 0,
      cajasPreparadas: (json['cajaS_PREPARADAS'] ?? 0).toDouble(),
      kilogramosPreparados: (json['kilogramoS_PREPARADOS'] ?? 0).toDouble(),
      estadoProducto: json['estadO_PRODUCTO'] ?? 'PENDIENTE',
      tiempoInicioPreparacion: json['tiempO_INICIO_PREPARACION'],
      tiempoFinPreparacion: json['tiempO_FIN_PREPARACION'],
      usuarioPreparacion: json['usuariO_PREPARACION'],
      cantidadEscaneos: json['cantidaD_ESCANEOS'] ?? 0,
      diferenciaUnidades: (json['diferenciA_UNIDADES'] ?? 0).toDouble(),
      tieneProblemas: json['tienE_PROBLEMAS'] ?? false,
      descripcionProblema: json['descripcioN_PROBLEMA'],
      observaciones: json['observaciones'],
      fechaCreacion: json['fechA_CREACION'] ?? '',
      fechaActualizacion: json['fechA_ACTUALIZACION'] ?? '',
      unidadesPendientes: json['unidadeS_PENDIENTES'] ?? 0,
      cajasPendientes: (json['cajaS_PENDIENTES'] ?? 0).toDouble(),
      porcentajeCompletitud: (json['porcentajE_COMPLETITUD'] ?? 0).toDouble(),
    );
  }

  // Getters para estados
  bool get estaPendiente => estadoProducto.toUpperCase() == 'PENDIENTE';
  bool get estaEnProceso =>
      estadoProducto.toUpperCase() == 'EN_PROCESO' ||
      estadoProducto.toUpperCase() == 'PARCIAL';
  bool get estaCompletado =>
      estadoProducto.toUpperCase() == 'COMPLETADO' ||
      porcentajeCompletitud >= 100;
  bool get tieneError => tieneProblemas;

  // Getters seguros para evitar nulos
  String get nombreSeguro =>
      nombreProducto.isNotEmpty ? nombreProducto : 'Sin nombre';
  String get codigoSeguro => codigoBarra.isNotEmpty ? codigoBarra : itemId;
  String get itemSeguro => itemId.isNotEmpty ? itemId : 'Sin código';
  String get loteSeguro => lote.isNotEmpty ? lote : '0000';

  // Formateo de fecha
  String get fechaCreacionFormateada {
    try {
      final date = DateTime.parse(fechaCreacion);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return fechaCreacion;
    }
  }

  String get fechaActualizacionFormateada {
    try {
      final date = DateTime.parse(fechaActualizacion);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return fechaActualizacion;
    }
  }

  String get fechaVencimientoFormateada {
    if (fechaVencimiento == null) return 'N/A';
    try {
      final date = DateTime.parse(fechaVencimiento!);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return fechaVencimiento!;
    }
  }

  // Estado formateado
  String get estadoFormateado {
    switch (estadoProducto.toUpperCase()) {
      case 'PENDIENTE':
        return 'Pendiente';
      case 'EN_PROCESO':
      case 'PARCIAL':
        return 'En Proceso';
      case 'COMPLETADO':
        return 'Completado';
      default:
        return estadoProducto;
    }
  }

  double get totalpendiente {
    if (factor <= 0) return 0.0;
    final pendientes = unidadesPendientes;
    final cajasEnteras = (pendientes / factor).floor();
    final unidadesSueltas = pendientes - (cajasEnteras * factor);
    final unidadesFormateadas = unidadesSueltas / 1000.0;

    return cajasEnteras + unidadesFormateadas;
  }

  double get totalGeneral {
    if (factor <= 0) return 0.0;
    final unidades = unidadesConsolidado;
    final cajasEnteras = (unidades / factor).floor();
    final unidadesSueltas = unidades - (cajasEnteras * factor);
    final unidadesFormateadas = unidadesSueltas / 1000.0;

    return cajasEnteras + unidadesFormateadas;
  }

  double get totalProcesadas {
    if (factor <= 0) return 0.0;
    final procesadas = unidadesPreparadas;
    final cajasEnteras = (procesadas / factor).floor();
    final unidadesSueltas = procesadas - (cajasEnteras * factor);
    final unidadesFormateadas = unidadesSueltas / 1000.0;

    return cajasEnteras + unidadesFormateadas;
  }

  // Información de progreso
  String get progresoTexto {
    return '${unidadesPreparadas}/${unidadesConsolidado} unidades';
  }

  String get progresoCajasTexto {
    return '${cajasPreparadas.toStringAsFixed(2)}/${cajasConsolidado.toStringAsFixed(2)} cajas';
  }

  // Validación para procesamiento
  bool get puedeSerProcesado => !estaCompletado && !tieneError;

  // Cantidad disponible para procesar
  int get cantidadDisponible => unidadesPendientes;

  // Información del lote (importante para consolidados)
  String get informacionLote {
    if (lote.isNotEmpty) {
      return 'Lote: $lote';
    }
    return 'Sin lote';
  }
}
