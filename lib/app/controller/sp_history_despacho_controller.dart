import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sabipay/app/model/sp_despacho.dart';
import 'package:sabipay/route/my_route.dart';
import 'package:sabipay/services/route_service.dart';
import 'package:sabipay/constant/sp_colors.dart';

class SPHistoryController extends GetxController {
  final RouteService _routeService = RouteService.instance;
  final box = GetStorage();

  // Estado de carga
  final isLoading = false.obs;

  // Datos
  final despachosList = <SesionDespacho>[].obs;
  final selectedDespacho = Rxn<SesionDespacho>();

  // Filtros
  final selectedFilterIndex = 0.obs; // 0=Activos, 1=Finalizado, 2=Todos
  final List<String> filterOptions = ['Activos', 'Finalizados', 'Todos'];

  @override
  void onInit() {
    super.onInit();
    loadDespachos();
  }

  /// Cambiar filtro y recargar datos
  void changeFilter(int index) {
    if (selectedFilterIndex.value == index) {
      return;
    }
    selectedFilterIndex.value = index;
    despachosList.clear();
    loadDespachos();
  }

  /// Cargar despachos según el filtro seleccionado
  Future<void> loadDespachos() async {
    try {
      isLoading.value = true;

      final userCode = box.read('user_code') ?? '';
      if (userCode.isEmpty) {
        _showErrorMessage('No se encontró código de usuario');
        return;
      }

      final estado = selectedFilterIndex.value + 1;

      final response = await _routeService.getDespachoHistory(
        codigoUser: userCode,
        estado: estado,
      );

      if (response.isSuccess && response.data != null) {
        final despachoResponse = DespachoResponse.fromJson(response.data!);

        if (despachoResponse.success) {
          despachosList.value = despachoResponse.data;
          if (despachosList.isEmpty) {
            _showInfoMessage(
                'No se encontraron despachos ${filterOptions[selectedFilterIndex.value].toLowerCase()}');
          }
        } else {
          _showErrorMessage(despachoResponse.message);
          despachosList.clear();
        }
      } else {
        _showErrorMessage(response.message);
        despachosList.clear();
      }
    } catch (e) {
      print('❌ Error al cargar despachos: $e');
      _showErrorMessage('Error inesperado al cargar despachos');
      despachosList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Ir a los detalles completos de un despacho
  void goToDespachoDetails(SesionDespacho despacho) {
    selectedDespacho.value = despacho;
    try {
      Get.toNamed(MyRoute.spDespachoDetalle, arguments: despacho.idRuta);
    } catch (e) {
      print('❌ Error de navegación: $e');
      _showErrorMessage('Error al navegar al despacho');
    }
  }

  /// Refrescar datos
  Future<void> refreshData() async {
    await loadDespachos();
  }

  /// Buscar despachos por ID de ruta
  void searchDespachos(String query) {
    if (query.isEmpty) {
      loadDespachos();
      return;
    }

    final filteredList = despachosList.where((despacho) {
      final idRuta = despacho.idRuta?.toLowerCase() ?? '';
      return idRuta.contains(query.toLowerCase());
    }).toList();

    despachosList.value = filteredList;
  }

  /// Obtener color según el estado del despacho
  Color getStatusColor(String? estado) {
    switch (estado?.toUpperCase()) {
      case 'ACTIVO':
      case 'EN_PROCESO':
        return spColorSuccess500;
      case 'PAUSADO':
        return spWarning500;
      case 'FINALIZADA':
        return spColorGrey600;
      default:
        return spColorGrey400;
    }
  }

  /// Obtener icono según el estado del despacho
  IconData getStatusIcon(String? estado) {
    switch (estado?.toUpperCase()) {
      case 'ACTIVO':
      case 'EN_PROCESO':
        return Icons.play_circle_filled;
      case 'PAUSADO':
        return Icons.pause_circle_filled;
      case 'FINALIZADA':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  /// Verificar si el despacho puede continuar
  bool canContinueDespacho(String? estado) {
    return estado?.toUpperCase() == 'ACTIVO' ||
        estado?.toUpperCase() == 'EN_PROCESO';
  }

  /// Formatear fecha para mostrar
  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      final weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return '${weekdays[date.weekday - 1]} ${date.day}/${date.month}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Mostrar mensaje de error
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

  /// Mostrar mensaje informativo
  void _showInfoMessage(String message) {
    Get.snackbar(
      'ℹ️ Información',
      message,
      backgroundColor: spColorGrey600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  /// Limpiar datos al cerrar
  @override
  void onClose() {
    despachosList.clear();
    // ELIMINAR: expandedItems.clear();
    selectedDespacho.value = null;
    super.onClose();
  }
}
