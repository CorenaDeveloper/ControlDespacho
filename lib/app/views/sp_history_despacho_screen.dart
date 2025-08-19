import 'package:flutter/material.dart';
import 'package:sabipay/app/controller/sp_history_despacho_controller.dart';
import 'package:sabipay/app/model/sp_despacho.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/constant/sp_images.dart';
import 'package:sabipay/route/my_route.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/sabipy_theme/theme_controller.dart';
import 'package:sabipay/widgets/sp_app_widget.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class SPHistoryScreen extends StatefulWidget {
  const SPHistoryScreen({super.key});

  @override
  SPHistoryScreenState createState() => SPHistoryScreenState();
}

class SPHistoryScreenState extends State<SPHistoryScreen> {
  final SPHistoryController controller = Get.put(SPHistoryController());
  final ThemeController themeController = Get.put(ThemeController());
  final TextEditingController searchController = TextEditingController();
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
    return Scaffold(
      backgroundColor:
          themeController.isDarkMode ? spDarkPrimary : spColorLightBg,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchAndFilters(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoadingWidget();
                }

                if (controller.despachosList.isEmpty) {
                  return _buildEmptyWidget();
                }

                return _buildDespachosList();
              }),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor:
          themeController.isDarkMode ? spDarkPrimary : spColorLightBg,
      elevation: 0,
      leadingWidth: 70,
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          'Historico',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: themeController.isDarkMode ? Colors.white : spTextColor,
          ),
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
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: spColorGrey400.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            controller: searchController,
            // CONFIGURACIONES DE TECLADO EXPLÍCITAS
            keyboardType: TextInputType.number, // Tipo de teclado
            textInputAction:
                TextInputAction.search, // Acción del botón del teclado
            autocorrect: true, // Permitir autocorrección
            enableSuggestions: true, // Permitir sugerencias
            readOnly: false, // Asegurar que no sea solo lectura
            enabled: true, // Asegurar que esté habilitado
            // CONFIGURACIÓN DE FOCO
            autofocus: false, // No auto-enfocar al cargar
            canRequestFocus: true, // Permitir solicitar foco
            decoration: spInputDecoration(
              context,
              hintText: 'Buscar por ID de ruta...',
              prefixIcon: searchIcon,
              borderRadius: 12,
              fillColor:
                  themeController.isDarkMode ? spDarkPrimary : spColorGrey50,
              borderColor:
                  themeController.isDarkMode ? spColorGrey600 : spColorGrey200,
            ),

            onChanged: (value) {
              controller.searchDespachos(value);
            },

            onFieldSubmitted: (value) {
              controller.searchDespachos(value);
            },
          ),
          8.height,
          Obx(() => Row(
                children: List.generate(
                  controller.filterOptions.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right:
                            index < controller.filterOptions.length - 1 ? 8 : 0,
                      ),
                      child: _buildFilterChip(
                        controller.filterOptions[index],
                        index,
                        controller.selectedFilterIndex.value == index,
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, bool isSelected) {
    return InkWell(
      onTap: () => controller.changeFilter(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? spColorPrimary
              : (themeController.isDarkMode ? spColorGrey700 : spColorGrey100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? spColorPrimary
                : (themeController.isDarkMode
                    ? spColorGrey600
                    : spColorGrey300),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? Colors.white
                : (themeController.isDarkMode ? Colors.white : spColorGrey700),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: spColorPrimary),
          SizedBox(height: 16),
          Text('Cargando historial...'),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: themeController.isDarkMode ? spColorGrey400 : spColorGrey500,
          ),
          16.height,
          Text(
            'No hay despachos',
            style: theme.textTheme.titleLarge?.copyWith(
              color:
                  themeController.isDarkMode ? spColorGrey400 : spColorGrey600,
            ),
          ),
          8.height,
          Text(
            'No se encontraron despachos para el filtro seleccionado',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  themeController.isDarkMode ? spColorGrey500 : spColorGrey500,
            ),
          ),
          24.height,
          ElevatedButton.icon(
            onPressed: () => controller.refreshData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: spColorPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDespachosList() {
    return RefreshIndicator(
      onRefresh: () => controller.refreshData(),
      color: spColorPrimary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.despachosList.length,
        itemBuilder: (context, index) {
          final despacho = controller.despachosList[index];
          return _buildDespachoCard(despacho);
        },
      ),
    );
  }

  Widget _buildDespachoCard(SesionDespacho despacho) {
    final canContinue = controller.canContinueDespacho(despacho.estadoSesion);
    final progress = (despacho.porcentajeCompletado ?? 0) / 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: spColorGrey400.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header con información principal
            Row(
              children: [
                // Icono de estado o botón continuar
                if (canContinue)
                  InkWell(
                    onTap: () => controller.goToDespachoDetails(despacho),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: spColorPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: controller
                          .getStatusColor(despacho.estadoSesion)
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.getStatusIcon(despacho.estadoSesion),
                      color: controller.getStatusColor(despacho.estadoSesion),
                      size: 24,
                    ),
                  ),

                16.width,

                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ruta: ${despacho.idRuta ?? 'N/A'}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      4.height,
                      Text(
                        despacho.estadoDescripcion,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              controller.getStatusColor(despacho.estadoSesion),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      8.height,
                      // Progreso compacto
                      Row(
                        children: [
                          Text(
                            '${despacho.totalProductosProcesados ?? 0}/${despacho.totalProductosRuta ?? 0}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          8.width,
                          Text(
                            '${(despacho.porcentajeCompletado ?? 0).toStringAsFixed(1)}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: progress < 0.3
                                  ? spColorError500
                                  : progress < 0.7
                                      ? spWarning500
                                      : spColorSuccess500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Fecha y estadísticas compactas
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      controller.formatDate(despacho.fechaInicio),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: themeController.isDarkMode
                            ? spColorGrey400
                            : spColorGrey600,
                      ),
                    ),
                    8.height,
                    // Cajas procesadas
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2,
                          size: 14,
                          color: spColorTeal600,
                        ),
                        4.width,
                        Text(
                          '${despacho.totalCajasProcesadas?.toInt() ?? 0}/${despacho.totalCajasRuta?.toInt() ?? 0}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: spColorTeal600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    4.height,
                    // Problemas (solo si hay)
                    if ((despacho.productosConProblemas ?? 0) > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 14,
                            color: spColorError500,
                          ),
                          4.width,
                          Text(
                            '${despacho.productosConProblemas}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: spColorError500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),

            16.height,

            // Barra de progreso
            LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  themeController.isDarkMode ? spColorGrey700 : spColorGrey200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress < 0.3
                    ? spColorError500
                    : progress < 0.7
                        ? spWarning500
                        : spColorSuccess500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
