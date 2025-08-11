// app/model/sp_consolidado.dart
class ConsolidadoResponse {
  final bool success;
  final List<Consolidado> data;
  final int totalCount;
  final String fechaInicio;
  final String fechaFin;
  final String? estado;
  final String? bodega;
  final String? idConsolidado;
  final String message;
  final String timestamp;

  ConsolidadoResponse({
    required this.success,
    required this.data,
    required this.totalCount,
    required this.fechaInicio,
    required this.fechaFin,
    this.estado,
    this.bodega,
    this.idConsolidado,
    required this.message,
    required this.timestamp,
  });

  factory ConsolidadoResponse.fromJson(Map<String, dynamic> json) {
    return ConsolidadoResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((item) => Consolidado.fromJson(item))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
      fechaInicio: json['fechaInicio'] ?? '',
      fechaFin: json['fechaFin'] ?? '',
      estado: json['estado'],
      bodega: json['bodega'],
      idConsolidado: json['id_consolidado'],
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class Consolidado {
  final int id;
  final String fechaConsolidado;
  final String bodega;
  final String nombreBodega;
  final String fechaInicio;
  final String? fechaFinalizacion;
  final String estadoConsolidado;
  final int totalProductos;
  final int totalProductosPreparados;
  final double totalCajas;
  final double totalCajasPreparadas;
  final double totalKilogramos;
  final double totalKilogramosPreparados;
  final String observacionesGenerales;
  final bool procesadoPorJob;
  final String fechaCreacion;
  final String fechaActualizacion;
  final double porcentajeProductosPreparados;
  final double porcentajeCajasPreparadas;

  Consolidado({
    required this.id,
    required this.fechaConsolidado,
    required this.bodega,
    required this.nombreBodega,
    required this.fechaInicio,
    this.fechaFinalizacion,
    required this.estadoConsolidado,
    required this.totalProductos,
    required this.totalProductosPreparados,
    required this.totalCajas,
    required this.totalCajasPreparadas,
    required this.totalKilogramos,
    required this.totalKilogramosPreparados,
    required this.observacionesGenerales,
    required this.procesadoPorJob,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    required this.porcentajeProductosPreparados,
    required this.porcentajeCajasPreparadas,
  });

  factory Consolidado.fromJson(Map<String, dynamic> json) {
    return Consolidado(
      id: json['id'] ?? 0,
      fechaConsolidado: json['fechA_CONSOLIDADO'] ?? '',
      bodega: json['bodega'] ?? '',
      nombreBodega: json['nombrE_BODEGA'] ?? '',
      fechaInicio: json['fechA_INICIO'] ?? '',
      fechaFinalizacion: json['fechA_FINALIZACION'],
      estadoConsolidado: json['estadO_CONSOLIDADO'] ?? '',
      totalProductos: json['totaL_PRODUCTOS'] ?? 0,
      totalProductosPreparados: json['totaL_PRODUCTOS_PREPARADOS'] ?? 0,
      totalCajas: _safeToDouble(json['totaL_CAJAS']),
      totalCajasPreparadas: _safeToDouble(json['totaL_CAJAS_PREPARADAS']),
      totalKilogramos: _safeToDouble(json['totaL_KILOGRAMOS']),
      totalKilogramosPreparados:
          _safeToDouble(json['totaL_KILOGRAMOS_PREPARADOS']),
      observacionesGenerales: json['observacioneS_GENERALES'] ?? '',
      procesadoPorJob: json['procesadO_POR_JOB'] ?? false,
      fechaCreacion: json['fechA_CREACION'] ?? '',
      fechaActualizacion: json['fechA_ACTUALIZACION'] ?? '',
      porcentajeProductosPreparados:
          _safeToDouble(json['porcentajE_PRODUCTOS_PREPARADOS']),
      porcentajeCajasPreparadas:
          _safeToDouble(json['porcentajE_CAJAS_PREPARADAS']),
    );
  }

  // Métodos auxiliares para mostrar en UI
  String get nombreBodegaFormateado {
    if (bodega == '0111') return 'Lourdes';
    if (bodega == '0333') return 'San Miguel';
    return nombreBodega;
  }

  String get estadoFormateado {
    switch (estadoConsolidado.toUpperCase()) {
      case 'CREADO':
        return 'Creado';
      case 'EN_PROCESO':
      case 'PARCIAL':
        return 'En Proceso';
      case 'FINALIZADO':
        return 'Finalizado';
      case 'PAUSADO':
        return 'Pausado';
      default:
        return estadoConsolidado;
    }
  }

  String get fechaConsolidadoFormateada {
    try {
      final date = DateTime.parse(fechaConsolidado);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return fechaConsolidado;
    }
  }

  double get progresoProductos {
    if (totalProductos == 0) return 0.0;
    return (totalProductosPreparados / totalProductos) * 100;
  }

  double get progresoCajas {
    if (totalCajas == 0) return 0.0;
    return (totalCajasPreparadas / totalCajas) * 100;
  }

  double get progresoKilogramos {
    if (totalKilogramos == 0) return 0.0;
    return (totalKilogramosPreparados / totalKilogramos) * 100;
  }

  static double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
