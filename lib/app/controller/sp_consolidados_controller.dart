// app/controller/sp_consolidados_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sabipay/app/model/sp_consolidado.dart';
import 'package:sabipay/services/route_service.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/route/my_route.dart';
import 'package:intl/intl.dart';

class SPConsolidadosController extends GetxController {
  final RouteService _routeService = RouteService.instance;

  // Estado de carga
  final isLoading = false.obs;

  // Datos
  final consolidadosList = <Consolidado>[].obs;
  final selectedConsolidado = Rxn<Consolidado>();

  @override
  void onInit() {
    super.onInit();
    loadConsolidados();
  }

  /// Cargar consolidados desde la API
  Future<void> loadConsolidados() async {
    try {
      isLoading.value = true;

      // Obtener fecha actual y un día atrás
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final fechaInicio = DateFormat('yyyy-MM-dd').format(yesterday);
      final fechaFin = DateFormat('yyyy-MM-dd').format(now);

      final response = await _routeService.getConsolidados(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );

      if (response.isSuccess && response.data != null) {
        final consolidadoResponse =
            ConsolidadoResponse.fromJson(response.data!);

        if (consolidadoResponse.success) {
          consolidadosList.value = consolidadoResponse.data;

          if (consolidadosList.isEmpty) {
            _showInfoMessage(
                'No se encontraron consolidados para la fecha actual');
          }
        } else {
          _showErrorMessage(consolidadoResponse.message);
          consolidadosList.clear();
        }
      } else {
        _showErrorMessage(response.message);
        consolidadosList.clear();
      }
    } catch (e) {
      print('❌ Error al cargar consolidados: $e');
      _showErrorMessage('Error inesperado al cargar consolidados');
      consolidadosList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Refrescar datos
  Future<void> refreshData() async {
    await loadConsolidados();
  }

  /// Verificar si el consolidado está completo
  bool isConsolidadoCompleto(Consolidado consolidado) {
    return consolidado.progresoProductos >= 100.0;
  }

  /// Navegar al detalle del consolidado
  void navegarADetalleConsolidado(Consolidado consolidado) {
    if (consolidado.id == null) {
      _showErrorMessage('ID de consolidado no válido');
      return;
    }

    // Navegar a la pantalla de detalle del consolidado
    Get.toNamed(
      MyRoute.spConsolidadoDetalleScreen, // Necesitarás agregar esta ruta
      arguments: consolidado.id,
    );
  }

  /// Obtener color según el estado del consolidado
  Color getStatusColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'CREADO':
        return spColorPrimary;
      case 'EN_PROCESO':
      case 'PARCIAL':
        return spColorTeal600;
      case 'FINALIZADO':
        return spColorSuccess500;
      case 'PAUSADO':
        return spWarning500;
      default:
        return spColorGrey400;
    }
  }

  /// Obtener icono según el estado del consolidado
  IconData getStatusIcon(String estado) {
    switch (estado.toUpperCase()) {
      case 'CREADO':
        return Icons.fiber_new;
      case 'EN_PROCESO':
      case 'PARCIAL':
        return Icons.play_circle_filled;
      case 'FINALIZADO':
        return Icons.check_circle;
      case 'PAUSADO':
        return Icons.pause_circle_filled;
      default:
        return Icons.help_outline;
    }
  }

  /// Formatear fecha para mostrar
  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Formatear número con separador de miles
  String formatNumber(double number) {
    return NumberFormat('#,##0.00').format(number);
  }

  /// Mostrar detalles del consolidado
  void showConsolidadoDetails(Consolidado consolidado) {
    selectedConsolidado.value = consolidado;

    Get.bottomSheet(
      _buildConsolidadoDetailsSheet(consolidado),
      backgroundColor: Get.isDarkMode ? spCardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
    );
  }

