import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sabipay/app/controller/sp_cards_controller.dart';
import 'package:sabipay/app/model/sp_carga_camion_detalle.dart';
import 'package:sabipay/app/model/sp_carga_camion.dart';
import 'package:sabipay/app/model/sp_despacho_detalle.dart';
import 'package:sabipay/route/my_route.dart';
import 'package:sabipay/services/route_service.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:intl/intl.dart';
import 'package:sabipay/services/api_despacho.dart';

class SPCargaCamionDetalleController extends GetxController {
  final RouteService _routeService = RouteService.instance;
  final DespachoService _despachoService = DespachoService.instance;
  // Parámetros básicos
  String? idRuta;
  final isProcessing = false.obs;
  // Estado de carga
  final isLoading = false.obs;

  final RxBool isModalOpen = false.obs;
  final RxBool isProcessingModal = false.obs;
  final RxBool isFinalizingModalOpen = false.obs;

  // Datos principales
  final despacho = Rxn<DetalleResponseRuta>();
  final productos = <ProductoDetalleRuta>[].obs;
  final filteredProductos = <ProductoDetalleRuta>[].obs;

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

  void _updateStatistics() {
    if (productos.isEmpty) {
      productosCompletados.value = 0;
      productosPendientes.value = 0;
      productosEnProceso.value = 0;
      progresoGeneral.value = 0.0;
      return;
    }

    productosCompletados.value =
        productos.where((p) => p.estaCompletado).length;
    productosPendientes.value = productos.where((p) => p.estaPendiente).length;
    productosEnProceso.value = productos.where((p) => p.estaEnProceso).length;

    final total = productos.length;
    progresoGeneral.value =
        total > 0 ? (productosCompletados.value / total) * 100 : 0.0;
  }

  @override
  void onInit() {
    super.onInit();
    idRuta = Get.arguments as String?;

    if (idRuta != null && idRuta!.isNotEmpty) {
      loadDespachoDetalle();
    } else {
      _showErrorMessage('No se proporcionó ID de ruta válido');
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

  /// 🆕 Navegar a pantalla de finalizar despacho
  void navegarAFinalizarDespacho() {
    if (despacho.value == null) {
      _showErrorMessage('No se encontró información del despacho');
      return;
    }

    final pendientes = productos.where((p) => p.estaPendiente).toList();
    final enProceso = productos.where((p) => p.estaEnProceso).toList();
    final productosIncompletos = [...pendientes, ...enProceso];

    if (productosIncompletos.isNotEmpty) {
      // Mostrar modal de confirmación con detalles de productos pendientes
      _showPendingProductsModal(productosIncompletos);
    } else {
      // No hay productos pendientes, proceder directamente
      _showFinalizeConfirmationModal();
    }
  }

  /// Modal para mostrar productos pendientes
  void _showPendingProductsModal(List<SPProductoDetalle> productosIncompletos) {
    isFinalizingModalOpen.value = true;
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: spWarning500, size: 24),
            const SizedBox(width: 8),
            const Text('Pendientes'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hay ${productosIncompletos.length} productos que no han sido completados:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  children: productosIncompletos.map((producto) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: getProductStatusColor(producto.estadoProducto)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: getProductStatusColor(producto.estadoProducto)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            producto.nombreSeguro,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: getProductStatusColor(
                                          producto.estadoProducto)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  producto.estadoDescripcion,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: getProductStatusColor(
                                        producto.estadoProducto),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${producto.unidadesProcesadas ?? 0}/${producto.unidadesRuta ?? 0}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: spColorTeal600.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: spColorTeal600.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: spColorTeal600),
                      const SizedBox(width: 8),
                      const Text(
                        'Especificar el motivo:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Para finalizar con productos pendientes, es obligatorio agregar un comentario explicando el motivo.',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Get.isDarkMode ? Colors.white : spColorGrey700,
            ), // ← Color adaptativo para modo claro/oscuro
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              showFinalizeWithCommentModal(productosIncompletos);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: spWarning500,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    ).then((_) {
      isFinalizingModalOpen.value = false;
    });
  }

  void showFinalizeWithCommentModal(
      List<SPProductoDetalle> productosIncompletos) {
    // Marcar modal como abierto
    isModalOpen.value = true;

    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      builder: (context) =>
          _buildFinalizeWithCommentDialog(context, productosIncompletos),
    ).whenComplete(() {
      // Marcar modal como cerrado cuando se complete
      isModalOpen.value = false;
    });
  }

