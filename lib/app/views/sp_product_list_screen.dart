// Archivo actualizado: lib/app/views/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sabipay/app/controller/sp_product_list_controller.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/services/route_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  ProductListScreenState createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  final SPProductListController controller = Get.put(SPProductListController());
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    theme =
        Get.isDarkMode ? SPWalletTheme.spDarkTheme : SPWalletTheme.spLightTheme;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SPProductListController>(
      init: controller,
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Productos - Ruta ${controller.codigoRuta}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Get.isDarkMode ? spDarkPrimary : Colors.white,
            actions: [
              // Botón de progreso
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Obx(() => Text(
                        '${controller.scannedCount}/${controller.routeInfo.products.length}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: spColorPrimary,
                        ),
                      )),
                ),
              ),
            ],
          ),
          backgroundColor: Get.isDarkMode ? spDarkPrimary : Colors.white,
          body: Column(
            children: [
              // Header con información de sesión y progreso
              _buildSessionHeader(),

              // Barra de progreso
              _buildProgressBar(),

              // Lista de productos
              Expanded(
                child: _buildProductList(),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomActions(),
        );
      },
    );
  }

  Widget _buildSessionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: spColorPrimary50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: spColorPrimary300),
      ),
      child: Row(
        children: [
          Icon(Icons.play_circle_filled, color: spColorPrimary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sesión Activa',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: spColorPrimary700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'ID: ${controller.idSesion}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: spColorPrimary700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: spColorSuccess500,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'ACTIVA',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso de Carga',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Obx(() => Text(
                    '${(controller.progressPercentage * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: spColorPrimary,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => LinearProgressIndicator(
                value: controller.progressPercentage,
                backgroundColor:
                    Get.isDarkMode ? spColorGrey700 : spColorGrey200,
                valueColor: AlwaysStoppedAnimation<Color>(spColorPrimary),
                minHeight: 6,
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.routeInfo.products.length,
      itemBuilder: (context, index) {
        final product = controller.getProduct(index);
        return Obx(() => _buildProductCard(product, index));
      },
    );
  }

  Widget _buildProductCard(ProductInfo product, int index) {
    final isScanned = controller.isProductScanned(index);
    final isSelected = controller.selectedProductIndex.value == index;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      color: isScanned
          ? spColorSuccess50
          : isSelected
              ? spColorPrimary50
              : Get.isDarkMode
                  ? spCardDark
                  : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isScanned
              ? spColorSuccess500
              : isSelected
                  ? spColorPrimary
                  : spColorGrey300,
          child: isScanned
              ? Icon(Icons.check, color: Colors.white)
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : spColorGrey700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Text(
          product.itemName,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isScanned ? spColorSuccess700 : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${product.itemId} | ${product.unidades} unidades'),
            Text(
                '${product.kilogramos.toStringAsFixed(2)} kg | ${product.boxRound.toStringAsFixed(0)} cajas'),
          ],
        ),
        trailing: isScanned
            ? Icon(Icons.check_circle, color: spColorSuccess500)
            : Icon(Icons.qr_code_scanner, color: spColorPrimary),
        onTap: () {
          controller.selectProduct(index);
          // Aquí puedes navegar al scanner de este producto específico
          _onProductTap(product, index);
        },
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? spCardDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Simular marcar todos como escaneados (para testing)
                _markAllAsScanned();
              },
              child: Text('Marcar Todos'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(() => ElevatedButton(
                  onPressed: controller.progressPercentage >= 1.0
                      ? () => controller.finalizarSesion()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: spColorPrimary,
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Finalizar',
                          style: TextStyle(color: Colors.white),
                        ),
                )),
          ),
        ],
      ),
    );
  }

  void _onProductTap(ProductInfo product, int index) {
    // Aquí puedes implementar la lógica para escanear el producto específico
    print('🎯 Producto seleccionado: ${product.itemName}');

    // Por ahora, simplemente lo marcamos como escaneado
    controller.markProductAsScanned(index, product.itemId);

    // TODO: Navegar a una vista de scanner específica para este producto
    // Get.to(() => ProductScannerScreen(), arguments: {
    //   'product': product,
    //   'index': index,
    //   'sessionId': controller.idSesion,
    // });
  }

  void _markAllAsScanned() {
    // Función de testing para marcar todos los productos como escaneados
    for (int i = 0; i < controller.routeInfo.products.length; i++) {
      final product = controller.getProduct(i);
      controller.markProductAsScanned(i, product.itemId);
    }
  }
}
