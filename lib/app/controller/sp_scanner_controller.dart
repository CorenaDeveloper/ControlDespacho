import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SPScannerController extends GetxController {
  // Variables observables
  final RxString scannedData = ''.obs;
  final RxString statusMessage =
      'Presiona el botón azul del HT330 para escanear'.obs;
  final RxBool isScanning = false.obs;
  final RxList<String> scanHistory = <String>[].obs;

  // Controladores de texto
  final TextEditingController manualInputController = TextEditingController();
  final FocusNode scannerFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    _initializeScanner();
    // Mantener el foco en el campo invisible para capturar el escaneo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scannerFocusNode.requestFocus();
    });
  }

  void _initializeScanner() {
    statusMessage.value =
        'Escáner listo - HT330 v1.3 Unitech\nPresiona el botón azul para escanear';
  }

  void onScanResult(String data) {
    // Limpiar datos duplicados o concatenados
    String cleanData = data.trim();

    // Si el dato contiene múltiples códigos concatenados, tomar solo el último
    if (cleanData.length > 30) {
      // Buscar patrones repetidos y tomar solo uno
      List<String> parts = [];
      int chunkSize = cleanData.length ~/ 3; // Dividir en 3 partes aprox

      for (int i = 0; i < cleanData.length; i += chunkSize) {
        int end = (i + chunkSize < cleanData.length)
            ? i + chunkSize
            : cleanData.length;
        String chunk = cleanData.substring(i, end);
        if (chunk.isNotEmpty && !parts.contains(chunk)) {
          parts.add(chunk);
        }
      }

      // Tomar la parte más corta (probablemente el código real)
      if (parts.isNotEmpty) {
        parts.sort((a, b) => a.length.compareTo(b.length));
        cleanData = parts.first;
      }
    }

    // Actualizar estados
    scannedData.value = cleanData;
    isScanning.value = false;
    statusMessage.value =
        'Código escaneado exitosamente\nListo para el siguiente';

    // Solo agregar si no es duplicado
    if (scanHistory.isEmpty || scanHistory.first != cleanData) {
      scanHistory.insert(0, cleanData);
      if (scanHistory.length > 10) {
        scanHistory.removeLast();
      }
    }

    // Buscar en la base de datos
    searchInDatabase(cleanData);
  }

  void searchInDatabase(String code) {
    // Placeholder para la búsqueda en base de datos
    Get.snackbar(
      'Buscando...',
      'Código: $code en la base de datos...',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );

    // Aquí puedes agregar la lógica real de búsqueda en tu base de datos
    // Por ejemplo, llamar a tu API service
  }

  void manualInput() {
    if (manualInputController.text.isNotEmpty) {
      onScanResult(manualInputController.text);
      manualInputController.clear();
    }
  }

  void clearHistory() {
    scanHistory.clear();
    scannedData.value = '';
    statusMessage.value = 'Historial limpiado - Listo para escanear';
  }

  void startDemoScan() {
    isScanning.value = true;
    statusMessage.value = 'Escaneando... Apunta a la hoja';

    // Simular escáneo - para pruebas
    Future.delayed(const Duration(seconds: 2), () {
      onScanResult('DEMO123456789');
    });
  }

  @override
  void onClose() {
    manualInputController.dispose();
    scannerFocusNode.dispose();
    super.onClose();
  }
}
