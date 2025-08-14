import 'package:flutter/material.dart';
import 'package:sabipay/app/controller/sp_despacho_detalle_controller.dart';
import 'package:sabipay/app/model/sp_despacho_detalle.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/sabipy_theme/theme_controller.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'dart:async';

class SPDespachoDetalleScreen extends StatefulWidget {
  const SPDespachoDetalleScreen({super.key});

  @override
  SPDespachoDetalleScreenState createState() => SPDespachoDetalleScreenState();
}

class SPDespachoDetalleScreenState extends State<SPDespachoDetalleScreen> {
  late SPDespachoDetalleController controller;
  final ThemeController themeController = Get.put(ThemeController());

  // 🔍 Controlador principal del buscador externo
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  late ThemeData theme;
  Timer? debounceTimer;
  DateTime? lastInputTime;

  @override
  void initState() {
    super.initState();
    theme = themeController.isDarkMode
        ? SPWalletTheme.spDarkTheme
        : SPWalletTheme.spLightTheme;
    controller = Get.put(SPDespachoDetalleController());

    // 🎯 Auto-focus inicial y mantener el focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureFocus();
    });

    // 🔄 Re-enfocar automáticamente cada vez que se pierde el focus
    searchFocusNode.addListener(() {
      if (!searchFocusNode.hasFocus &&
          !controller.isModalOpen.value &&
          !controller.isFinalizingModalOpen.value) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted &&
              !controller.isModalOpen.value &&
              !controller.isFinalizingModalOpen.value) {
            _ensureFocus();
          }
        });
      }
    });

    // 🎯 Observar cambios en el estado del modal de productos
    ever(controller.isModalOpen, (isOpen) {
      if (isOpen) {
        // Modal se abrió - quitar focus
        _removeFocus();
      } else {
        // Modal se cerró - restaurar focus después de un delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _ensureFocus();
          }
        });
      }
    });

    // 🎯 Observar cambios en el estado del modal de finalizar
    ever(controller.isFinalizingModalOpen, (isOpen) {
      if (isOpen) {
        // Modal de finalizar se abrió - quitar focus
        _removeFocus();
      } else {
        // Modal de finalizar se cerró - restaurar focus después de un delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _ensureFocus();
          }
        });
      }
    });
  }

  void _ensureFocus() {
    // Solo enfocar si no hay ningún modal abierto
    if (mounted &&
        !searchFocusNode.hasFocus &&
        !controller.isModalOpen.value &&
        !controller.isFinalizingModalOpen.value) {
      searchFocusNode.requestFocus();
    }
  }

  void _removeFocus() {
    if (searchFocusNode.hasFocus) {
      searchFocusNode.unfocus();
    }
  }

  @override
  void dispose() {
    debounceTimer?.cancel();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SPDespachoDetalleController>(
      init: controller,
      builder: (controller) {
        return Scaffold(
          backgroundColor:
              themeController.isDarkMode ? spDarkPrimary : spColorLightBg,
          appBar: _buildAppBar(),
          body: GestureDetector(
            onTap: () {
              // Solo re-enfocar si no hay modal abierto
              if (!controller.isModalOpen.value &&
                  !controller.isFinalizingModalOpen.value) {
                _ensureFocus();
              }
            },
            child: Column(
              children: [
                _buildHeader(),
                _buildExternalSearchBar(), // 🔍 Buscador externo
                _buildFilters(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: spColorPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: spColorPrimary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.route, size: 16, color: spColorPrimary),
            4.width,
            Text(
              'Ruta: ${controller.idRuta ?? 'N/A'}',
              style: TextStyle(
                color: spColorPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      backgroundColor:
          themeController.isDarkMode ? spDarkPrimary : spColorLightBg,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: themeController.isDarkMode ? spCardDark : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: themeController.isDarkMode ? Colors.white : spColorGrey700,
          ),
        ),
      ),
      actions: [
        // Refrescar
        _buildActionButton(
          icon: Icons.refresh,
          onPressed: () => controller.refreshData(),
          tooltip: 'Actualizar',
        ),
        8.width,
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
    String? tooltip,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      child: Material(
        color: Colors.transparent,
        child: Tooltip(
          message: tooltip ?? '',
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isActive
                    ? spColorPrimary.withOpacity(0.1)
                    : (themeController.isDarkMode ? spCardDark : Colors.white),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive
                      ? spColorPrimary.withOpacity(0.3)
                      : (themeController.isDarkMode
                          ? spColorGrey600
                          : spColorGrey200),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 20,
                color: isActive
                    ? spColorPrimary
                    : (themeController.isDarkMode
                        ? Colors.white
                        : spColorGrey700),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(4),
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
      child: GetBuilder<SPDespachoDetalleController>(
        builder: (controller) {
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: controller.despacho.value?.esActivo == true
                          ? spColorSuccess500
                          : spColorGrey400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  8.width,
                  Expanded(
                    child: Text(
                      controller.despacho.value?.estadoDescripcion ??
                          'Cargando...',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${controller.progresoGeneral.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              8.height,
              Row(
                children: [
                  _buildCompactStat(
                    controller.productosCompletados.toString(),
                    'Completados',
                    spColorSuccess500,
                  ),
                  const Spacer(),
                  _buildCompactStat(
                    controller.productosPendientes.toString(),
                    'Pendientes',
                    spWarning500,
                  ),
                  const Spacer(),
                  _buildCompactStat(
                    controller.productosEnProceso.toString(),
                    'En Proceso',
                    spColorTeal600,
                  ),
                ],
              ),
              4.height,
              LinearProgressIndicator(
                value: controller.progresoGeneral / 100,
                backgroundColor: themeController.isDarkMode
                    ? spColorGrey700
                    : spColorGrey200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(spColorSuccess500),
              ),
            ],
          );
        },
      ),
    );
  }

  // 🔍 NUEVO: Input de búsqueda externo delgado con focus automático
  Widget _buildExternalSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: themeController.isDarkMode ? spColorGrey600 : spColorGrey200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: themeController.isDarkMode ? spColorGrey400 : spColorGrey500,
            size: 20,
          ),
          8.width,
          Expanded(
            child: TextField(
              controller: searchController,
              focusNode: searchFocusNode,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    themeController.isDarkMode ? Colors.white : spColorGrey800,
              ),
              decoration: InputDecoration(
                hintText: 'Escanea o escribe código del producto...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: themeController.isDarkMode
                      ? spColorGrey500
                      : spColorGrey400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              keyboardType: TextInputType.none, // Desactiva teclado virtual
              enableInteractiveSelection: false,
              textInputAction: TextInputAction.search,
              onChanged: _handleSearchInput,
              onSubmitted: _handleSearchSubmit,
              onTap: () {
                // Solo enfocar si no hay modal abierto
                if (!controller.isModalOpen.value &&
                    !controller.isFinalizingModalOpen.value) {
                  _ensureFocus();
                }
              },
            ),
          ),
          if (searchController.text.isNotEmpty) ...[
            8.width,
            GestureDetector(
              onTap: _clearSearch,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: themeController.isDarkMode
                      ? spColorGrey600
                      : spColorGrey300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.clear,
                  size: 14,
                  color: themeController.isDarkMode
                      ? Colors.white
                      : spColorGrey700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleSearchInput(String value) {
    final now = DateTime.now();

    // Cancelar timer anterior
    debounceTimer?.cancel();

    // Medir velocidad de escritura para detectar scanner vs manual
    if (lastInputTime != null) {
      final timeDiff = now.difference(lastInputTime!).inMilliseconds;

      // Scanner: escritura rápida (< 50ms entre caracteres)
      if (timeDiff < 50 && value.length >= 6) {
        debounceTimer = Timer(const Duration(milliseconds: 100), () {
          if (value.trim().isNotEmpty) {
            _processSearch(value.trim());
          }
        });
      }
      // Manual: escritura lenta (>= 50ms entre caracteres)
      else if (timeDiff >= 50 && value.length >= 3) {
        debounceTimer = Timer(const Duration(milliseconds: 800), () {
          if (value.trim().isNotEmpty) {
            _processSearch(value.trim());
          }
        });
      }
    }

    lastInputTime = now;

    // También buscar en tiempo real para filtrar lista
    controller.searchProductos(value);
  }

  void _handleSearchSubmit(String value) {
    debounceTimer?.cancel();
    if (value.trim().isNotEmpty) {
      _processSearch(value.trim());
    }
  }

  void _processSearch(String codigo) {
    controller.buscarYAbrirProducto(context, codigo);
    _clearSearch();
    // El focus se manejará automáticamente por el observer si se abre modal
  }

  void _clearSearch() {
    searchController.clear();
    controller.searchProductos(''); // Limpiar filtros
    // Solo re-enfocar si no hay modal abierto
    if (!controller.isModalOpen.value &&
        !controller.isFinalizingModalOpen.value) {
      _ensureFocus();
    }
  }

  Widget _buildCompactStat(String value, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        4.width,
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        2.width,
        Text(
          label,
          style: TextStyle(
            color: themeController.isDarkMode ? spColorGrey400 : spColorGrey600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: themeController.isDarkMode ? spColorGrey600 : spColorGrey300,
            width: 1.5,
          ),
        ),
      ),
      child: SizedBox(
        height: 32,
        child: GetBuilder<SPDespachoDetalleController>(
          builder: (controller) {
            return ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Filtros normales
                for (int i = 0; i < controller.filterOptions.length; i++) ...[
                  _buildFilterChip(
                    controller.filterOptions[i],
                    i,
                    controller.selectedFilterIndex.value == i,
                    false, // No es botón finalizar
                  ),
                  if (i < controller.filterOptions.length - 1) 8.width,
                ],
                // Separador
                16.width,
                Container(
                  width: 1,
                  height: 20,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: themeController.isDarkMode
                      ? spColorGrey600
                      : spColorGrey300,
                ),
                16.width,
                // 🆕 Botón Finalizar
                _buildFinalizarButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label, int index, bool isSelected, bool isFinalizarButton) {
    return InkWell(
      onTap: () {
        if (!isFinalizarButton) {
          controller.changeFilter(index);
          // Solo re-enfocar si no hay modal abierto
          if (!controller.isModalOpen.value &&
              !controller.isFinalizingModalOpen.value) {
            _ensureFocus();
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? spColorPrimary
              : (themeController.isDarkMode ? spColorGrey700 : spColorGrey100),
          borderRadius: BorderRadius.circular(16),
          border:
              isSelected ? Border.all(color: spColorPrimary, width: 1) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (themeController.isDarkMode ? Colors.white : spColorGrey700),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // 🆕 Botón Finalizar separado
  Widget _buildFinalizarButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.navegarAFinalizarDespacho(); // ← NUEVA LÍNEA
          // Solo re-enfocar si no hay modal abierto
          if (!controller.isModalOpen.value &&
              !controller.isFinalizingModalOpen.value) {
            _ensureFocus();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            color: spColorError500,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: spColorError500, width: 1),
            boxShadow: [
              BoxShadow(
                color: spColorError500.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 14,
                color: Colors.white,
              ),
              4.width,
              const Text(
                'Finalizar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshData();
          // Solo re-enfocar si no hay modal abierto
          if (!controller.isModalOpen.value &&
              !controller.isFinalizingModalOpen.value) {
            _ensureFocus();
          }
        },
        color: spColorPrimary,
        child: GetBuilder<SPDespachoDetalleController>(
          builder: (controller) {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: spColorPrimary),
              );
            }

            final productos = controller.filteredProductos;

            if (productos.isEmpty) {
              return _buildEmptyWidget();
            }

            return _buildProductsList(productos);
          },
        ),
      ),
    );
  }

  Widget _buildProductsList(List<SPProductoDetalle> productos) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];
        return _buildProductoCard(producto);
      },
    );
  }

  Widget _buildProductoCard(SPProductoDetalle producto) {
    // 🆕 Verificar si el producto puede ser procesado
    final puedeSerProcesado = controller.puedeSerProcesado(producto);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: themeController.isDarkMode ? spColorGrey600 : spColorGrey200,
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: puedeSerProcesado
              ? () {
                  controller.openProcessModal(context, producto);
                  // El focus se manejará automáticamente por el observer
                }
              : null, // 🆕 Deshabilitar tap si está completado
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: controller
                            .getProductStatusColor(producto.estadoProducto),
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
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              // 🆕 Cambiar opacidad si está completado
                              color: puedeSerProcesado
                                  ? null
                                  : (themeController.isDarkMode
                                      ? Colors.white54
                                      : Colors.black54),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          4.height,
                          Text(
                            'Item: ${producto.itemSeguro} | Lote: ${producto.loteSeguro}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: themeController.isDarkMode
                                  ? spColorGrey400
                                  : spColorGrey600,
                            ),
                          ),
                          if (producto.codigoBarra?.isNotEmpty == true) ...[
                            2.height,
                            Row(
                              children: [
                                Icon(
                                  Icons.qr_code,
                                  size: 12,
                                  color: themeController.isDarkMode
                                      ? spColorGrey400
                                      : spColorGrey600,
                                ),
                                4.width,
                                Text(
                                  producto.codigoBarra!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: themeController.isDarkMode
                                        ? spColorGrey400
                                        : spColorGrey600,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: controller
                                .getProductStatusColor(producto.estadoProducto)
                                .withAlpha(26),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            producto.estadoDescripcion,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: controller.getProductStatusColor(
                                  producto.estadoProducto),
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        4.height,
                        Text(
                          '${producto.unidadesProcesadas ?? 0} Proc /${producto.unidadesRuta ?? 0} Tot',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                8.height,
                LinearProgressIndicator(
                  value: producto.progreso,
                  backgroundColor: themeController.isDarkMode
                      ? spColorGrey700
                      : spColorGrey200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    controller.getProductStatusColor(producto.estadoProducto),
                  ),
                ),
                8.height,
                // 🆕 Mostrar botón solo si puede ser procesado
                if (puedeSerProcesado)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.openProcessModal(context, producto);
                        // El focus se manejará automáticamente por el observer
                      },
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Trabajar Producto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: spColorPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  )
                else
                  // 🆕 Mostrar estado completado en lugar del botón
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: spColorSuccess500.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: spColorSuccess500.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: spColorSuccess500,
                        ),
                        8.width,
                        Text(
                          'Producto Completado',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: spColorSuccess500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: themeController.isDarkMode
                    ? spColorGrey400
                    : spColorGrey500,
              ),
              12.height,
              Text(
                'No hay productos',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: themeController.isDarkMode
                      ? spColorGrey400
                      : spColorGrey600,
                ),
              ),
              4.height,
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Los productos se están cargando o no hay productos para mostrar con los filtros actuales',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              16.height,
              ElevatedButton.icon(
                onPressed: () {
                  controller.refreshData();
                  // Solo re-enfocar si no hay modal abierto
                  if (!controller.isModalOpen.value &&
                      !controller.isFinalizingModalOpen.value) {
                    _ensureFocus();
                  }
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Recargar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: spColorPrimary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
