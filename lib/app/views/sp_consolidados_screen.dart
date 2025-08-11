// app/views/sp_consolidados_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sabipay/app/controller/sp_consolidados_controller.dart';
import 'package:sabipay/app/model/sp_consolidado.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/sabipy_theme/theme_controller.dart';
import 'package:sabipay/route/my_route.dart';
import 'package:nb_utils/nb_utils.dart';

class SPConsolidadosScreen extends StatefulWidget {
  const SPConsolidadosScreen({super.key});

  @override
  SPConsolidadosScreenState createState() => SPConsolidadosScreenState();
}

class SPConsolidadosScreenState extends State<SPConsolidadosScreen> {
  final SPConsolidadosController controller =
      Get.put(SPConsolidadosController());
  final ThemeController themeController = Get.put(ThemeController());
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    theme = themeController.isDarkMode
        ? SPWalletTheme.spDarkTheme
        : SPWalletTheme.spLightTheme;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SPConsolidadosController>(
      init: controller,
      builder: (controller) {
        return Scaffold(
          backgroundColor:
              themeController.isDarkMode ? spDarkPrimary : spColorLightBg,
          appBar: _buildAppBar(),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildConsolidadosList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construir AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor:
          themeController.isDarkMode ? spDarkPrimary : Colors.white,
      elevation: 0,
      title: Text(
        'Consolidados',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: themeController.isDarkMode ? Colors.white : spTextColor,
        ),
      ),
      leading: Center(
        child: InkWell(
          onTap: () {
            Get.offNamedUntil(
                MyRoute.spMainHomeScreen, (route) => route.isFirst);
          },
          child: Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeController.isDarkMode ? spDarkPrimary : Colors.white,
              boxShadow: [
                BoxShadow(
                  spreadRadius: -4,
                  color: spTextColor.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_sharp,
              size: 18,
              color: themeController.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => controller.refreshData(),
          icon: Obx(() => controller.isLoading.value
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      themeController.isDarkMode ? Colors.white : spTextColor,
                    ),
                  ),
                )
              : Icon(
                  Icons.refresh,
                  color:
                      themeController.isDarkMode ? Colors.white : spTextColor,
                )),
        ),
        16.width,
      ],
    );
  }

  /// Construir header con información
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [spColorPrimary, spColorPrimary600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: spColorPrimary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.inventory_2,
              color: Colors.white,
              size: 32,
            ),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consolidados de Despacho',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                4.height,
                Text(
                  'Gestión de consolidados por bodega',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Obx(() => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${controller.consolidadosList.length}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  /// Construir lista de consolidados
  Widget _buildConsolidadosList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.consolidadosList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: themeController.isDarkMode
                    ? spColorGrey600
                    : spColorGrey400,
              ),
              16.height,
              Text(
                'No hay consolidados disponibles',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: themeController.isDarkMode
                      ? spColorGrey400
                      : spColorGrey600,
                ),
              ),
              8.height,
              Text(
                'Los consolidados aparecerán aquí cuando estén disponibles',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: themeController.isDarkMode
                      ? spColorGrey500
                      : spColorGrey500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshData,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: controller.consolidadosList.length,
          itemBuilder: (context, index) {
            final consolidado = controller.consolidadosList[index];
            return _buildConsolidadoCard(consolidado);
          },
        ),
      );
    });
  }

  /// Construir tarjeta de consolidado
  Widget _buildConsolidadoCard(Consolidado consolidado) {
    final bool isCompleto = controller.isConsolidadoCompleto(consolidado);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: spColorGrey400.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => controller.showConsolidadoDetails(consolidado),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con bodega y estado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: controller
                          .getStatusColor(consolidado.estadoConsolidado)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      controller.getStatusIcon(consolidado.estadoConsolidado),
                      color: controller
                          .getStatusColor(consolidado.estadoConsolidado),
                      size: 20,
                    ),
                  ),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consolidado.nombreBodegaFormateado,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        4.height,
                        Text(
                          consolidado.fechaConsolidadoFormateada,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: themeController.isDarkMode
                                ? spColorGrey400
                                : spColorGrey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: controller
                          .getStatusColor(consolidado.estadoConsolidado)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      consolidado.estadoFormateado,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: controller
                            .getStatusColor(consolidado.estadoConsolidado),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              16.height,

              // Estadísticas principales
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Productos',
                      '${consolidado.totalProductosPreparados}/${consolidado.totalProductos}',
                      consolidado.progresoProductos,
                      Icons.inventory,
                      spColorPrimary,
                    ),
                  ),
                  8.width,
                  Expanded(
                    child: _buildStatCard(
                      'Cajas',
                      '${controller.formatNumber(consolidado.totalCajasPreparadas)}/${controller.formatNumber(consolidado.totalCajas)}',
                      consolidado.progresoCajas,
                      Icons.archive,
                      spColorTeal600,
                    ),
                  ),
                ],
              ),

              12.height,

              // Barra de progreso general
              Row(
                children: [
                  Text(
                    'Progreso general: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${consolidado.progresoProductos.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: controller
                          .getStatusColor(consolidado.estadoConsolidado),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              8.height,

              LinearProgressIndicator(
                value: consolidado.progresoProductos / 100,
                backgroundColor: themeController.isDarkMode
                    ? spColorGrey700
                    : spColorGrey200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  controller.getStatusColor(consolidado.estadoConsolidado),
                ),
              ),

              // Botón "Ingresar" si no está completo
              if (!isCompleto) ...[
                16.height,
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        controller.navegarADetalleConsolidado(consolidado),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: spColorPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.login,
                          size: 18,
                        ),
                        8.width,
                        const Text(
                          'Ingresar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Construir tarjeta de estadística
  Widget _buildStatCard(
      String title, String value, double progress, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              4.width,
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          8.height,
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          4.height,
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor:
                themeController.isDarkMode ? spColorGrey700 : spColorGrey200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}
