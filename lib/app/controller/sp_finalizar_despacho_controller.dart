import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sabipay/app/model/sp_despacho_detalle.dart';
import 'package:sabipay/services/api_despacho.dart';
import 'package:sabipay/constant/sp_colors.dart';

class SPFinalizarDespachoController extends GetxController {
  final DespachoService _api_despacho = DespachoService.instance;

  // Datos recibidos de la pantalla anterior
  SPDespachoDetalle? despacho;
  List<SPProductoDetalle> productos = [];

  // Estado de la pantalla
  final isLoading = false.obs;
  final isFinalizando = false.obs;

  // Controladores de texto
  final comentarioController = TextEditingController();
  final comentarioFocusNode = FocusNode();

  // Estadísticas calculadas
  final productosCompletados = 0.obs;
  final productosPendientes = 0.obs;
  final productosEnProceso = 0.obs;
  final progresoGeneral = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    // Recibir datos de la pantalla anterior
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      despacho = arguments['despacho'] as SPDespachoDetalle?;
      productos = arguments['productos'] as List<SPProductoDetalle>? ?? [];
      _updateStatistics();
    }
  }

  void _updateStatistics() {
    if (productos.isEmpty) {
      productosCompletados.value = 0;
      productosPendientes.value = 0;
      productosEnProceso.value = 0;
      progresoGeneral.value = 0.0;
      return;
    }

    productosCompletados.value =
        productos.where((p) => p.estaCompletado).length;
    productosPendientes.value = productos.where((p) => p.estaPendiente).length;
    productosEnProceso.value = productos.where((p) => p.estaEnProceso).length;

    final total = productos.length;
    progresoGeneral.value =
        total > 0 ? (productosCompletados.value / total) * 100 : 0.0;
  }

  /// Finalizar despacho con comentarios
  Future<void> finalizarDespacho() async {
    if (despacho?.id == null) {
      _showErrorMessage('No se encontró sesión válida para finalizar');
      return;
    }

    try {
      isFinalizando.value = true;
      _showInfoMessage('Finalizando despacho...');

      final observaciones = comentarioController.text.trim();

      // Llamar a la API de finalizar sesión
      final response = await _api_despacho.finalizarSesion(
        idSesion: despacho!.id!,
        observacionesGenerales: observaciones.isNotEmpty ? observaciones : null,
      );

      if (response.isSuccess) {
        _showSuccessMessage('Despacho finalizado exitosamente');

        // Regresar a la pantalla anterior con resultado
        Get.back(result: {
          'success': true,
          'message': 'Despacho finalizado correctamente',
        });
      } else {
        _showErrorMessage(response.message.isNotEmpty
            ? response.message
            : 'Error al finalizar despacho');
      }
    } catch (e) {
      _showErrorMessage('Error inesperado: ${e.toString()}');
    } finally {
      isFinalizando.value = false;
    }
  }

  /// Obtener productos agrupados por estado
  List<SPProductoDetalle> get productosCompletadosList =>
      productos.where((p) => p.estaCompletado).toList();

  List<SPProductoDetalle> get productosPendientesList =>
      productos.where((p) => p.estaPendiente).toList();

  List<SPProductoDetalle> get productosEnProcesoList =>
      productos.where((p) => p.estaEnProceso).toList();

  /// Verificar si se puede finalizar
  bool get puedeFinalizarDespacho => despacho?.id != null;

  /// Verificar si hay productos pendientes
  bool get hayProductosPendientes => productosPendientes.value > 0;

  /// Obtener color del estado del producto
  Color getProductStatusColor(String? estado) {
    switch (estado?.toUpperCase()) {
      case 'COMPLETO':
      case 'COMPLETADO':
        return spColorSuccess500;
      case 'EN_PROCESO':
      case 'PROCESANDO':
        return spColorTeal600;
      case 'PENDIENTE':
        return spWarning500;
      default:
        return spColorGrey400;
    }
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      '❌ Error',
      message,
      backgroundColor: spColorError500,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  void _showInfoMessage(String message) {
    Get.snackbar(
      'ℹ️ Información',
      message,
      backgroundColor: spColorGrey600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }

  void _showSuccessMessage(String message) {
    Get.snackbar(
      '✅ Éxito',
      message,
      backgroundColor: spColorSuccess500,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    comentarioController.dispose();
    comentarioFocusNode.dispose();
    super.onClose();
  }
}
