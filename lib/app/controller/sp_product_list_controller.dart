// Crear archivo: lib/app/controller/sp_product_list_controller.dart
import 'package:get/get.dart';
import 'package:sabipay/services/route_service.dart';

class SPProductListController extends GetxController {
  // Variables reactivas
  final isLoading = false.obs;
  final selectedProductIndex = (-1).obs;

  // Datos de la sesión
  late int idSesion;
  late RouteInfo routeInfo;
  late String codigoRuta;

  // Lista de productos escaneados/procesados
  final scannedProducts = <String>[].obs;
  final productProgress = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  void _initializeData() {
    final args = Get.arguments as Map<String, dynamic>;
    idSesion = args['idSesion'];
    routeInfo = args['routeInfo'];
    codigoRuta = args['codigoRuta'];

    print('🎯 ProductListController inicializado');
    print('   ID Sesión: $idSesion');
    print('   Código Ruta: $codigoRuta');
    print('   Total Productos: ${routeInfo.totalItems}');
  }

  // Marcar producto como escaneado/procesado
  void markProductAsScanned(int index, String productId) {
    productProgress[index] = true;
    scannedProducts.add(productId);
    update();
    print('✅ Producto $index marcado como escaneado: $productId');
  }

  // Verificar si un producto está escaneado
  bool isProductScanned(int index) {
    return productProgress[index] ?? false;
  }

  // Obtener progreso total
  double get progressPercentage {
    if (routeInfo.products.isEmpty) return 0.0;
    int scannedCount =
        productProgress.values.where((scanned) => scanned).length;
    return scannedCount / routeInfo.products.length;
  }

  // Obtener cantidad de productos escaneados
  int get scannedCount {
    return productProgress.values.where((scanned) => scanned).length;
  }

  // Seleccionar producto
  void selectProduct(int index) {
    selectedProductIndex.value = index;
    update();
  }

  // Finalizar sesión (puedes expandir esta función)
  Future<void> finalizarSesion() async {
    try {
      isLoading.value = true;

      // Aquí puedes llamar a la API para finalizar la sesión
      // await DespachoService.instance.finalizarSesion(idSesion);

      print('🏁 Sesión finalizada exitosamente');

      // Regresar a la vista anterior
      Get.back();
    } catch (e) {
      print('❌ Error al finalizar sesión: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Obtener información del producto por índice
  ProductInfo getProduct(int index) {
    return routeInfo.products[index];
  }
}