  /// Construir sheet de detalles del consolidado
  Widget _buildConsolidadoDetailsSheet(Consolidado consolidado) {
    return Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(Get.context!).size.height * 0.8,
          maxWidth: MediaQuery.of(Get.context!).size.width,
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    getStatusIcon(consolidado.estadoConsolidado),
                    color: getStatusColor(consolidado.estadoConsolidado),
                    size: 24,
                  ),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consolidado.nombreBodegaFormateado,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          consolidado.estadoFormateado,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                getStatusColor(consolidado.estadoConsolidado),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              24.height,

              // Información general
              _buildDetailSection(
                'Información General',
                [
                  _buildDetailRow('Fecha Consolidado',
                      consolidado.fechaConsolidadoFormateada),
                  _buildDetailRow('Bodega',
                      '${consolidado.bodega} - ${consolidado.nombreBodegaFormateado}'),
                  _buildDetailRow(
                      'Fecha Inicio', formatDate(consolidado.fechaInicio)),
                  _buildDetailRow(
                      'Fecha Finalización',
                      consolidado.fechaFinalizacion != null
                          ? formatDate(consolidado.fechaFinalizacion)
                          : 'Pendiente'),
                ],
              ),

              16.height,

              // Estadísticas de productos
              _buildDetailSection(
                'Productos',
                [
                  _buildDetailRow(
                      'Total Productos', consolidado.totalProductos.toString()),
                  _buildDetailRow('Productos Preparados',
                      consolidado.totalProductosPreparados.toString()),
                  _buildDetailRow('Progreso Productos',
                      '${consolidado.progresoProductos.toStringAsFixed(1)}%'),
                ],
              ),

              16.height,

              // Estadísticas de cajas
              _buildDetailSection(
                'Cajas',
                [
                  _buildDetailRow(
                      'Total Cajas', formatNumber(consolidado.totalCajas)),
                  _buildDetailRow('Cajas Preparadas',
                      formatNumber(consolidado.totalCajasPreparadas)),
                  _buildDetailRow('Progreso Cajas',
                      '${consolidado.progresoCajas.toStringAsFixed(1)}%'),
                ],
              ),

              16.height,

              // Estadísticas de kilogramos
              _buildDetailSection(
                'Kilogramos',
                [
                  _buildDetailRow('Total Kilogramos',
                      formatNumber(consolidado.totalKilogramos)),
                  _buildDetailRow('Kilogramos Preparados',
                      formatNumber(consolidado.totalKilogramosPreparados)),
                  _buildDetailRow('Progreso Kilogramos',
                      '${consolidado.progresoKilogramos.toStringAsFixed(1)}%'),
                ],
              ),

              16.height,

              // Observaciones
              if (consolidado.observacionesGenerales.isNotEmpty) ...[
                _buildDetailSection(
                  'Observaciones',
                  [
                    Text(
                      consolidado.observacionesGenerales,
                      style: TextStyle(
                        fontSize: 14,
                        color: Get.isDarkMode ? spColorGrey300 : spColorGrey600,
                      ),
                    ),
                  ],
                ),
                16.height,
              ],

              // Información adicional
              _buildDetailSection(
                'Información Adicional',
                [
                  _buildDetailRow('Procesado por JOB',
                      consolidado.procesadoPorJob ? 'Sí' : 'No'),
                  _buildDetailRow(
                      'Fecha Creación', formatDate(consolidado.fechaCreacion)),
                  _buildDetailRow('Fecha Actualización',
                      formatDate(consolidado.fechaActualizacion)),
                ],
              ),

              24.height,

              // Botón para ir al detalle si no está completo
              if (!isConsolidadoCompleto(consolidado)) ...[
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Cerrar el modal
                      navegarADetalleConsolidado(consolidado);
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
                      'Ingresar al Detalle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ));
  }

  /// Construir sección de detalles
  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        8.height,
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? spDarkPrimary : spColorGrey50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  /// Construir fila de detalle
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Get.isDarkMode ? spColorGrey400 : spColorGrey600,
              ),
            ),
          ),
          8.width,
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
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
}