  Widget _buildFinalizeWithCommentDialog(
      BuildContext context, List<SPProductoDetalle> productosIncompletos) {
    final TextEditingController comentarioController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    // Función para finalizar
    void finalizarYCerrarModal() async {
      if (formKey.currentState!.validate()) {
        // Cerrar modal ANTES de finalizar
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Esperar a que el modal se cierre completamente
        await Future.delayed(const Duration(milliseconds: 300));

        // Finalizar despacho
        _finalizarDespacho(comentarioController.text.trim());
      }
    }

    // Función para cerrar modal sin finalizar
    void cerrarModal() {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }

    return Dialog(
      // 🆕 Posicionar el dialog en la parte superior
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(
        top: 0, // Margen desde arriba
        left: 0,
        right: 0,
        bottom: 0, // Espacio para el teclado
      ),
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? spCardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header compacto
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: spColorError500.withAlpha(26),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit_note, color: spColorError500, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Finalizar Despacho',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: spColorError500.withAlpha(52),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Pendientes: ${productosIncompletos.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: spColorError500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: cerrarModal,
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido principal
              Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Información de productos pendientes
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: spColorError500.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: spColorError500.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_outlined,
                              size: 18,
                              color: spColorError500,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Comentario obligatorio para productos pendientes',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: spColorError500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Campo de comentario
                      Material(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Get.isDarkMode
                                  ? spColorGrey600
                                  : spColorGrey300,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextFormField(
                            controller: comentarioController,
                            // 🆕 Permitir teclado normal
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            minLines: 3,
                            autofocus: true, // 🆕 Enfocar automáticamente
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Explica el motivo por el cual hay productos pendientes...',
                              hintStyle: TextStyle(
                                color: Get.isDarkMode
                                    ? spColorGrey500
                                    : spColorGrey400,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El comentario es obligatorio';
                              }
                              if (value.trim().length < 10) {
                                return 'El comentario debe tener al menos 10 caracteres';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Botones de acción
                      Row(
                        children: [
                          // Botón Cancelar
                          Expanded(
                            child: TextButton(
                              onPressed: cerrarModal,
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
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
                                  fontWeight: FontWeight.w600,
                                  color: Get.isDarkMode
                                      ? spColorGrey400
                                      : spColorGrey700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Botón Finalizar
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: finalizarYCerrarModal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: spColorError500,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Finalizar',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Modal de confirmación simple para despachos sin pendientes
  void _showFinalizeConfirmationModal() {
    final TextEditingController comentarioController = TextEditingController();

    // 🎯 Marcar que el modal de finalizar está abierto
    isFinalizingModalOpen.value = true;

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: spColorSuccess500, size: 24),
            const SizedBox(width: 8),
            const Text('Finalizar Despacho'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            const Text(
              'Comentario opcional:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            TextField(
              controller: comentarioController,
              decoration: const InputDecoration(
                hintText: 'Agrega un comentario si lo deseas...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _finalizarDespacho(comentarioController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: spColorSuccess500,
              foregroundColor: Colors.white,
            ),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    ).then((_) {
      // 🎯 Marcar modal como cerrado cuando se complete
      isFinalizingModalOpen.value = false;
    });
  }

  /// Método para finalizar despacho usando la API correcta
  Future<void> _finalizarDespacho(String comentario) async {
    if (despacho.value?.id == null) {
      _showErrorMessage('No se encontró sesión válida para finalizar');
      return;
    }

    try {
      isProcessing.value = true;
      _showInfoMessage('Finalizando despacho...');

      // Usar la API correcta de DespachoService
      final response = await _despachoService.finalizarSesion(
        idSesion: despacho.value!.id!,
        observacionesGenerales: comentario.isNotEmpty ? comentario : null,
      );

      if (response.isSuccess) {
        _showSuccessMessage('Despacho finalizado exitosamente');
        // pendiente proceder
      } else {
        _showErrorMessage(response.message.isNotEmpty
            ? response.message
            : 'Error al finalizar despacho');
      }
    } catch (e) {
      print('❌ Error al finalizar despacho: $e');
      _showErrorMessage('Error inesperado: ${e.toString()}');
    } finally {
      isProcessing.value = false;
    }
  }

  /// Verificar si un producto puede ser procesado
  bool puedeSerProcesado(ProductoDetalleRuta producto) {
    return !producto.estaCompletado;
  }

  /// Buscar producto por código de barras
  ProductoDetalleRuta? _findProductByBarcode(String barcode) {
    if (productos.isEmpty || barcode.isEmpty) return null;

    // Normalizar el código escaneado
    final normalizedScanned = barcode.trim().toLowerCase();

    // Buscar coincidencia exacta
    SPProductoDetalle? producto = productos.firstWhereOrNull(
        (p) => p.codigoBarra?.trim().toLowerCase() == normalizedScanned);

    // Si no encuentra coincidencia exacta, buscar por otros campos
    if (producto == null) {
      producto = productos.firstWhereOrNull((p) =>
          p.codigoSeguro.toLowerCase().contains(normalizedScanned) ||
          p.itemSeguro.toLowerCase().contains(normalizedScanned) ||
          p.loteSeguro.toLowerCase().contains(normalizedScanned));
    }
    return producto;
  }

  /// Cargar detalles del despacho
  Future<void> loadDespachoDetalle() async {
    if (idRuta == null || idRuta!.isEmpty) {
      _showErrorMessage('ID de ruta no válido');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _routeService.getSessionDespachoUnica(
        idRuta: idRuta!,
      );

      if (response.isSuccess && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final despachoResponse =
              SPDespachoDetalleResponse.fromJson(response.data!);

          if (despachoResponse.success && despachoResponse.data.isNotEmpty) {
            final primeraSession = despachoResponse.data.first;
            despacho.value = primeraSession;

            if (primeraSession.productos.isNotEmpty) {
              final productosOrdenados = sortProductosPersonalizado(
                primeraSession.productos,
                getItemId: (producto) => producto.itemSeguro,
                getUnidades: (producto) => producto.unidadesRuta ?? 0,
              );
              productos.value = productosOrdenados;
              _updateStatistics();
              _applyFilters();
            } else {
              productos.clear();
              filteredProductos.clear();
              _showInfoMessage('No se encontraron productos en este despacho');
            }
          } else {
            _showErrorMessage(despachoResponse.message.isNotEmpty
                ? despachoResponse.message
                : 'No se encontraron datos de despacho');
          }
        } else {
          _showErrorMessage('Formato de respuesta inesperado del servidor');
        }
      } else {
        _showErrorMessage(response.message);
      }
    } catch (e) {
      _showErrorMessage('Error al cargar despacho: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Cambiar filtro con actualización de UI
  void changeFilter(int index) {
    if (selectedFilterIndex.value != index) {
      selectedFilterIndex.value = index;
      _applyFilters();
      update(); // Forzar actualización de UI
    }
  }

  /// Buscar productos
  void searchProductos(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  /// Aplicar filtros y búsqueda
  void _applyFilters() {
    if (productos.isEmpty) {
      filteredProductos.clear();
      return;
    }

    var filtered = List<SPProductoDetalle>.from(productos);
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
      default: // Todos (caso 0)
        // No filtramos, mostramos todos
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
        final codigoBarra = producto.codigoBarra?.toLowerCase() ?? '';

        return nombre.contains(query) ||
            codigo.contains(query) ||
            itemId.contains(query) ||
            lote.contains(query) ||
            codigoBarra.contains(query);
      }).toList();
    }

    filtered = sortProductosPersonalizado(
      filtered,
      getItemId: (producto) => producto.itemSeguro,
      getUnidades: (producto) => producto.unidadesRuta ?? 0,
    );

    filteredProductos.value = filtered;
    update(); // Forzar actualización de la UI
  }

  /// Refrescar datos
  Future<void> refreshData() async {
    _showInfoMessage('Actualizando datos...');
    await loadDespachoDetalle();
  }

  /// Obtener color del estado del producto
  Color getProductStatusColor(String? estado) {
    switch (estado?.toUpperCase()) {
      case 'COMPLETO':
      case 'COMPLETADO':
        return spColorSuccess500;
      case 'EN_PROCESO':
      case 'PROCESANDO':
        return spColorTeal600;
      case 'PENDIENTE':
        return spWarning500;
      default:
        return spColorGrey400;
    }
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

  /// Buscar producto por código manual y abrir modal
  void buscarYAbrirProducto(BuildContext context, String codigoBarra) {
    final producto = _findProductByBarcode(codigoBarra);

    if (producto != null) {
      openProcessModal(context, producto);
    } else {
      _showWarningMessage('Producto no encontrado para código: $codigoBarra');
    }
  }

  void openProcessModal(BuildContext context, SPProductoDetalle producto) {
    // Marcar modal como abierto
    isModalOpen.value = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => _buildProcessModal(context, producto),
    ).whenComplete(() {
      // Marcar modal como cerrado cuando se complete
      isModalOpen.value = false;
      isProcessingModal.value = false;
    });
  }

  /// Modal para visualizar los datos del producto escaneado
  Widget _buildProcessModal(BuildContext context, SPProductoDetalle producto) {
    final TextEditingController cajasController = TextEditingController();
    final TextEditingController unidadesController = TextEditingController();

    // Función mejorada para procesar y cerrar modal
    void procesarYCerrarModal() async {
      // Evitar múltiples ejecuciones
      if (isProcessingModal.value) return;

      final cajas = int.tryParse(cajasController.text) ?? 0;
      final unidades = int.tryParse(unidadesController.text) ?? 0;

      // Validación básica local
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

      // Marcar como procesando
      isProcessingModal.value = true;

      // Cerrar modal ANTES de procesar
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Esperar a que el modal se cierre completamente
      await Future.delayed(const Duration(milliseconds: 300));

      // Procesar producto
      await procesarProducto(producto, cajas: cajas, unidades: unidades);
    }

    // Función para cerrar modal sin procesar
    void cerrarModal() {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        // Permitir cerrar con gesto o botón atrás
        isModalOpen.value = false;
      },
      child: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKeyEvent: (KeyEvent event) {
          // Manejar Enter para procesar
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            procesarYCerrarModal();
          }
          // Manejar Escape para cerrar
          else if (event is KeyDownEvent &&
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
                            '${producto.unidadesProcesadas ?? 0} Procesadas',
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

              // Información del producto
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Fecha de vencimiento (más compacta)
                    if (producto.tieneVencimientoValido)
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(8), // ✅ REDUCIDO de 10 a 8
                        margin: const EdgeInsets.only(
                            bottom: 8), // ✅ REDUCIDO de 12 a 8
                        decoration: BoxDecoration(
                          color: producto.estaVencido
                              ? spColorError500.withOpacity(0.1)
                              : producto.tieneVencimientoProximo
                                  ? spWarning500.withOpacity(0.1)
                                  : spColorSuccess500.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(6), // ✅ REDUCIDO de 8 a 6
                          border: Border.all(
                            color: producto.estaVencido
                                ? spColorError500.withOpacity(0.3)
                                : producto.tieneVencimientoProximo
                                    ? spWarning500.withOpacity(0.3)
                                    : spColorSuccess500.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              producto.estaVencido
                                  ? Icons.warning
                                  : producto.tieneVencimientoProximo
                                      ? Icons.schedule
                                      : Icons.check_circle,
                              color: producto.estaVencido
                                  ? spColorError500
                                  : producto.tieneVencimientoProximo
                                      ? spWarning500
                                      : spColorSuccess500,
                              size: 16, // ✅ REDUCIDO de 18 a 16
                            ),
                            const SizedBox(width: 6), // ✅ REDUCIDO de 8 a 6
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Vencimiento', // ✅ TEXTO MÁS CORTO
                                    style: TextStyle(
                                      fontSize: 10, // ✅ REDUCIDO de 11 a 10
                                      fontWeight: FontWeight.w500,
                                      color: Get.isDarkMode
                                          ? spColorGrey400
                                          : spColorGrey600,
                                    ),
                                  ),
                                  Text(
                                    producto.vencimientoSeguro,
                                    style: TextStyle(
                                      fontSize: 12, // ✅ REDUCIDO de 14 a 12
                                      fontWeight: FontWeight.w600,
                                      color: producto.estaVencido
                                          ? spColorError500
                                          : producto.tieneVencimientoProximo
                                              ? spWarning500
                                              : spColorSuccess500,
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
                        // Pendientes (MÁS DESTACADO pero más compacto)
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding:
                                const EdgeInsets.all(8), // ✅ REDUCIDO de 12 a 8
                            decoration: BoxDecoration(
                              color: spWarning500.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(
                                  6), // ✅ REDUCIDO de 8 a 6
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
                                      size: 14, // ✅ REDUCIDO de 16 a 14
                                      color: spWarning500,
                                    ),
                                    const SizedBox(
                                        width: 3), // ✅ REDUCIDO de 4 a 3
                                    Text(
                                      'PROCESADAS',
                                      style: TextStyle(
                                        fontSize: 10, // ✅ REDUCIDO de 11 a 10
                                        fontWeight: FontWeight.w700,
                                        color: spWarning500,
                                        letterSpacing:
                                            0.3, // ✅ REDUCIDO de 0.5 a 0.3
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                    height: 2), // ✅ REDUCIDO de 4 a 2
                                Text(
                                  '${producto.toStringAsFixed(3)}',
                                  style: TextStyle(
                                    fontSize: 16, // ✅ REDUCIDO de 18 a 16
                                    fontWeight: FontWeight.w900,
                                    color: spWarning500,
                                  ),
                                ),
                                Text(
                                  '${producto.unidadesProcesadas} Unidades | ${producto.cajasProcesadas} cajas',
                                  style: TextStyle(
                                    fontSize: 10, // ✅ REDUCIDO de 11 a 10
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

                    const SizedBox(height: 12), // ✅ REDUCIDO de 16 a 12

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
  Future<void> procesarProducto(SPProductoDetalle producto,
      {int cajas = 0, int unidades = 0}) async {
    try {
      if (despacho.value?.id == null) {
        _showErrorMessage('No se encontró ID de sesión válido');
        return;
      }
      if (cajas <= 0 && unidades <= 0) {
        _showWarningMessage('Debe ingresar al menos una caja o unidad');
        return;
      }
      // Mostrar indicador de carga
      _showInfoMessage('Procesando producto...');

      // Preparar datos para la API
      final cantidadCajaUnidad = (producto.factor ?? 0) * cajas;
      final cantidadTotal = cantidadCajaUnidad + unidades;
      final disponibles =
          (producto.unidadesRuta ?? 0) - (producto.unidadesProcesadas ?? 0);

      if (cantidadTotal > disponibles) {
        _showErrorMessage(
            'La cantidad ingresada supera la cantidad disponible.');
        return;
      }

      String? itemId = (producto.itemId ?? '').trim();
      if (itemId.isEmpty) {
        itemId = (producto.itemId ?? '').trim();
      }

      if (itemId.isEmpty) {
        _showErrorMessage(
            'El producto no tiene un código válido para procesar');
        return;
      }

      String? lote = (producto.lote ?? '').trim();
      if (lote.isEmpty) {
        lote = (producto.itemId ?? '').trim();
      }

      if (lote.isEmpty) {
        _showErrorMessage(
            'El producto no tiene un código válido para procesar');
        return;
      }
      // Llamar a la API - ella se encarga de todas las validaciones
      final response = await _routeService.procesarEscaneoProducto(
        idSesion: despacho.value!.id!,
        itemId: itemId,
        lote: lote,
        cantidadCargada: cantidadTotal,
        observaciones: 'Procesado: $cajas cajas, $unidades unidades',
      );

      if (response.isSuccess) {
        // ✅ ÉXITO - Mostrar mensaje de éxito
        _showSuccessMessage(
            'Procesado exitosamente: $cajas cajas, $unidades unidades');

        await loadDespachoDetalle();
      } else {
        // ❌ ERROR - La API nos dice qué está mal
        String mensajeError = response.message.isNotEmpty
            ? response.message
            : 'Error al procesar producto';
        _showErrorMessage(mensajeError);
      }
    } catch (e) {
      print('❌ Error inesperado procesando producto: $e');
      _showErrorMessage('Error inesperado: ${e.toString()}');
    }
  }

  /// Limpiar datos al cerrar
  @override
  void onClose() {
    // Limpiar datos
    productos.clear();
    filteredProductos.clear();
    despacho.value = null;

    super.onClose();
  }
}
