// lib/app/controller/sp_carga_camion_detalle_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sabipay/app/model/sp_carga_camion_detalle.dart';
import 'package:sabipay/services/route_service.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:intl/intl.dart';

class SPCargaCamionDetalleController extends GetxController {
  final RouteService _routeService = RouteService.instance;

  // Parámetros básicos
  int? idCarga;
  final isLoading = false.obs;
  final isProcessing = false.obs;
  final isModalOpen = false.obs;
  final isProcessingModal = false.obs;

  // Datos principales
  final carga = Rxn<CargaCamionDetalle>();
  final productos = <ProductoCargaCamion>[].obs;
  final filteredProductos = <ProductoCargaCamion>[].obs;

  // Filtros y búsqueda
  final selectedFilterIndex = 1.obs;
  final searchQuery = ''.obs;
  final List<String> filterOptions = [
    'Todos',
    'Pendientes',
    'Procesados',
    'Validados'
  ];

  // Estadísticas
  final productosValidados = 0.obs;
  final productosPendientes = 0.obs;
  final productosConValidacion = 0.obs;
  final progresoGeneral = 0.0.obs;

  // Controladores para el modal
  final cajasController = TextEditingController();
  final unidadesController = TextEditingController();
  final observacionesController = TextEditingController();
  final selectedProducto = Rxn<ProductoCargaCamion>();

