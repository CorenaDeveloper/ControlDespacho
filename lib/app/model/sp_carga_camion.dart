class CargaCamion {
  final int? id;
  final String? idRuta;
  final String? codigoUser;
  final DateTime? fechaInicio;
  final String? estadoSesion;
  final int? totalProductosRuta;
  final int? totalProductosProcesados;
  final double? totalCajasRuta;
  final double? totalCajasProcesadas;
  final String? observacionesGenerales;
  final double? porcentajeCompletado;
  final int? productosConProblemas;

  CargaCamion({
    this.id,
    this.idRuta,
    this.codigoUser,
    this.fechaInicio,
    this.estadoSesion,
    this.totalProductosRuta,
    this.totalProductosProcesados,
    this.totalCajasRuta,
    this.totalCajasProcesadas,
    this.observacionesGenerales,
    this.porcentajeCompletado,
    this.productosConProblemas,
  });

  factory CargaCamion.fromJson(Map<String, dynamic> json) {
    try {
      return CargaCamion(
        id: (json['id'] as num?)?.toInt(),
        idRuta: json['idRuta']?.toString(),
        codigoUser: json['codigoUser']?.toString(),
        fechaInicio: json['fechaInicio'] != null
            ? DateTime.tryParse(json['fechaInicio'].toString())
            : null,
        estadoSesion: json['estadoSesion']?.toString(),
        totalProductosRuta: (json['totalProductosRuta'] as num?)?.toInt(),
        totalProductosProcesados:
            (json['totalProductosProcesados'] as num?)?.toInt(),
        totalCajasRuta: (json['totalCajasRuta'] as num?)?.toDouble(),
        totalCajasProcesadas:
            (json['totalCajasProcesadas'] as num?)?.toDouble(),
        observacionesGenerales: json['observacionesGenerales']?.toString(),
        porcentajeCompletado:
            (json['porcentajeCompletado'] as num?)?.toDouble(),
        productosConProblemas: (json['productosConProblemas'] as num?)?.toInt(),
      );
    } catch (e) {
      print('❌ Error parsing CargaCamion: $e');
      return CargaCamion();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idRuta': idRuta,
      'codigoUser': codigoUser,
      'fechaInicio': fechaInicio?.toIso8601String(),
      'estadoSesion': estadoSesion,
      'totalProductosRuta': totalProductosRuta,
      'totalProductosProcesados': totalProductosProcesados,
      'totalCajasRuta': totalCajasRuta,
      'totalCajasProcesadas': totalCajasProcesadas,
      'observacionesGenerales': observacionesGenerales,
      'porcentajeCompletado': porcentajeCompletado,
      'productosConProblemas': productosConProblemas,
    };
  }

  // Métodos de utilidad
  bool get estaFinalizado => estadoSesion?.toUpperCase() == 'FINALIZADA';

  bool get tieneProblemas => (productosConProblemas ?? 0) > 0;

  bool get estaCompleto => (porcentajeCompletado ?? 0) >= 100.0;

  String get estadoDescripcion {
    switch (estadoSesion?.toUpperCase()) {
      case 'FINALIZADA':
        return 'Finalizada';
      case 'ACTIVA':
        return 'En Proceso';
      case 'PAUSADA':
        return 'Pausada';
      case 'CANCELADA':
        return 'Cancelada';
      default:
        return 'Desconocido';
    }
  }

  // Calcular eficiencia (cajas procesadas vs cajas de ruta)
  double get eficienciaEnCajas {
    if (totalCajasRuta == null || totalCajasRuta == 0) return 0.0;
    return ((totalCajasProcesadas ?? 0) / totalCajasRuta!) * 100;
  }

  // Verificar si hay sobreproceso (más cajas procesadas que las de la ruta)
  bool get tieneSobreproceso {
    if (totalCajasRuta == null || totalCajasProcesadas == null) return false;
    return totalCajasProcesadas! > totalCajasRuta!;
  }

  @override
  String toString() {
    return 'CargaCamion{id: $id, idRuta: $idRuta, estadoSesion: $estadoSesion, porcentajeCompletado: $porcentajeCompletado}';
  }
}
