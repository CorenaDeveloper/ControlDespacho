import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sabipay/app/controller/sp_carga_camion_detalle_controller.dart';
import 'package:sabipay/app/model/sp_carga_camion_detalle.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/sabipy_theme/theme_controller.dart';
import 'package:nb_utils/nb_utils.dart';

class SPCargaCamionDetalleScreen extends StatefulWidget {
  const SPCargaCamionDetalleScreen({super.key});

  @override
  SPCargaCamionDetalleScreenState createState() =>
      SPCargaCamionDetalleScreenState();
}

class SPCargaCamionDetalleScreenState
    extends State<SPCargaCamionDetalleScreen> {
  final SPCargaCamionDetalleController controller =
      Get.put(SPCargaCamionDetalleController());
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
    return GetBuilder<SPCargaCamionDetalleController>(
      init: controller,
      builder: (controller) {
        return Scaffold(
          backgroundColor:
              themeController.isDarkMode ? spDarkPrimary : spColorLightBg,
          appBar: _buildAppBar(),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(),
                    _buildSearchAndFilters(),
                    _buildStats(),
                    Expanded(child: _buildProductosList()),
                  ],
                ),

                // Modal de validación
                Obx(() => controller.isModalOpen.value
                    ? _buildValidationModal()
                    : const SizedBox.shrink()),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomActions(),
          floatingActionButton: _buildScanFab(),
        );
      },
    );
  }

  /// AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor:
          themeController.isDarkMode ? spDarkPrimary : Colors.white,
      elevation: 0,
      title: Text(
        'Validación Física',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: themeController.isDarkMode ? Colors.white : spTextColor,
        ),
      ),
      leading: Center(
        child: InkWell(
          onTap: () => Get.back(),
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

  /// Header
  Widget _buildHeader() {
    return Obx(() {
      final carga = controller.carga.value;
      if (carga == null) return const SizedBox.shrink();

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
                    'Ruta: ${carga.idRuta ?? 'N/A'}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  4.height,
                  Text(
                    'Validación Física de Productos',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  4.height,
                  Text(
                    'Usuario: ${carga.codigoUser ?? 'N/A'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Búsqueda y filtros
  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: spColorGrey400.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Búsqueda
          TextField(
            onChanged: controller.updateSearch,
            decoration: InputDecoration(
              hintText: 'Buscar producto...',
              prefixIcon: Icon(Icons.search, color: spColorGrey500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: spColorGrey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: spColorPrimary),
              ),
              filled: true,
              fillColor:
                  themeController.isDarkMode ? spColorGrey800 : spColorGrey100,
            ),
          ),

          12.height,

          // Filtros
          SizedBox(
            height: 40,
            child: Obx(() => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.filterOptions.length,
                  itemBuilder: (context, index) {
                    final isSelected =
                        controller.selectedFilterIndex.value == index;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          controller.filterOptions[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : spColorGrey600,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) => controller.changeFilter(index),
                        backgroundColor: themeController.isDarkMode
                            ? spColorGrey700
                            : spColorGrey200,
                        selectedColor: spColorPrimary,
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? spColorPrimary : spColorGrey300,
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }

  /// Estadísticas
  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pendientes',
                  '${controller.productosPendientes.value}',
                  spWarning500,
                  Icons.pending,
                ),
              ),
              8.width,
              Expanded(
                child: _buildStatCard(
                  'Validados',
                  '${controller.productosValidados.value}',
                  spColorSuccess500,
                  Icons.check_circle,
                ),
              ),
              8.width,
              Expanded(
                child: _buildStatCard(
                  'Progreso',
                  '${controller.progresoGeneral.value.toStringAsFixed(1)}%',
                  spColorTeal600,
                  Icons.trending_up,
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          4.height,
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          2.height,
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Lista de productos
  Widget _buildProductosList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredProductos.isEmpty) {
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
                'No hay productos',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: themeController.isDarkMode
                      ? spColorGrey400
                      : spColorGrey600,
                ),
              ),
              8.height,
              Text(
                'No se encontraron productos para el filtro seleccionado',
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
          itemCount: controller.filteredProductos.length,
          itemBuilder: (context, index) {
            final producto = controller.filteredProductos[index];
            return _buildProductoCard(producto);
          },
        ),
      );
    });
  }

  /// Tarjeta de producto
  Widget _buildProductoCard(ProductoCargaCamion producto) {
    final statusColor = controller.getProductStatusColor(producto);
    final statusIcon = controller.getProductStatusIcon(producto);

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
        onTap: () => controller.abrirModalValidacion(producto),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del producto
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.itemId ?? 'N/A',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        4.height,
                        Text(
                          producto.descripcion ?? 'Sin descripción',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: themeController.isDarkMode
                                ? spColorGrey400
                                : spColorGrey600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              12.height,

              // Información del producto (SIN cantidades originales)
              Row(
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 16,
                    color: spColorGrey500,
                  ),
                  4.width,
                  Text(
                    'Código: ${producto.codigoBarra ?? 'N/A'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: spColorGrey600,
                    ),
                  ),
                  16.width,
                  if (producto.lote != null) ...[
                    Icon(
                      Icons.label,
                      size: 16,
                      color: spColorGrey500,
                    ),
                    4.width,
                    Text(
                      'Lote: ${producto.lote}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: spColorGrey600,
                      ),
                    ),
                  ],
                ],
              ),

              // Cantidades validadas (solo si existen)
              if (producto.cajasValidadas != null ||
                  producto.unidadesValidadas != null) ...[
                12.height,
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: spColorTeal600.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: spColorTeal600.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cantidades Validadas:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: spColorTeal600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      4.height,
                      Row(
                        children: [
                          if (producto.cajasValidadas != null) ...[
                            Icon(Icons.archive,
                                size: 16, color: spColorTeal600),
                            4.width,
                            Text(
                              '${producto.cajasValidadas} cajas',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: spColorTeal600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            16.width,
                          ],
                          if (producto.unidadesValidadas != null) ...[
                            Icon(Icons.inventory,
                                size: 16, color: spColorTeal600),
                            4.width,
                            Text(
                              '${producto.unidadesValidadas} unidades',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: spColorTeal600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              12.height,

              // Estado y fecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      producto.estaValidado
                          ? 'Validado'
                          : producto.tieneValidacion
                              ? 'Procesado'
                              : 'Pendiente',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (producto.fechaValidacion != null)
                    Text(
                      controller.formatDate(producto.fechaValidacion),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: spColorGrey600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Acciones del bottom
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: spColorGrey400.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() => Row(
            children: [
              // Progreso
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progreso: ${controller.progresoGeneral.value.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    4.height,
                    LinearProgressIndicator(
                      value: controller.progresoGeneral.value / 100,
                      backgroundColor: spColorGrey200,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(spColorSuccess500),
                    ),
                  ],
                ),
              ),

              16.width,

              // Botón finalizar
              ElevatedButton(
                onPressed: controller.isProcessing.value
                    ? null
                    : controller.finalizarCarga,
                style: ElevatedButton.styleFrom(
                  backgroundColor: spColorPrimary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isProcessing.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Finalizar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          )),
    );
  }

  /// FAB para escanear
  Widget _buildScanFab() {
    return FloatingActionButton(
      onPressed: () => _showScanDialog(),
      backgroundColor: spColorPrimary,
      child: const Icon(
        Icons.qr_code_scanner,
        color: Colors.white,
      ),
    );
  }

  /// Diálogo de escaneo
  void _showScanDialog() {
    final TextEditingController scanController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.qr_code_scanner, color: spColorPrimary),
            8.width,
            const Text('Escanear Producto'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ingrese o escanee el código del producto:',
              style: theme.textTheme.bodyMedium,
            ),
            16.height,
            TextField(
              controller: scanController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Código del producto',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.qr_code, color: spColorGrey500),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Get.back();
                  controller.buscarProductoPorCodigo(value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final codigo = scanController.text.trim();
              if (codigo.isNotEmpty) {
                Get.back();
                controller.buscarProductoPorCodigo(codigo);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: spColorPrimary),
            child: const Text('Buscar'),
          ),
        ],
      ),
    ).then((_) => scanController.dispose());
  }

  /// Modal de validación
  Widget _buildValidationModal() {
    final producto = controller.selectedProducto.value;
    if (producto == null) return const SizedBox.shrink();

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: themeController.isDarkMode ? spCardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.local_shipping, color: spColorPrimary, size: 24),
                  12.width,
                  Expanded(
                    child: Text(
                      'Validar Producto',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: spColorPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.isModalOpen.value = false,
                    icon: Icon(Icons.close, color: spColorGrey500),
                  ),
                ],
              ),

              16.height,

              // Info del producto
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: spColorGrey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.itemId ?? 'N/A',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    4.height,
                    Text(
                      producto.descripcion ?? 'Sin descripción',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: spColorGrey600,
                      ),
                    ),
                    8.height,
                    Text(
                      'Código: ${producto.codigoBarra ?? 'N/A'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: spColorGrey600,
                      ),
                    ),
                  ],
                ),
              ),

              20.height,

              // Campos de entrada
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.cajasController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Cajas',
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.archive, color: spColorTeal600),
                      ),
                    ),
                  ),
                  16.width,
                  Expanded(
                    child: TextField(
                      controller: controller.unidadesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Unidades',
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon:
                            Icon(Icons.inventory, color: spColorTeal600),
                      ),
                    ),
                  ),
                ],
              ),

              16.height,

              // Observaciones
              TextField(
                controller: controller.observacionesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Observaciones (opcional)',
                  hintText: 'Ingrese observaciones...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.note, color: spColorGrey500),
                ),
              ),

              24.height,

              // Botones
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => controller.isModalOpen.value = false,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  16.width,
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isProcessingModal.value
                              ? null
                              : controller.validarProducto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: spColorPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: controller.isProcessingModal.value
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Validar',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
