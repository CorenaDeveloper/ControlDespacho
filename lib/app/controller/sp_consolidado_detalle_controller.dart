// app/controller/sp_consolidado_detalle_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sabipay/app/model/sp_consolidado_detalle.dart';
import 'package:sabipay/services/route_service.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'dart:async';

class SPConsolidadoDetalleController extends GetxController {
  final RouteService _routeService = RouteService.instance;

  // Parámetros básicos
  int? idConsolidado;
  final isProcessing = false.obs;

  // Estado de carga
  final isLoading = false.obs;
  final RxBool isModalOpen = false.obs;
  final RxBool isProcessingModal = false.obs;

  // 🆕 PAGINACIÓN
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;
  final currentPage = 1.obs;
  static const int itemsPerPage = 20; // Cargar 20 items por página
  final ScrollController scrollController = ScrollController();

  // Datos principales
  final productos = <ConsolidadoProductoDetalle>[].obs;
  final filteredProductos = <ConsolidadoProductoDetalle>[].obs;
  final allProductos = <ConsolidadoProductoDetalle>[]; // Cache completo

  // Filtros y búsqueda
  final selectedFilterIndex = 1.obs;
  final searchQuery = ''.obs;
  final List<String> filterOptions = [
    'Todos',
    'Pendientes',
    'En Proceso',
    'Completados'
  ];

  // Estadísticas básicas
  final productosCompletados = 0.obs;
  final productosPendientes = 0.obs;
  final productosEnProceso = 0.obs;
  final progresoGeneral = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    idConsolidado = Get.arguments as int?;

    // 🆕 Configurar scroll listener para paginación
    _setupScrollListener();

