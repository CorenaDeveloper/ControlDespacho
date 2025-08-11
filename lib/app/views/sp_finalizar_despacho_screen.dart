import 'package:flutter/material.dart';
import 'package:sabipay/app/controller/sp_finalizar_despacho_controller.dart';
import 'package:sabipay/app/model/sp_despacho_detalle.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/sabipy_theme/theme_controller.dart';
import 'package:sabipay/widgets/sp_app_widget.dart';
import 'package:sabipay/widgets/sp_common_button.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class SPFinalizarDespachoScreen extends StatefulWidget {
  const SPFinalizarDespachoScreen({super.key});

  @override
  SPFinalizarDespachoScreenState createState() =>
      SPFinalizarDespachoScreenState();
}

class SPFinalizarDespachoScreenState extends State<SPFinalizarDespachoScreen> {
  late SPFinalizarDespachoController controller;
  final ThemeController themeController = Get.put(ThemeController());
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    theme = themeController.isDarkMode
        ? SPWalletTheme.spDarkTheme
        : SPWalletTheme.spLightTheme;
    controller = Get.put(SPFinalizarDespachoController());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SPFinalizarDespachoController>(
      init: controller,
      builder: (controller) {
        return Scaffold(
          backgroundColor:
              themeController.isDarkMode ? spDarkPrimary : spColorLightBg,
          appBar: _buildAppBar(),
          body: _buildBody(),
          bottomNavigationBar: _buildBottomBar(),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return spCommonAppBarWidget(
      context,
      titleText: 'Finalizar Despacho',
      backgroundColor:
          themeController.isDarkMode ? spDarkPrimary : spColorLightBg,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          16.height,
          _buildResumenCard(),
          16.height,
          _buildDetalleProductos(),
          16.height,
          _buildComentariosSection(),
          100.height, // Espacio para el bottom bar
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: spColorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.route,
                  color: spColorPrimary,
                  size: 20,
                ),
              ),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ruta: ${controller.despacho?.id ?? 'N/A'}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    4.height,
                    Text(
                      controller.despacho?.estadoDescripcion ??
                          'Estado no disponible',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: themeController.isDarkMode
                            ? spColorGrey400
                            : spColorGrey600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: controller.despacho?.esActivo == true
                      ? spColorSuccess500
                      : spColorGrey400,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          16.height,
          // Barra de progreso
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso General',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: themeController.isDarkMode
                          ? spColorGrey400
                          : spColorGrey600,
                    ),
                  ),
                  Text(
                    '${controller.progresoGeneral.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: spColorPrimary,
                    ),
                  ),
                ],
              ),
              8.height,
              LinearProgressIndicator(
                value: controller.progresoGeneral / 100,
                backgroundColor: themeController.isDarkMode
                    ? spColorGrey700
                    : spColorGrey200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(spColorSuccess500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumenCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de Productos',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          16.height,
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Completados',
                  controller.productosCompletados.toString(),
                  spColorSuccess500,
                  Icons.check_circle_outline,
                ),
              ),
              12.width,
              Expanded(
                child: _buildStatCard(
                  'En Proceso',
                  controller.productosEnProceso.toString(),
                  spColorTeal600,
                  Icons.loop,
                ),
              ),
              12.width,
              Expanded(
                child: _buildStatCard(
                  'Pendientes',
                  controller.productosPendientes.toString(),
                  spWarning500,
                  Icons.pending_outlined,
                ),
              ),
            ],
          ),
          if (controller.hayProductosPendientes) ...[
            16.height,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: spWarning500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: spWarning500.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: spWarning500,
                    size: 20,
                  ),
                  8.width,
                  Expanded(
                    child: Text(
                      'Hay ${controller.productosPendientes} producto(s) sin completar. ¿Está seguro de finalizar?',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: spWarning500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          8.height,
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          4.height,
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleProductos() {
    return Container(
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Detalle de Productos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Tabs para los diferentes estados
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  labelColor: spColorPrimary,
                  unselectedLabelColor: themeController.isDarkMode
                      ? spColorGrey400
                      : spColorGrey600,
                  indicatorColor: spColorPrimary,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline, size: 16),
                          4.width,
                          Text(
                              'Completados (${controller.productosCompletados})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.loop, size: 16),
                          4.width,
                          Text('En Proceso (${controller.productosEnProceso})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pending_outlined, size: 16),
                          4.width,
                          Text(
                              'Pendientes (${controller.productosPendientes})'),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 200,
                  child: TabBarView(
                    children: [
                      _buildProductosList(controller.productosCompletadosList),
                      _buildProductosList(controller.productosEnProcesoList),
                      _buildProductosList(controller.productosPendientesList),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductosList(List<SPProductoDetalle> productos) {
    if (productos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No hay productos en esta categoría',
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  themeController.isDarkMode ? spColorGrey400 : spColorGrey600,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: themeController.isDarkMode ? spDarkPrimary : spColorGrey50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  themeController.isDarkMode ? spColorGrey600 : spColorGrey200,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      controller.getProductStatusColor(producto.estadoProducto),
                  shape: BoxShape.circle,
                ),
              ),
              8.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombreSeguro,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    2.height,
                    Text(
                      'Item: ${producto.itemSeguro}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: themeController.isDarkMode
                            ? spColorGrey400
                            : spColorGrey600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${producto.unidadesProcesadas ?? 0}/${producto.unidadesRuta ?? 0}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      controller.getProductStatusColor(producto.estadoProducto),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComentariosSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comentarios (Opcional)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          8.height,
          Text(
            'Agregue comentarios adicionales sobre el despacho si es necesario.',
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  themeController.isDarkMode ? spColorGrey400 : spColorGrey600,
            ),
          ),
          16.height,
          TextFormField(
            controller: controller.comentarioController,
            focusNode: controller.comentarioFocusNode,
            maxLines: 4,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            decoration: spInputDecoration(
              context,
              hintText: 'Escriba sus comentarios aquí...',
              borderColor:
                  themeController.isDarkMode ? spColorGrey600 : spColorGrey300,
              fillColor:
                  themeController.isDarkMode ? spDarkPrimary : spColorGrey50,
              hintColor:
                  themeController.isDarkMode ? spColorGrey500 : spColorGrey400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: themeController.isDarkMode ? spColorGrey600 : spColorGrey200,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SPCommonButton(
              onPressed: () => Navigator.pop(context),
              text: 'Cancelar',
              bgColor: Colors.transparent,
              textColor:
                  themeController.isDarkMode ? Colors.white : spColorGrey700,
              borderColor:
                  themeController.isDarkMode ? spColorGrey600 : spColorGrey300,
              height: 48,
            ),
          ),
          16.width,
          Expanded(
            flex: 2,
            child: Obx(() => SPCommonButton(
                  onPressed: controller.isFinalizando.value ||
                          controller.despacho?.id == null
                      ? () {} // Función vacía en lugar de null
                      : () => controller.finalizarDespacho(),
                  text: controller.isFinalizando.value
                      ? 'Finalizando...'
                      : 'Finalizar Despacho',
                  bgColor: controller.isFinalizando.value ||
                          controller.despacho?.id == null
                      ? spColorGrey400
                      : spColorError500,
                  textColor: controller.isFinalizando.value ||
                          controller.despacho?.id == null
                      ? Colors.white54
                      : Colors.white,
                  height: 48,
                )),
          ),
        ],
      ),
    );
  }
}