  @override
  void onInit() {
    super.onInit();
    idCarga = Get.arguments as int?;

    if (idCarga != null) {
      loadCargaDetalle();
    } else {
      _showErrorMessage('No se proporcionó ID de carga válido');
    }

    // Escuchar cambios en búsqueda y filtros
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedFilterIndex, (_) => _applyFilters());
  }

  @override
  void onClose() {
    cajasController.dispose();
    unidadesController.dispose();
    observacionesController.dispose();
    super.onClose();
  }

  /// Cargar detalle de la carga
  Future<void> loadCargaDetalle() async {
    try {
      isLoading.value = true;

      // TODO: Cambiar por la API específica de carga de camión detalle
      // Por ahora simulamos datos
      await Future.delayed(const Duration(seconds: 1));

      // Datos simulados
      final productosSimulados = [
        ProductoCargaCamion(
          itemId: "PROD001",
          descripcion: "Producto de prueba 1",
          codigoBarra: "123456789",
          lote: "L001",
        ),
        ProductoCargaCamion(
          itemId: "PROD002",
          descripcion: "Producto de prueba 2",
          codigoBarra: "987654321",
          lote: "L002",
          validadoFisicamente: true,
          cajasValidadas: 5.0,
          unidadesValidadas: 50,
          fechaValidacion: DateTime.now(),
        ),
        ProductoCargaCamion(
          itemId: "PROD003",
          descripcion: "Producto de prueba 3",
          codigoBarra: "456789123",
          lote: "L003",
          cajasValidadas: 2.0,
          unidadesValidadas: 20,
        ),
      ];

      carga.value = CargaCamionDetalle(
        id: idCarga,
        idRuta: "0000057681",
        codigoUser: "4259",
        fechaInicio: DateTime.now(),
        productos: productosSimulados,
      );

      productos.value = productosSimulados;
      _applyFilters();
      _updateStatistics();
    } catch (e) {
      print('❌ Error al cargar detalle de carga: $e');
      _showErrorMessage('Error al cargar detalle de carga');
    } finally {
      isLoading.value = false;
    }
  }

  /// Aplicar filtros y búsqueda
  void _applyFilters() {
    List<ProductoCargaCamion> filtered = List.from(productos);

    // Aplicar filtro por estado
    switch (selectedFilterIndex.value) {
      case 1: // Pendientes
        filtered = filtered.where((p) => p.estaPendiente).toList();
        break;
      case 2: // Procesados
        filtered = filtered
            .where((p) => p.tieneValidacion && !p.estaValidado)
            .toList();
        break;
      case 3: // Validados
        filtered = filtered.where((p) => p.estaValidado).toList();
        break;
      case 0: // Todos
      default:
        break;
    }

    // Aplicar búsqueda por texto
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((producto) {
        return (producto.itemId?.toLowerCase().contains(query) ?? false) ||
            (producto.descripcion?.toLowerCase().contains(query) ?? false) ||
            (producto.codigoBarra?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Ordenar: pendientes primero
    filtered.sort((a, b) {
      if (a.estaPendiente && !b.estaPendiente) return -1;
      if (!a.estaPendiente && b.estaPendiente) return 1;
      return (a.itemId ?? '').compareTo(b.itemId ?? '');
    });

    filteredProductos.value = filtered;
  }

  /// Actualizar estadísticas
  void _updateStatistics() {
    if (productos.isEmpty) {
      productosValidados.value = 0;
      productosPendientes.value = 0;
      productosConValidacion.value = 0;
      progresoGeneral.value = 0.0;
      return;
    }

    productosValidados.value = productos.where((p) => p.estaValidado).length;
    productosPendientes.value = productos.where((p) => p.estaPendiente).length;
    productosConValidacion.value =
        productos.where((p) => p.tieneValidacion && !p.estaValidado).length;

    final total = productos.length;
    progresoGeneral.value =
        total > 0 ? (productosValidados.value / total) * 100 : 0.0;
  }

  /// Cambiar filtro
  void changeFilter(int index) {
    selectedFilterIndex.value = index;
  }

  /// Actualizar búsqueda
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  /// Abrir modal para validar producto
  void abrirModalValidacion(ProductoCargaCamion producto) {
    selectedProducto.value = producto;

    // Limpiar campos
    cajasController.clear();
    unidadesController.clear();
    observacionesController.clear();

    // Pre-llenar con valores existentes si los hay
    if (producto.cajasValidadas != null) {
      cajasController.text = producto.cajasValidadas!.toString();
    }
    if (producto.unidadesValidadas != null) {
      unidadesController.text = producto.unidadesValidadas!.toString();
    }
    if (producto.observaciones != null) {
      observacionesController.text = producto.observaciones!;
    }

    isModalOpen.value = true;
  }

  /// Validar producto
  Future<void> validarProducto() async {
    if (selectedProducto.value == null) return;

    final producto = selectedProducto.value!;
    final cajas = double.tryParse(cajasController.text) ?? 0;
    final unidades = int.tryParse(unidadesController.text) ?? 0;

    if (cajas <= 0 && unidades <= 0) {
      _showErrorMessage('Debe ingresar al menos cajas o unidades');
      return;
    }

    try {
      isProcessingModal.value = true;

      // TODO: Implementar API para guardar validación
      await Future.delayed(const Duration(seconds: 1));

      // Actualizar producto localmente
      final index = productos.indexWhere((p) => p.itemId == producto.itemId);
      if (index != -1) {
        productos[index] = producto.copyWith(
          cajasValidadas: cajas > 0 ? cajas : null,
          unidadesValidadas: unidades > 0 ? unidades : null,
          validadoFisicamente: true,
          fechaValidacion: DateTime.now(),
          usuarioValidacion: 'Usuario Actual',
          observaciones: observacionesController.text.isNotEmpty
              ? observacionesController.text
              : null,
        );
      }

      _applyFilters();
      _updateStatistics();
      isModalOpen.value = false;
      _showSuccessMessage('Producto validado correctamente');

      // Limpiar campos
      cajasController.clear();
      unidadesController.clear();
      observacionesController.clear();
    } catch (e) {
      print('❌ Error al validar producto: $e');
      _showErrorMessage('Error al validar producto');
    } finally {
      isProcessingModal.value = false;
    }
  }

  /// Buscar producto por código
  void buscarProductoPorCodigo(String codigo) {
    if (codigo.isEmpty) return;

    final producto = productos.firstWhereOrNull((p) =>
        p.codigoBarra?.toLowerCase() == codigo.toLowerCase() ||
        p.itemId?.toLowerCase() == codigo.toLowerCase());

    if (producto != null) {
      abrirModalValidacion(producto);
    } else {
      _showErrorMessage('Producto no encontrado');
    }
  }

  /// Finalizar carga
  Future<void> finalizarCarga() async {
    final pendientes = productos.where((p) => !p.estaValidado).length;

    if (pendientes > 0) {
      final confirmar = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Confirmar Finalización'),
              content: Text(
                  'Quedan $pendientes productos sin validar.\n¿Finalizar la carga?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: spWarning500),
                  child: const Text('Finalizar'),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirmar) return;
    }

    try {
      isProcessing.value = true;

      // TODO: API para finalizar carga
      await Future.delayed(const Duration(seconds: 2));

      _showSuccessMessage('Carga finalizada exitosamente');
      Get.back();
    } catch (e) {
      print('❌ Error al finalizar carga: $e');
      _showErrorMessage('Error al finalizar carga');
    } finally {
      isProcessing.value = false;
    }
  }

  /// Refrescar datos
  Future<void> refreshData() async {
    await loadCargaDetalle();
  }

  /// Obtener color del estado
  Color getProductStatusColor(ProductoCargaCamion producto) {
    if (producto.estaValidado) {
      return spColorSuccess500;
    } else if (producto.tieneValidacion) {
      return spColorTeal600;
    } else {
      return spWarning500;
    }
  }

  /// Obtener icono del estado
  IconData getProductStatusIcon(ProductoCargaCamion producto) {
    if (producto.estaValidado) {
      return Icons.check_circle;
    } else if (producto.tieneValidacion) {
      return Icons.edit_note;
    } else {
      return Icons.pending;
    }
  }

  /// Formatear fecha
  String formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
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

  /// Mostrar mensaje de éxito
  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Éxito',
      message,
      backgroundColor: spColorSuccess500,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
}
