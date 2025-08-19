// lib/app/model/sp_carga_camion_detalle.dart

class CargaCamionDetalle {
  final int? id;
  final String? idRuta;
  final String? codigoUser;
  final DateTime? fechaInicio;
  final List<ProductoCargaCamion>? productos;

  CargaCamionDetalle({
    this.id,
    this.idRuta,
    this.codigoUser,
    this.fechaInicio,
    this.productos,
  });

  factory CargaCamionDetalle.fromJson(Map<String, dynamic> json) {
    return CargaCamionDetalle(
      id: (json['id'] as num?)?.toInt(),
      idRuta: json['idRuta']?.toString(),
      codigoUser: json['codigoUser']?.toString(),
      fechaInicio: json['fechaInicio'] != null
          ? DateTime.tryParse(json['fechaInicio'].toString())
          : null,
      productos: (json['productos'] as List<dynamic>?)
          ?.map((item) => ProductoCargaCamion.fromJson(item))
          .toList(),
    );
  }
}

class ProductoCargaCamion {
  final String? itemId;
  final String? descripcion;
  final String? codigoBarra;
  final String? lote;
  final DateTime? fechaVencimiento;

  // Campos específicos para validación física
  final bool? validadoFisicamente;
  final DateTime? fechaValidacion;
  final String? usuarioValidacion;
  final int? unidadesValidadas;
  final double? cajasValidadas;
  final String? observaciones;

  ProductoCargaCamion({
    this.itemId,
    this.descripcion,
    this.codigoBarra,
    this.lote,
    this.fechaVencimiento,
    this.validadoFisicamente,
    this.fechaValidacion,
    this.usuarioValidacion,
    this.unidadesValidadas,
    this.cajasValidadas,
    this.observaciones,
  });

  factory ProductoCargaCamion.fromJson(Map<String, dynamic> json) {
    return ProductoCargaCamion(
      itemId: json['itemId']?.toString(),
      descripcion: json['descripcion']?.toString(),
      codigoBarra: json['codigoBarra']?.toString(),
      lote: json['lote']?.toString(),
      fechaVencimiento: json['fechaVencimiento'] != null
          ? DateTime.tryParse(json['fechaVencimiento'].toString())
          : null,
      validadoFisicamente: json['validadoFisicamente'] as bool?,
      fechaValidacion: json['fechaValidacion'] != null
          ? DateTime.tryParse(json['fechaValidacion'].toString())
          : null,
      usuarioValidacion: json['usuarioValidacion']?.toString(),
      unidadesValidadas: (json['unidadesValidadas'] as num?)?.toInt(),
      cajasValidadas: (json['cajasValidadas'] as num?)?.toDouble(),
      observaciones: json['observaciones']?.toString(),
    );
  }

  // Crear copia con nuevos valores
  ProductoCargaCamion copyWith({
    String? itemId,
    String? descripcion,
    String? codigoBarra,
    String? lote,
    DateTime? fechaVencimiento,
    bool? validadoFisicamente,
    DateTime? fechaValidacion,
    String? usuarioValidacion,
    int? unidadesValidadas,
    double? cajasValidadas,
    String? observaciones,
  }) {
    return ProductoCargaCamion(
      itemId: itemId ?? this.itemId,
      descripcion: descripcion ?? this.descripcion,
      codigoBarra: codigoBarra ?? this.codigoBarra,
      lote: lote ?? this.lote,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      validadoFisicamente: validadoFisicamente ?? this.validadoFisicamente,
      fechaValidacion: fechaValidacion ?? this.fechaValidacion,
      usuarioValidacion: usuarioValidacion ?? this.usuarioValidacion,
      unidadesValidadas: unidadesValidadas ?? this.unidadesValidadas,
      cajasValidadas: cajasValidadas ?? this.cajasValidadas,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  // Métodos de utilidad
  bool get estaValidado => validadoFisicamente == true;

  bool get tieneValidacion =>
      unidadesValidadas != null || cajasValidadas != null;

  bool get estaPendiente => !estaValidado && !tieneValidacion;

  @override
  String toString() {
    return 'ProductoCargaCamion{itemId: $itemId, validado: $validadoFisicamente}';
  }
}
