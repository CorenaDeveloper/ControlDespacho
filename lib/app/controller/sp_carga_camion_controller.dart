import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sabipay/app/model/sp_carga_camion.dart';
import 'package:sabipay/route/my_route.dart';
import 'package:sabipay/services/route_service.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:intl/intl.dart';

class SPCargaCamionController extends GetxController {
  final RouteService _routeService = RouteService.instance;

  // Estado de carga
  final isLoading = false.obs;

  // Datos
  final cargasList = <CargaCamion>[].obs;
  final filteredCargasList = <CargaCamion>[].obs;
  final selectedCarga = Rxn<CargaCamion>();

  // Búsqueda
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCargasCamion();

    // Escuchar cambios en búsqueda
    ever(searchQuery, (_) => _applyFilters());
  }

  /// Cargar cargas de camión desde la API
  Future<void> loadCargasCamion() async {
    try {
      isLoading.value = true;

      final response = await _routeService.getCargaCamionPendiente();

      if (response.isSuccess && response.data != null) {
        // La API devuelve directamente una lista
        final List<dynamic> dataList = response.data!;

        // Convertir cada elemento a CargaCamion
        final List<CargaCamion> cargas = dataList
            .map((item) => CargaCamion.fromJson(item as Map<String, dynamic>))
            .toList();

        cargasList.value = cargas;
        _applyFilters();

        if (cargasList.isEmpty) {
          _showInfoMessage('No se encontraron cargas pendientes para camión');
        }
      } else {
        _showErrorMessage(response.message);
        cargasList.clear();
        filteredCargasList.clear();
      }
    } catch (e) {
      print('❌ Error al cargar cargas de camión: $e');
      _showErrorMessage('Error inesperado al cargar cargas de camión');
      cargasList.clear();
      filteredCargasList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Aplicar filtros y búsqueda
  void _applyFilters() {
    List<CargaCamion> filtered = List.from(cargasList);

    // Aplicar búsqueda por texto (solo si hay texto)
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((carga) {
        return (carga.idRuta?.toLowerCase().contains(query) ?? false) ||
            (carga.codigoUser?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Ordenar por fecha (más recientes primero)
    filtered.sort((a, b) {
      if (a.fechaInicio == null && b.fechaInicio == null) return 0;
      if (a.fechaInicio == null) return 1;
      if (b.fechaInicio == null) return -1;
      return b.fechaInicio!.compareTo(a.fechaInicio!);
    });

    filteredCargasList.value = filtered;
  }

  /// Cambiar filtro - Método removido ya que no hay filtros

  /// Actualizar búsqueda
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  /// Refrescar datos
  Future<void> refreshData() async {
    await loadCargasCamion();
  }

  /// Navegar al detalle de la carga
  void navegarADetalleCarga(CargaCamion carga) {
    if (carga.id == null) {
      _showErrorMessage('ID de carga no válido');
      return;
    }

    Get.toNamed(
      MyRoute.spCargaCamionDetalleScreen,
      arguments: carga.idRuta,
    );
  }

  /// Obtener color para cargas finalizadas pendientes
  Color getStatusColor(String? estado) {
    // Todas son finalizadas, pero podemos diferenciar por otros criterios
    return spColorSuccess500; // Verde para finalizadas listas para carga
  }

  /// Obtener icono para cargas finalizadas pendientes
  IconData getStatusIcon(String? estado) {
    return Icons.local_shipping; // Icono de camión para carga
  }

  /// Formatear fecha para mostrar
  String formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  /// Formatear número con separador de miles
  String formatNumber(double? number) {
    if (number == null) return '0';
    return NumberFormat('#,##0.00').format(number);
  }

  /// Mostrar detalles de la carga
  void showCargaDetails(CargaCamion carga) {
    selectedCarga.value = carga;

    Get.bottomSheet(
      _buildCargaDetailsSheet(carga),
      backgroundColor: Get.isDarkMode ? spCardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
    );
  }

  /// Construir sheet de detalles
  Widget _buildCargaDetailsSheet(CargaCamion carga) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: Get.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: getStatusColor(carga.estadoSesion).withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Indicador de arrastre
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: spColorGrey400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                16.height,
                Row(
                  children: [
                    Icon(
                      getStatusIcon(carga.estadoSesion),
                      color: getStatusColor(carga.estadoSesion),
                      size: 32,
                    ),
                    16.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ruta: ${carga.idRuta ?? 'N/A'}',
                            style: Get.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            carga.estadoDescripcion,
                            style: Get.textTheme.bodyMedium?.copyWith(
                              color: getStatusColor(carga.estadoSesion),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Contenido
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDetailItem('Usuario', carga.codigoUser ?? 'N/A'),
                  _buildDetailItem(
                      'Fecha Inicio', formatDate(carga.fechaInicio)),
                  _buildDetailItem(
                      'Productos Ruta', '${carga.totalProductosRuta ?? 0}'),
                  _buildDetailItem('Productos Procesados',
                      '${carga.totalProductosProcesados ?? 0}'),
                  _buildDetailItem(
                      'Cajas Ruta', formatNumber(carga.totalCajasRuta)),
                  _buildDetailItem('Cajas Procesadas',
                      formatNumber(carga.totalCajasProcesadas)),
                  _buildDetailItem('Progreso',
                      '${(carga.porcentajeCompletado ?? 0).toStringAsFixed(1)}%'),
                  _buildDetailItem('Productos con Problemas',
                      '${carga.productosConProblemas ?? 0}'),
                  if (carga.observacionesGenerales?.isNotEmpty == true) ...[
                    16.height,
                    _buildDetailItem(
                        'Observaciones', carga.observacionesGenerales!),
                  ],
                  24.height,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        navegarADetalleCarga(carga);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: spColorPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Iniciar Carga de Camión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: spColorGrey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          8.width,
          Expanded(
            child: Text(
              value,
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mostrar mensaje de error
  void _showErrorMessage(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: spColorError500,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  /// Mostrar mensaje de información
  void _showInfoMessage(String message) {
    Get.snackbar(
      'Información',
      message,
      backgroundColor: spColorTeal600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
}