    if (idConsolidado != null) {
      loadConsolidadoDetalle();
    } else {
      _showErrorMessage('No se proporcionó ID de consolidado válido');
    }
  }

  /// Método para ordenar productos con el criterio personalizado:
  /// 1. Primero por el primer dígito del itemId (1, 2, 3, etc.)
  /// 2. Segundo por cantidad de unidades descendente dentro de cada grupo
  List<T> sortProductosPersonalizado<T>(
    List<T> productos, {
    required String Function(T) getItemId,
    required int Function(T) getUnidades,
  }) {
    if (productos.isEmpty) return productos;

    // Crear una copia para no modificar la lista original
    final List<T> productosCopia = List.from(productos);

    // Ordenar con criterio personalizado
    productosCopia.sort((a, b) {
      final itemIdA = getItemId(a);
      final itemIdB = getItemId(b);
      final unidadesA = getUnidades(a);
      final unidadesB = getUnidades(b);

      // Extraer primer dígito del itemId de forma segura
      int getFirstDigit(String itemId) {
        if (itemId.isEmpty) return 0;

        // Buscar el primer dígito en la cadena
        for (int i = 0; i < itemId.length; i++) {
          final char = itemId[i];
          if (char.contains(RegExp(r'[0-9]'))) {
            return int.tryParse(char) ?? 0;
          }
        }
        return 0; // Si no encuentra dígitos
      }

      final primerDigitoA = getFirstDigit(itemIdA);
      final primerDigitoB = getFirstDigit(itemIdB);

      // 1. Ordenar primero por primer dígito (ascendente)
      final comparacionDigito = primerDigitoA.compareTo(primerDigitoB);
      if (comparacionDigito != 0) {
        return comparacionDigito;
      }

      // 2. Si tienen el mismo primer dígito, ordenar por unidades (descendente)
      return unidadesB.compareTo(unidadesA); // Descendente: B compareTo A
    });

    return productosCopia;
  }

  // 🆕 Configurar listener del scroll
  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore.value &&
          hasMoreData.value &&
          searchQuery.value.isEmpty) {
        // Solo paginar si no hay búsqueda activa
        _loadMoreProducts();
      }
    });
  }

  void _updateStatistics() {
    if (allProductos.isEmpty) {
      productosCompletados.value = 0;
      productosPendientes.value = 0;
      productosEnProceso.value = 0;
      progresoGeneral.value = 0.0;
      return;
    }

    productosCompletados.value =
        allProductos.where((p) => p.estaCompletado).length;
    productosPendientes.value =
        allProductos.where((p) => p.estaPendiente).length;
    productosEnProceso.value =
        allProductos.where((p) => p.estaEnProceso).length;

    final total = allProductos.length;
    progresoGeneral.value =
        total > 0 ? (productosCompletados.value / total) * 100 : 0.0;
  }

  /// Cargar detalles del consolidado (primera página)
  Future<void> loadConsolidadoDetalle() async {
    if (idConsolidado == null) {
      _showErrorMessage('ID de consolidado no válido');
      return;
    }

    try {
      isLoading.value = true;
      currentPage.value = 1;
      hasMoreData.value = true;

      final response = await _routeService.getConsolidadoDetalle(
        idConsolidado: idConsolidado!,
      );

      if (response.isSuccess && response.data != null) {
        final consolidadoDetalleResponse =
            ConsolidadoDetalleResponse.fromJson(response.data!);

        if (consolidadoDetalleResponse.success) {
          // Guardar todos los productos en cache
          allProductos.clear();
          final productosOrdenados = sortProductosPersonalizado(
            consolidadoDetalleResponse.data,
            getItemId: (producto) => producto.itemSeguro,
            getUnidades: (producto) => producto.unidadesConsolidado,
          );
          allProductos.addAll(productosOrdenados);

          _updateStatistics();
          _applyPagination();

          if (allProductos.isEmpty) {
            _showInfoMessage('No se encontraron productos en este consolidado');
          }
        } else {
          _showErrorMessage(consolidadoDetalleResponse.message.isNotEmpty
              ? consolidadoDetalleResponse.message
              : 'No se encontraron datos del consolidado');
        }
      } else {
        _showErrorMessage(response.message);
      }
    } catch (e) {
      _showErrorMessage(
          'Error al cargar detalle del consolidado: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // 🆕 Cargar más productos (paginación)
  Future<void> _loadMoreProducts() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      // Simular delay de red para mejor UX
      await Future.delayed(const Duration(milliseconds: 300));

      _applyPagination();
    } catch (e) {
      _showErrorMessage('Error al cargar más productos: ${e.toString()}');
      currentPage.value--; // Revertir página en caso de error
    } finally {
      isLoadingMore.value = false;
    }
  }

  // 🆕 Aplicar paginación a los productos filtrados
  void _applyPagination() {
    if (searchQuery.value.isNotEmpty) {
      // Si hay búsqueda, mostrar todos los resultados filtrados
      _applyFilters();
      return;
    }

    // Aplicar filtro de estado primero
    var filtered = List<ConsolidadoProductoDetalle>.from(allProductos);

    switch (selectedFilterIndex.value) {
      case 1: // Pendientes
        filtered = filtered.where((p) => p.estaPendiente).toList();
        break;
      case 2: // En Proceso
        filtered = filtered.where((p) => p.estaEnProceso).toList();
        break;
      case 3: // Completados
        filtered = filtered.where((p) => p.estaCompletado).toList();
        break;
      default: // Todos
        break;
    }

    filtered = sortProductosPersonalizado(
      filtered,
      getItemId: (producto) => producto.itemSeguro,
      getUnidades: (producto) => producto.unidadesConsolidado,
    );
    // Aplicar paginación
    final totalItems = filtered.length;
    final endIndex = currentPage.value * itemsPerPage;

    if (endIndex >= totalItems) {
      hasMoreData.value = false;
      filteredProductos.value = filtered;
    } else {
      hasMoreData.value = true;
      filteredProductos.value = filtered.take(endIndex).toList();
    }

    update();
  }

  /// Cambiar filtro con actualización de UI
  void changeFilter(int index) {
    if (selectedFilterIndex.value != index) {
      selectedFilterIndex.value = index;
      currentPage.value = 1; // 🆕 Reset pagination
      hasMoreData.value = true;
      _applyPagination();
      update();
    }
  }

  /// Buscar productos
  void searchProductos(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  /// Aplicar filtros y búsqueda (sin paginación para búsquedas)
  void _applyFilters() {
    if (allProductos.isEmpty) {
      filteredProductos.clear();
      return;
    }

    var filtered = List<ConsolidadoProductoDetalle>.from(allProductos);

    // Aplicar filtro por estado
    switch (selectedFilterIndex.value) {
      case 1: // Pendientes
        filtered = filtered.where((p) => p.estaPendiente).toList();
        break;
      case 2: // En Proceso
        filtered = filtered.where((p) => p.estaEnProceso).toList();
        break;
      case 3: // Completados
        filtered = filtered.where((p) => p.estaCompletado).toList();
        break;
      default: // Todos
        break;
    }

    // Aplicar búsqueda si hay texto
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((producto) {
        final nombre = producto.nombreSeguro.toLowerCase();
        final codigo = producto.codigoSeguro.toLowerCase();
        final itemId = producto.itemSeguro.toLowerCase();
        final lote = producto.loteSeguro.toLowerCase();
        final codigoBarra = producto.codigoBarra.toLowerCase();

        return nombre.contains(query) ||
            codigo.contains(query) ||
            itemId.contains(query) ||
            lote.contains(query) ||
            codigoBarra.contains(query);
      }).toList();

      // Para búsquedas, mostrar todos los resultados sin paginación
      hasMoreData.value = false;
    }

    filtered = sortProductosPersonalizado(
      filtered,
      getItemId: (producto) => producto.itemSeguro,
      getUnidades: (producto) => producto.unidadesConsolidado,
    );

    filteredProductos.value = filtered;
    update();
  }

  /// Refrescar datos
  Future<void> refreshData() async {
    _showInfoMessage('Actualizando datos...');
    currentPage.value = 1; // 🆕 Reset pagination
    hasMoreData.value = true;
    await loadConsolidadoDetalle();
  }

  /// NUEVA FUNCIÓN: Buscar productos por código de barras con manejo de lotes múltiples
  List<ConsolidadoProductoDetalle> findProductsByBarcode(String barcode) {
    if (allProductos.isEmpty || barcode.isEmpty) return [];

    final normalizedScanned = barcode.trim().toLowerCase();

    // Buscar por código de barras exacto
    List<ConsolidadoProductoDetalle> productosPorCodigo = allProductos
        .where((p) => p.codigoBarra.trim().toLowerCase() == normalizedScanned)
        .toList();

    // Si no encuentra por código de barras, buscar por otros campos
    if (productosPorCodigo.isEmpty) {
      productosPorCodigo = allProductos
          .where((p) =>
              p.codigoSeguro.toLowerCase().contains(normalizedScanned) ||
              p.itemSeguro.toLowerCase().contains(normalizedScanned) ||
              p.loteSeguro.toLowerCase().contains(normalizedScanned))
          .toList();
    }

    return productosPorCodigo;
  }

  // 🆕 Scroll hacia arriba
  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Obtener color del estado del producto
  Color getProductStatusColor(String? estado) {
    switch (estado?.toUpperCase()) {
      case 'PENDIENTE':
        return spWarning500;
      case 'EN_PROCESO':
        return spColorPrimary;
      case 'COMPLETADO':
        return spColorSuccess500;
      default:
        return spColorGrey400;
    }
  }

  /// Verificar si un producto puede ser procesado
  bool puedeSerProcesado(ConsolidadoProductoDetalle producto) {
    return !producto.estaCompletado;
  }

  /// NUEVA FUNCIÓN: Buscar y abrir producto con manejo de lotes múltiples
  void buscarYAbrirProducto(BuildContext context, String codigoBarra) {
    final productosEncontrados = findProductsByBarcode(codigoBarra);

    if (productosEncontrados.isEmpty) {
      _showWarningMessage('Producto no encontrado para código: $codigoBarra');
      return;
    }

    if (productosEncontrados.length == 1) {
      final producto = productosEncontrados.first;
      if (puedeSerProcesado(producto)) {
        openProcessModal(context, producto);
      } else {
        _showWarningMessage(
            'Producto ${producto.nombreSeguro} ya está completado');
      }
      return;
    }

    _showProductSelectionModal(context, productosEncontrados, codigoBarra);
  }

  /// Modal para seleccionar entre productos con diferentes lotes
  void _showProductSelectionModal(BuildContext context,
      List<ConsolidadoProductoDetalle> productos, String codigoEscaneado) {
    final productosDisponibles =
        productos.where((p) => puedeSerProcesado(p)).toList();

    if (productosDisponibles.isEmpty) {
      _showWarningMessage(
          'Todos los productos con código $codigoEscaneado están completados');
      return;
    }

    if (productosDisponibles.length == 1) {
      openProcessModal(context, productosDisponibles.first);
      return;
    }

    isModalOpen.value = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? spCardDark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: spColorPrimary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.qr_code_scanner, color: spColorPrimary, size: 24),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Múltiples Lotes Encontrados',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        4.height,
                        Text(
                          'Código: $codigoEscaneado',
                          style: TextStyle(
                            fontSize: 12,
                            color: Get.isDarkMode
                                ? spColorGrey400
                                : spColorGrey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      isModalOpen.value = false;
                      Get.back();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Lista de productos
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: productosDisponibles.length,
                itemBuilder: (context, index) {
                  final producto = productosDisponibles[index];
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Get.isDarkMode ? spColorGrey600 : spColorGrey300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      onTap: () {
                        isModalOpen.value = false;
                        Navigator.of(context).pop();
                        Future.delayed(const Duration(milliseconds: 300), () {
                          openProcessModal(Get.context!, producto);
                        });
                      },
                      leading: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: getProductStatusColor(producto.estadoProducto),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        producto.nombreSeguro,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lote: ${producto.loteSeguro}',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Pendiente: ${producto.unidadesPendientes} unidades',
                            style: TextStyle(
                              fontSize: 12,
                              color: spWarning500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: spColorPrimary,
                      ),
                    ),
                  );
                },
              ),
            ),

            16.height,
          ],
        ),
      ),
    ).whenComplete(() {
      isModalOpen.value = false;
    });
  }

  /// Abrir modal de procesamiento
  void openProcessModal(
      BuildContext context, ConsolidadoProductoDetalle producto) {
    isModalOpen.value = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => _buildProcessModal(context, producto),
    ).whenComplete(() {
      isModalOpen.value = false;
      isProcessingModal.value = false;
    });
  }

  /// Modal  para procesar producto
  Widget _buildProcessModal(
      BuildContext context, ConsolidadoProductoDetalle producto) {
    final TextEditingController cajasController = TextEditingController();
    final TextEditingController unidadesController = TextEditingController();

    void procesarYCerrarModal() async {
      if (isProcessingModal.value) return;

      final cajas = int.tryParse(cajasController.text) ?? 0;
      final unidades = int.tryParse(unidadesController.text) ?? 0;

      if (cajas <= 0 && unidades <= 0) {
        Get.snackbar(
          '⚠️ Atención',
          'Debe ingresar al menos una caja o unidad',
          backgroundColor: spWarning500,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      isProcessingModal.value = true;

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      await Future.delayed(const Duration(milliseconds: 300));
      await procesarProducto(producto, cajas: cajas, unidades: unidades);
    }

    void cerrarModal() {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        isModalOpen.value = false;
      },
      child: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            procesarYCerrarModal();
          } else if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            cerrarModal();
          }
        },
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? spCardDark : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header compacto
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: spColorPrimary.withAlpha(26),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color:
                                getProductStatusColor(producto.estadoProducto),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            producto.nombreSeguro,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                getProductStatusColor(producto.estadoProducto)
                                    .withAlpha(52),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${producto.unidadesPreparadas}/${producto.unidadesConsolidado}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: getProductStatusColor(
                                  producto.estadoProducto),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: cerrarModal,
                          icon: const Icon(Icons.close, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                        ),
                      ],
                    ),

                    // Item ID más visible
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: spColorPrimary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: spColorPrimary.withOpacity(0.3)),
                          ),
                          child: Text(
                            'Item: ${producto.itemSeguro}',
                            style: TextStyle(
                              color: spColorPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Lote más visible
                        if (producto.loteSeguro != 'Sin lote')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: spColorTeal600.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: spColorTeal600.withOpacity(0.3)),
                            ),
                            child: Text(
                              'Lote: ${producto.loteSeguro}',
                              style: TextStyle(
                                color: spColorTeal600,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Información y formulario
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Fecha de vencimiento (más compacta)
                    if (producto.fechaVencimiento != null &&
                        producto.fechaVencimiento!.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: spColorSuccess500.withOpacity(
                              0.1), // Siempre verde para consolidado
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: spColorSuccess500.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: spColorSuccess500,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Vencimiento',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Get.isDarkMode
                                          ? spColorGrey400
                                          : spColorGrey600,
                                    ),
                                  ),
                                  Text(
                                    producto.fechaVencimientoFormateada,
                                    style: TextStyle(
                                      fontSize: 12,
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

                    // Información de totales y pendientes (más compacta)
                    Row(
                      children: [
                        // Total (menos destacado)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: spColorGrey500.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: spColorGrey500.withOpacity(0.2)),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: spColorGrey600,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '${producto.totalGeneral.toStringAsFixed(3)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: spColorGrey700,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Pendientes (MÁS DESTACADO pero más compacto)
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: spWarning500.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: spWarning500.withOpacity(0.4),
                                  width: 2),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.pending_actions,
                                      size: 14,
                                      color: spWarning500,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      'PENDIENTES',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: spWarning500,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${producto.totalpendiente.toStringAsFixed(3)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: spWarning500,
                                  ),
                                ),
                                Text(
                                  '${producto.unidadesPendientes} Unidades | ${producto.cajasPendientes.toStringAsFixed(0)} cajas',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: spWarning500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Formulario de entrada
                    Row(
                      children: [
                        // Campo Cajas
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cajas',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Get.isDarkMode
                                      ? spColorGrey400
                                      : spColorGrey700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Material(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Get.isDarkMode
                                          ? spColorGrey600
                                          : spColorGrey300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextField(
                                    controller: cajasController,
                                    keyboardType: TextInputType.none,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                        color: Get.isDarkMode
                                            ? spColorGrey500
                                            : spColorGrey400,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Campo Unidades
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Unidades',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Get.isDarkMode
                                      ? spColorGrey400
                                      : spColorGrey700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Material(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Get.isDarkMode
                                          ? spColorGrey600
                                          : spColorGrey300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextField(
                                    controller: unidadesController,
                                    keyboardType: TextInputType.none,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                        color: Get.isDarkMode
                                            ? spColorGrey500
                                            : spColorGrey400,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Botones de acción
                    Row(
                      children: [
                        // Botón Cancelar
                        Expanded(
                          child: TextButton(
                            onPressed: cerrarModal,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Get.isDarkMode
                                      ? spColorGrey600
                                      : spColorGrey300,
                                ),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 14,
                                color: Get.isDarkMode
                                    ? spColorGrey400
                                    : spColorGrey700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Botón Procesar
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: procesarYCerrarModal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: spColorPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Procesar (ENT)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Método para procesar producto
  Future<void> procesarProducto(ConsolidadoProductoDetalle producto,
      {int cajas = 0, int unidades = 0}) async {
    try {
      if (idConsolidado == null) {
        _showErrorMessage('No se encontró ID de consolidado válido');
        return;
      }

      if (cajas <= 0 && unidades <= 0) {
        _showWarningMessage('Debe ingresar al menos una caja o unidad');
        return;
      }

      _showInfoMessage('Procesando producto...');

      // Calcular cantidad total
      final cantidadCajaUnidad =
          (producto.factor > 0) ? cajas * producto.factor : 0;
      final cantidadTotal = cantidadCajaUnidad + unidades;

      if (cantidadTotal > producto.cantidadDisponible) {
        _showErrorMessage('La cantidad supera la disponible');
        return;
      }

      final response = await _routeService.procesarProductoConsolidado(
        idConsolidado: idConsolidado!,
        idProducto: producto.itemId,
        codigoBarra: producto.loteSeguro,
        cantidadProcesada: cantidadTotal,
        observaciones: 'Procesado: $cajas cajas, $unidades unidades',
      );

      if (response.isSuccess) {
        _showSuccessMessage(
            'Procesado exitosamente: $cajas cajas, $unidades unidades');
        await loadConsolidadoDetalle();
      } else {
        _showErrorMessage(response.message.isNotEmpty
            ? response.message
            : 'Error al procesar producto');
      }
    } catch (e) {
      _showErrorMessage('Error inesperado: ${e.toString()}');
    } finally {
      isProcessingModal.value = false;
    }
  }

  /// Limpiar datos al cerrar
  @override
  void onClose() {
    scrollController.dispose();
    allProductos.clear();
    productos.clear();
    filteredProductos.clear();
    super.onClose();
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

  void _showWarningMessage(String message) {
    Get.snackbar(
      '⚠️ Advertencia',
      message,
      backgroundColor: spWarning500,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
}
