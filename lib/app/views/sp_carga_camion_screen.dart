// lib/app/views/sp_carga_camion_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sabipay/app/controller/sp_carga_camion_controller.dart';
import 'package:sabipay/app/model/sp_carga_camion.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/sabipy_theme/theme_controller.dart';
import 'package:sabipay/route/my_route.dart';
import 'package:nb_utils/nb_utils.dart';

class SPCargaCamionScrenn extends StatefulWidget {
  const SPCargaCamionScrenn({super.key});

  @override
  SPCargaCamionScrennState createState() => SPCargaCamionScrennState();
}

class SPCargaCamionScrennState extends State<SPCargaCamionScrenn> {
  final SPCargaCamionController controller = Get.put(SPCargaCamionController());
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
    return GetBuilder<SPCargaCamionController>(
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
                _buildSearchBar(),
                Expanded(
                  child: _buildCargasList(),
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
        'Carga de Camiones',
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
              Icons.local_shipping,
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
                  'Carga de Camiones',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                4.height,
                Text(
                  'Rutas finalizadas listas para carga',
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
                  '${controller.filteredCargasList.length}',
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

  /// Construir barra de búsqueda
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: controller.updateSearch,
        decoration: InputDecoration(
          hintText: 'Buscar por ruta o usuario...',
          prefixIcon: Icon(
            Icons.search,
            color: spColorGrey500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: spColorGrey300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: spColorPrimary),
          ),
          filled: true,
          fillColor: themeController.isDarkMode ? spCardDark : Colors.white,
        ),
      ),
    );
  }

  /// Construir lista de cargas
  Widget _buildCargasList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.filteredCargasList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 80,
                color: themeController.isDarkMode
                    ? spColorGrey600
                    : spColorGrey400,
              ),
              16.height,
              Text(
                'No hay cargas pendientes',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: themeController.isDarkMode
                      ? spColorGrey400
                      : spColorGrey600,
                ),
              ),
              8.height,
              Text(
                'No se encontraron rutas finalizadas pendientes para carga de camión',
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
          itemCount: controller.filteredCargasList.length,
          itemBuilder: (context, index) {
            final carga = controller.filteredCargasList[index];
            return _buildCargaCard(carga);
          },
        ),
      );
    });
  }

  /// Construir tarjeta de carga
  Widget _buildCargaCard(CargaCamion carga) {
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
        onTap: () => controller.showCargaDetails(carga),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con ruta y estado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: spColorSuccess500.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_shipping,
                      color: spColorSuccess500,
                      size: 20,
                    ),
                  ),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ruta: ${carga.idRuta ?? 'N/A'}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        4.height,
                        Text(
                          controller.formatDate(carga.fechaInicio),
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
                      color: spColorSuccess500.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Listo para Carga',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: spColorSuccess500,
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
                      '${carga.totalProductosProcesados}/${carga.totalProductosRuta}',
                      carga.porcentajeCompletado ?? 0,
                      Icons.inventory,
                      spColorPrimary,
                    ),
                  ),
                  8.width,
                  Expanded(
                    child: _buildStatCard(
                      'Cajas',
                      '${controller.formatNumber(carga.totalCajasProcesadas)}',
                      carga.porcentajeCompletado ?? 0,
                      Icons.archive,
                      spColorTeal600,
                    ),
                  ),
                ],
              ),

              12.height,

              // Información del usuario
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: spColorGrey500,
                  ),
                  4.width,
                  Text(
                    'Usuario: ${carga.codigoUser ?? 'N/A'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: spColorGrey600,
                    ),
                  ),
                  Spacer(),
                  if (carga.tieneProblemas)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: spWarning500.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 12,
                            color: spWarning500,
                          ),
                          4.width,
                          Text(
                            '${carga.productosConProblemas} problemas',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: spColorError500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              16.height,

              // Botón "Iniciar Carga"
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.navegarADetalleCarga(carga),
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
                        Icons.local_shipping,
                        size: 18,
                      ),
                      8.width,
                      const Text(
                        'Iniciar Carga',
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
