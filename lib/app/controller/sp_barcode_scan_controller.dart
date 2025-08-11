import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:sabipay/app/model/sp_despacho.dart';
import 'package:sabipay/services/route_service.dart';
import 'package:sabipay/services/scan_services.dart';
import 'package:sabipay/constant/sp_colors.dart';

class SPBarcodeScanController extends GetxController {
  final RouteService _routeService = RouteService.instance;
  final BarcodeScannerService _scannerService = BarcodeScannerService.instance;

  // Estados reactivos
  final isLoading = false.obs;
  final scannedCode = ''.obs;
  final routeInfo = Rxn<RouteInfo>();
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final despachosList = <SesionDespacho>[].obs;
  final selectedDespacho = Rxn<SesionDespacho>();

  // Controladores
  final TextEditingController testCodeController = TextEditingController();
  final TextEditingController visibleInputController = TextEditingController();
  final FocusNode visibleInputFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();

    // Limpiar campos
    testCodeController.clear();
    visibleInputController.clear();

    // Configurar scanner
    _configureScannerService();

    // Escuchar códigos escaneados
    _scannerService.scannedCodeStream.listen(_onCodeScanned);

    // Setup del campo visible
    _setupVisibleInput();
  }

  // Configuración específica para códigos de 10 dígitos
  void _configureScannerService() {
    final config = BarcodeScannerConfig(
      minCodeLength: 10,
      maxCodeLength: 10,
      maxSingleCodeLength: 15,
      allowedCharactersPattern: r'^\d{10}$',
    );
    _scannerService.configure(config);
  }

  // Setup del campo visible
  void _setupVisibleInput() {
    // Auto-focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _ensureFocus();
      });
    });

    // Re-enfocar cuando se pierde el focus
    visibleInputFocusNode.addListener(() {
      if (!visibleInputFocusNode.hasFocus &&
          !isLoading.value &&
          routeInfo.value == null) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (!isLoading.value && routeInfo.value == null) {
            _ensureFocus();
          }
        });
      }
    });

    visibleInputController.addListener(_handleInputChange);
  }

  void _handleInputChange() {
    final currentText = visibleInputController.text;
    if (currentText.length == 10 && RegExp(r'^\d{10}$').hasMatch(currentText)) {
      _processCode(currentText);
    }
  }

  // 🎯 PROCESAR código de 10 dígitos
  void _processCode(String code) {
    // Limpiar campo y procesar
    visibleInputController.clear();
    processScannedCode(code);
  }

  // Callback del scanner service
  void _onCodeScanned(String code) {
    // Limpiar y extraer solo números
    String cleanCode = code.trim().replaceAll(RegExp(r'[^\d]'), '');
    // 🎯 SIMPLE: Si tiene exactamente 10 dígitos, usarlo
    if (cleanCode.length == 10) {
      visibleInputController.text = cleanCode;
    }
  }

  // Procesamiento manual del campo
  void processVisibleInput(String value) {
    String cleanValue = value.trim().replaceAll(RegExp(r'[^\d]'), '');
    // 🎯 SIMPLE: Solo aceptar exactamente 10 dígitos
    if (cleanValue.length == 10) {
      visibleInputController.text = cleanValue;
    }
  }

  // Simulación para testing
  Future<void> simulateScan() async {
    final code = testCodeController.text.trim();
    if (code.isNotEmpty) {
      String cleanCode = code.replaceAll(RegExp(r'[^\d]'), '');
      if (cleanCode.length == 10) {
        visibleInputController.text = cleanCode;
      }
    } else {
      _showErrorMessage('Ingresa un código para simular');
    }
  }

  // Asegurar focus
  void _ensureFocus() {
    if (!visibleInputFocusNode.hasFocus &&
        !isLoading.value &&
        routeInfo.value == null) {
      try {
        visibleInputFocusNode.requestFocus();
        print('🎯 Focus asignado');
      } catch (e) {
        print('❌ Error asignando focus: $e');
      }
    }
  }

  // Limpiar campo visible
  void clearVisibleInput() {
    visibleInputController.clear();
    _ensureFocus();
  }

  /// Procesar código escaneado (SIN CAMBIOS)
  Future<void> processScannedCode(String code) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      scannedCode.value = code;
      routeInfo.value = null;
      final response = await _routeService.getRouteDispatch(routeId: code);

      if (response.isSuccess && response.data != null) {
        try {
          final routeSummary = _routeService.getRouteSummary(response.data!);
          routeInfo.value = routeSummary;
          print('✅ Ruta cargada exitosamente: "$code"');
        } catch (processingError) {
          print('❌ Error procesando datos: $processingError');
          hasError.value = true;
          errorMessage.value = 'Error al procesar los datos de la ruta';
          _showErrorMessage('Error al procesar los datos de la ruta');
        }
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
        _showErrorMessage(response.message);
        print('❌ Error API: ${response.message}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error inesperado: $e';
      _showErrorMessage('Error inesperado: $e');
      print('❌ Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Limpiar resultados
  void clearResults() {
    scannedCode.value = '';
    routeInfo.value = null;
    hasError.value = false;
    errorMessage.value = '';
    isLoading.value = false;

    testCodeController.clear();
    visibleInputController.clear();

    _ensureFocus();
  }

  /// Reintentar escaneo
  void retryScan() {
    hasError.value = false;
    errorMessage.value = '';
    isLoading.value = false;
  }

  /// Obtener estadísticas del scanner
  Map<String, dynamic> getScannerStatistics() {
    return _scannerService.getScanStatistics();
  }

  /// Validar formato de código
  bool isValidBarcodeFormat(String code) {
    return code.length == 10 && RegExp(r'^\d{10}$').hasMatch(code);
  }

  /// Mostrar mensaje de error
  void _showErrorMessage(String message) {
    Get.snackbar(
      '❌ Error',
      message,
      backgroundColor: spColorError500,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );
  }

  // RESTO DE MÉTODOS SIN CAMBIOS
  Map<String, List<ProductInfo>> getProductsByWarehouse() {
    if (routeInfo.value == null) return {};
    final Map<String, List<ProductInfo>> grouped = {};
    for (var product in routeInfo.value!.products) {
      final bodega = product.bodega.isNotEmpty ? product.bodega : 'Sin bodega';
      if (!grouped.containsKey(bodega)) {
        grouped[bodega] = [];
      }
      grouped[bodega]!.add(product);
    }
    return grouped;
  }

  List<ProductInfo> getExpiringProducts() {
    if (routeInfo.value == null) return [];
    return routeInfo.value!.products.where((p) => p.isNearExpiry).toList();
  }

  List<ProductInfo> getExpiredProducts() {
    if (routeInfo.value == null) return [];
    return routeInfo.value!.products.where((p) => p.isExpired).toList();
  }

  Map<String, dynamic> getRouteStatistics() {
    if (routeInfo.value == null) return {};
    final route = routeInfo.value!;
    final expired = getExpiredProducts().length;
    final expiring = getExpiringProducts().length;
    final warehouses = getProductsByWarehouse().keys.length;
    return {
      'totalProducts': route.totalItems,
      'totalBoxes': route.totalBoxes,
      'totalKilogramos': route.totalKilogramos,
      'totalToneladas': route.totalToneladas,
      'totalUnidades': route.totalUnidades,
      'expiredProducts': expired,
      'expiringProducts': expiring,
      'warehousesCount': warehouses,
      'hasAlerts': expired > 0 || expiring > 0,
    };
  }

  List<ProductInfo> searchProducts(String query) {
    if (routeInfo.value == null || query.isEmpty) return [];
    final searchQuery = query.toLowerCase();
    return routeInfo.value!.products.where((product) {
      return product.itemName.toLowerCase().contains(searchQuery) ||
          product.itemId.toLowerCase().contains(searchQuery) ||
          product.lote.toLowerCase().contains(searchQuery);
    }).toList();
  }

  List<ProductInfo> getProductsSortedByExpiry() {
    if (routeInfo.value == null) return [];
    final products = List<ProductInfo>.from(routeInfo.value!.products);
    products.sort((a, b) {
      if (a.vencimiento == null && b.vencimiento == null) return 0;
      if (a.vencimiento == null) return 1;
      if (b.vencimiento == null) return -1;
      return a.vencimiento!.compareTo(b.vencimiento!);
    });
    return products;
  }

  @override
  void onClose() {
    testCodeController.dispose();
    visibleInputController.dispose();
    visibleInputFocusNode.dispose();
    super.onClose();
  }
}
