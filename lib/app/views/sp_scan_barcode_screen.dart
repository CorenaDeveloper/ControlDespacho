import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sabipay/app/controller/sp_barcode_scan_controller.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/sabipy_theme/theme_controller.dart';
import 'package:get/get.dart';
import 'package:sabipay/services/route_service.dart';
import 'package:sabipay/services/api_despacho.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:sabipay/route/my_route.dart';
import 'package:sabipay/services/scan_services.dart';

class SPScanBarcodeScreen extends StatefulWidget {
  const SPScanBarcodeScreen({super.key});

  @override
  SPScanBarcodeScreenState createState() => SPScanBarcodeScreenState();
}

class SPScanBarcodeScreenState extends State<SPScanBarcodeScreen> {
  final SPBarcodeScanController controller = Get.put(SPBarcodeScanController());
  final BarcodeScannerService scannerService = BarcodeScannerService.instance;
  late ThemeData theme;
  ThemeController themeController = Get.put(ThemeController());
  final isLoading = false.obs;

  void setLoading(bool loading) {
    isLoading.value = loading;
  }

  @override
  void initState() {
    super.initState();
    theme = themeController.isDarkMode
        ? SPWalletTheme.spDarkTheme
        : SPWalletTheme.spLightTheme;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SPBarcodeScanController>(
      init: controller,
      builder: (controller) {
        return Scaffold(
          backgroundColor:
              themeController.isDarkMode ? spDarkPrimary : spColorLightBg,
          appBar: _buildAppBar(),
          // Prevenir que el teclado aparezca
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: scannerService.createHT330Listener(
              onCodeScanned: (code) {},
              child: Container(
                color:
                    themeController.isDarkMode ? spDarkPrimary : Colors.white,
                child: Column(
                  children: [
                    Obx(() {
                      if (controller.routeInfo.value != null) {
                        return _buildResultsView();
                      } else {
                        return _buildScannerView();
                      }
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 🆕 NUEVO: Widget del campo visible optimizado
  Widget _buildVisibleInputField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: spColorPrimary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: spColorPrimary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título compacto
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: spColorPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  size: 16,
                  color: spColorPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Código de Ruta',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      themeController.isDarkMode ? Colors.white : spTextColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: spColorSuccess500.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Listo',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: spColorSuccess700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Campo de entrada más compacto
          Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(
                color: controller.visibleInputFocusNode.hasFocus
                    ? spColorPrimary
                    : (themeController.isDarkMode
                        ? spColorGrey600
                        : spColorGrey300),
                width: controller.visibleInputFocusNode.hasFocus ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: themeController.isDarkMode
                  ? spColorGrey800.withOpacity(0.3)
                  : spColorGrey50,
            ),
            child: TextField(
              controller: controller.visibleInputController,
              focusNode: controller.visibleInputFocusNode,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: themeController.isDarkMode ? Colors.white : spTextColor,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Escanea aquí o escribe...',
                hintStyle: TextStyle(
                  color: themeController.isDarkMode
                      ? spColorGrey400
                      : spColorGrey500,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              keyboardType: TextInputType.none,
              enableInteractiveSelection: false,
              textInputAction: TextInputAction.search,
              onSubmitted: controller.processVisibleInput,
              onChanged: (value) {
                if (value.length >= 8) {
                  controller.processVisibleInput(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🆕 NUEVO: Campo de entrada visible - ARRIBA
            _buildVisibleInputField(),

            // Área de escaneo visual SIN cuadro
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono principal
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: spColorPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.qr_code_scanner,
                      size: 48,
                      color: spColorPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Línea de escaneo animada
                  Container(
                    width: 120,
                    height: 3,
                    decoration: BoxDecoration(
                      color: spColorPrimary,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: spColorPrimary.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Texto principal
                  Text(
                    'Scanner HT330 Activo',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: themeController.isDarkMode
                          ? Colors.white
                          : spTextColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Presiona el botón azul del lector\no escribe en el campo superior',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: themeController.isDarkMode
                          ? spColorGrey300
                          : spColorGrey600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Indicador de carga compacto
            Obx(() => controller.isLoading.value
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: spColorPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: spColorPrimary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: spColorPrimary,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Procesando código...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: spColorPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    final routeInfo = controller.routeInfo.value!;

    return Expanded(
      child: Column(
        children: [
          // Header con información de ruta
          Container(
            //margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeController.isDarkMode ? spCardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: spColorPrimary900.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 24),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ruta Escaneada',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: themeController.isDarkMode
                              ? spColorGrey300
                              : spColorGrey600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.scannedCode.value}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: themeController.isDarkMode
                              ? Colors.white
                              : spTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    controller.clearResults();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: spColorPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: spColorPrimary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: spColorPrimary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Nuevo',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: spColorPrimary,
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

          // RESUMEN
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildResumenCarga(routeInfo),
            ),
          ),
        ],
      ),
    );
  }

// Resumen de carga con datos de la ruta - TODO EN UN MÉTODO
  Widget _buildResumenCarga(RouteInfo routeInfo) {
    // Función local para obtener nombre de bodega
    String getBodegaName(String? bodegaCode) {
      if (bodegaCode == null || bodegaCode.isEmpty) return 'Sin Asignar';
      switch (bodegaCode) {
        case '0111':
          return 'Bodega Lourdes';
        case '0333':
          return 'Bodega San Miguel';
        default:
          return 'Bodega Otra';
      }
    }

    // Obtener código de bodega
    String? bodegaCode;
    if (routeInfo.products.isNotEmpty) {
      bodegaCode = routeInfo.products[0].bodega;
    }
    final bodegaName = getBodegaName(bodegaCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // Card única con todo el resumen
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeController.isDarkMode ? spCardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: spColorPrimary900.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grid compacto de métricas (2x2)
              Column(
                children: [
                  // Fila 1: Productos y Cajas
                  Row(
                    children: [
                      // Métrica Productos
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: spColorPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: spColorPrimary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  color: spColorPrimary, size: 18),
                              const SizedBox(height: 6),
                              Text(
                                routeInfo.totalItems.toString(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: themeController.isDarkMode
                                      ? Colors.white
                                      : spTextColor,
                                ),
                              ),
                              Text(
                                'Productos',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: themeController.isDarkMode
                                      ? spColorGrey300
                                      : spColorGrey600,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Métrica Cajas
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: spColorTeal600.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: spColorTeal600.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.all_inbox_outlined,
                                  color: spColorTeal600, size: 18),
                              const SizedBox(height: 6),
                              Text(
                                routeInfo.totalBoxes.toStringAsFixed(0),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: themeController.isDarkMode
                                      ? Colors.white
                                      : spTextColor,
                                ),
                              ),
                              Text(
                                'Cajas',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: themeController.isDarkMode
                                      ? spColorGrey300
                                      : spColorGrey600,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Fila 2: Unidades y Kilogramos
                  Row(
                    children: [
                      // Métrica Unidades
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: spColorViolet500.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: spColorViolet500.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.confirmation_number_outlined,
                                  color: spColorViolet500, size: 18),
                              const SizedBox(height: 6),
                              Text(
                                routeInfo.products
                                    .fold<int>(
                                        0,
                                        (sum, product) =>
                                            sum + product.unidades)
                                    .toString(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: themeController.isDarkMode
                                      ? Colors.white
                                      : spTextColor,
                                ),
                              ),
                              Text(
                                'Unidades',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: themeController.isDarkMode
                                      ? spColorGrey300
                                      : spColorGrey600,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Métrica Kilogramos
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: spColorSuccess500.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: spColorSuccess500.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.scale_outlined,
                                  color: spColorSuccess500, size: 18),
                              const SizedBox(height: 6),
                              Text(
                                routeInfo.totalKilogramos.toStringAsFixed(1),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: themeController.isDarkMode
                                      ? Colors.white
                                      : spTextColor,
                                ),
                              ),
                              Text(
                                'Kg',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: themeController.isDarkMode
                                      ? spColorGrey300
                                      : spColorGrey600,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Información de bodega compacta
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: spColorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: spColorPrimary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warehouse_outlined,
                        color: spColorPrimary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bodegaName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: themeController.isDarkMode
                                  ? Colors.white
                                  : spTextColor,
                            ),
                          ),
                          if (bodegaCode != null) ...[
                            Text(
                              'Código: $bodegaCode',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: themeController.isDarkMode
                                    ? spColorGrey400
                                    : spColorGrey500,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: spColorSuccess500.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Activa',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: spColorSuccess700,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Botón Iniciar Carga
        KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.enter &&
                !controller.isLoading.value) {
              _iniciarCargaDespacho(routeInfo);
            }
          },
          child: Container(
            width: double.infinity,
            height: 50,
            child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          await _iniciarCargaDespacho(routeInfo);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isLoading.value
                        ? spColorGrey400
                        : spColorPrimary300,
                    foregroundColor: spColorGrey900,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    spColorGrey900),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Iniciando...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: spColorGrey900,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Iniciar Carga (ENT)',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: spColorGrey900,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                )),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _iniciarCargaDespacho(RouteInfo routeInfo) async {
    try {
      // Activar loading
      controller.isLoading.value = true;

      // Obtener datos del usuario desde storage
      final box = GetStorage();
      final userCode = box.read('user_code') ?? '';

      if (userCode.isEmpty) {
        _showErrorMessage('Error: No se encontró código de usuario');
        return;
      }

      // Preparar JSON de productos
      final productosJson = _prepararProductosJson(routeInfo.products);

      // Llamar a la API
      final response = await DespachoService.instance.iniciarSesion(
        idRuta: controller.scannedCode.value,
        codigoUser: userCode,
        productosRutaJson: productosJson,
        observacionesIniciales: 'Sesión iniciada desde app móvil',
      );

      if (response.isSuccess && response.data != null) {
        // Extraer ID de sesión de la respuesta
        final idSesion = _extraerIdSesion(response.data!);

        if (idSesion != null) {
          _showSuccessMessage('Sesión iniciada exitosamente');

          // Navegar a la nueva vista pasando los datos necesarios
          Get.toNamed(MyRoute.spDespachoDetalle,
              arguments: controller.scannedCode.value);
        } else {
          _showErrorMessage(
              'Error : ${response.message}, Estado: ${response.details}');
        }
      } else {
        _showErrorMessage(response.message);
      }
    } catch (e) {
      print('❌ Error al iniciar carga: $e');
      _showErrorMessage('Error inesperado: $e');
    } finally {
      // Desactivar loading
      controller.isLoading.value = false;
    }
  }

  // Preparar JSON de productos para la API
  String _prepararProductosJson(List<ProductInfo> productos) {
    if (productos.isEmpty) return '[]';

    final productosMap = productos
        .map((producto) => {
              'itemId': producto.itemId,
              'itemName': producto.itemName,
              'unidades': producto.unidades,
              'kilogramos': producto.kilogramos,
              'boxRound': producto.boxRound,
              'lote': producto.lote,
              'bodega': producto.bodega,
              'codigoBarra': producto.adtcodigobarra,
              'factor': producto.factor,
              'vencimiento': producto.vencimiento?.toIso8601String(),
            })
        .toList();
    final jsonString = jsonEncode(productosMap);
    return jsonString;
  }

  // Mostrar mensaje de éxito
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

  // Mostrar mensaje de error
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

  // Extraer ID de sesión de la respuesta de la API
  int? _extraerIdSesion(Map<String, dynamic> responseData) {
    try {
      // Ajusta esta lógica según la estructura de tu respuesta
      if (responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is List && data.isNotEmpty) {
          final firstItem = data.first;
          if (firstItem is Map<String, dynamic> &&
              firstItem.containsKey('idSesion')) {
            return firstItem['idSesion'] as int?;
          }
        } else if (data is Map<String, dynamic> &&
            data.containsKey('idSesion')) {
          return data['idSesion'] as int?;
        }
      }

      // Si no está en 'data', buscar directamente
      if (responseData.containsKey('idSesion')) {
        return responseData['idSesion'] as int?;
      }

      return null;
    } catch (e) {
      print('❌ Error al extraer ID de sesión: $e');
      return null;
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor:
          themeController.isDarkMode ? spDarkPrimary : spColorLightBg,
      elevation: 0,
      leadingWidth: 70, // Dar espacio suficiente para el botón
      centerTitle: false,

      title: Padding(
        padding: const EdgeInsets.only(left: 10), // Ajustar si es necesario
        child: Text(
          'Regresar a Inicio',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: themeController.isDarkMode ? Colors.white : spTextColor,
          ),
        ),
      ),

      leading: Center(
        child: InkWell(
          onTap: () {
            // Navegar al inicio en lugar de hacer pop
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
}
