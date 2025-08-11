import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Servicio para el manejo estandarizado de escaneo de códigos de barras
/// Soporta escáneres HT330 y otros dispositivos similares
class BarcodeScannerService extends GetxService {
  static BarcodeScannerService get instance =>
      Get.find<BarcodeScannerService>();

  // StreamController para escuchar códigos escaneados
  final _scannedCodeController = StreamController<String>.broadcast();
  Stream<String> get scannedCodeStream => _scannedCodeController.stream;

  // Configuración del servicio
  final _config = BarcodeScannerConfig();

  // Estado del escáner
  final isActive = false.obs;
  final lastScannedCode = ''.obs;
  final scanHistory = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    print('🔍 Barcode Scanner Service inicializado');
  }

  @override
  void onClose() {
    _scannedCodeController.close();
    super.onClose();
  }

  /// Configurar el escáner con parámetros personalizados
  void configure(BarcodeScannerConfig config) {
    _config.updateFrom(config);
  }

  /// Crear un listener para escáner HT330 (teclado físico)
  Widget createHT330Listener({
    required Widget child,
    required Function(String) onCodeScanned,
    FocusNode? customFocusNode,
  }) {
    final focusNode = customFocusNode ?? FocusNode();
    final hiddenController = TextEditingController();

    return _HT330Wrapper(
      focusNode: focusNode,
      hiddenController: hiddenController,
      onCodeScanned: (code) {
        final cleanCode = processRawCode(code);
        if (cleanCode.isNotEmpty) {
          _handleScannedCode(cleanCode);
          onCodeScanned(cleanCode);
        }
      },
      child: child,
    );
  }

  /// Procesar código crudo del escáner
  String processRawCode(String rawCode) {
    if (rawCode.isEmpty) return '';

    try {
      // Paso 1: Limpieza básica
      String cleaned = _basicCleanup(rawCode);

      // Paso 2: Manejo de códigos duplicados/concatenados
      cleaned = _handleDuplicatedCodes(cleaned);

      // Paso 3: Validación final
      if (_isValidBarcode(cleaned)) {
        return cleaned;
      }

      // Paso 4: Intentar recuperar código válido
      final recovered = _tryRecoverValidCode(rawCode);
      if (recovered.isNotEmpty) {
        return recovered;
      }

      print(
          '⚠️ Código no válido después de procesamiento: "$rawCode" -> "$cleaned"');
      return '';
    } catch (e) {
      print('❌ Error procesando código: $e');
      return '';
    }
  }

  /// Validar formato de código de barras
  bool validateBarcodeFormat(String code) {
    return _isValidBarcode(code);
  }

  /// Obtener estadísticas de escaneo
  Map<String, dynamic> getScanStatistics() {
    return {
      'totalScans': scanHistory.length,
      'lastScan': lastScannedCode.value,
      'isActive': isActive.value,
      'uniqueCodes': scanHistory.toSet().length,
      'scanHistory': scanHistory.take(10).toList(), // Últimos 10
    };
  }

  /// Limpiar historial de escaneo
  void clearHistory() {
    scanHistory.clear();
    lastScannedCode.value = '';
  }

  // =============================================================================
  // MÉTODOS PRIVADOS
  // =============================================================================

  /// Manejo interno de código escaneado
  void _handleScannedCode(String code) {
    lastScannedCode.value = code;
    scanHistory.add(code);

    // Mantener historial limitado
    if (scanHistory.length > _config.maxHistorySize) {
      scanHistory.removeAt(0);
    }

    // Emitir evento
    _scannedCodeController.add(code);

    print('✅ Código procesado: $code');
  }

  /// Limpieza básica de caracteres de control
  String _basicCleanup(String rawData) {
    // Remover caracteres nulos y de control comunes
    return rawData
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Caracteres de control
        .replaceAll('\u0000', '') // Null
        .replaceAll('\u0001', '') // Start of Heading
        .replaceAll('\u0002', '') // Start of Text
        .replaceAll('\u0003', '') // End of Text
        .replaceAll('\u0004', '') // End of Transmission
        .replaceAll('\u0005', '') // Enquiry
        .replaceAll('\u0006', '') // Acknowledge
        .replaceAll('\u0007', '') // Bell
        .replaceAll('\u0008', '') // Backspace
        .replaceAll('\u000B', '') // Vertical Tab
        .replaceAll('\u000C', '') // Form Feed
        .replaceAll('\u000E', '') // Shift Out
        .replaceAll('\u000F', '') // Shift In
        .replaceAll('\u0010', '') // Data Link Escape
        .replaceAll('\u0011', '') // Device Control 1
        .replaceAll('\u0012', '') // Device Control 2
        .replaceAll('\u0013', '') // Device Control 3
        .replaceAll('\u0014', '') // Device Control 4
        .replaceAll('\u0015', '') // Negative Acknowledge
        .replaceAll('\u0016', '') // Synchronous Idle
        .replaceAll('\u0017', '') // End of Transmission Block
        .replaceAll('\u0018', '') // Cancel
        .replaceAll('\u0019', '') // End of Medium
        .replaceAll('\u001A', '') // Substitute
        .replaceAll('\u001B', '') // Escape
        .replaceAll('\u001C', '') // File Separator
        .replaceAll('\u001D', '') // Group Separator
        .replaceAll('\u001E', '') // Record Separator
        .replaceAll('\u001F', '') // Unit Separator
        .replaceAll('\u007F', '') // Delete
        .trim();
  }

  /// Manejar códigos duplicados o concatenados
  String _handleDuplicatedCodes(String cleaned) {
    if (cleaned.length <= _config.maxSingleCodeLength) {
      return cleaned;
    }

    // Buscar separadores comunes
    final separators = ['\t', ' ', '\n', '\r', '-', '_'];
    List<String> potentialCodes = [];

    for (String separator in separators) {
      if (cleaned.contains(separator)) {
        final parts = cleaned.split(separator);
        for (var part in parts) {
          final trimmed = part.trim();
          if (trimmed.isNotEmpty && _isValidBarcode(trimmed)) {
            potentialCodes.add(trimmed);
          }
        }
        if (potentialCodes.isNotEmpty) break;
      }
    }

    // Si no hay separadores, intentar dividir por chunks
    if (potentialCodes.isEmpty) {
      potentialCodes = _splitIntoChunks(cleaned);
    }

    // Seleccionar el mejor candidato
    if (potentialCodes.isNotEmpty) {
      potentialCodes = potentialCodes.toSet().toList(); // Remover duplicados
      potentialCodes
          .sort((a, b) => _getBarcodeScore(b).compareTo(_getBarcodeScore(a)));
      return potentialCodes.first;
    }

    return cleaned;
  }

  /// Dividir en chunks para buscar códigos válidos
  List<String> _splitIntoChunks(String data) {
    final chunks = <String>[];
    final possibleLengths = [
      6,
      8,
      10,
      12,
      13,
      14
    ]; // Longitudes comunes de códigos

    for (int length in possibleLengths) {
      for (int i = 0; i <= data.length - length; i++) {
        final chunk = data.substring(i, i + length);
        if (_isValidBarcode(chunk)) {
          chunks.add(chunk);
        }
      }
    }

    return chunks;
  }

  /// Calcular score de calidad de código de barras
  int _getBarcodeScore(String code) {
    int score = 0;

    // Preferir códigos numéricos
    if (RegExp(r'^\d+$').hasMatch(code)) score += 10;

    // Preferir longitudes comunes
    if (code.length >= 6 && code.length <= 14) score += 5;

    // Penalizar códigos muy cortos o largos
    if (code.length < 4 || code.length > 20) score -= 10;

    // Penalizar muchos caracteres especiales
    final specialCount = RegExp(r'[^\w]').allMatches(code).length;
    score -= specialCount * 2;

    // Bonus por patrones conocidos
    if (RegExp(r'^\d{10}$').hasMatch(code)) score += 5; // Código de 10 dígitos
    if (RegExp(r'^\d{12,13}$').hasMatch(code)) score += 3; // EAN/UPC

    return score;
  }

  /// Validar si es un código de barras válido
  bool _isValidBarcode(String code) {
    if (code.isEmpty) return false;

    // Longitud aceptable
    if (code.length < _config.minCodeLength ||
        code.length > _config.maxCodeLength) return false;

    // Caracteres permitidos
    if (!RegExp(_config.allowedCharactersPattern).hasMatch(code)) return false;

    // No solo caracteres especiales
    if (RegExp(r'^[\s\-_.]+$').hasMatch(code)) return false;

    return true;
  }

  /// Intentar recuperar código válido de datos corruptos
  String _tryRecoverValidCode(String rawData) {
    // Intentar extraer números consecutivos
    final numbers = RegExp(r'\d+').allMatches(rawData);
    for (var match in numbers) {
      final candidate = match.group(0)!;
      if (_isValidBarcode(candidate)) {
        return candidate;
      }
    }

    // Intentar extraer alfanuméricos
    final alphanumeric = RegExp(r'[a-zA-Z0-9]+').allMatches(rawData);
    for (var match in alphanumeric) {
      final candidate = match.group(0)!;
      if (_isValidBarcode(candidate)) {
        return candidate;
      }
    }

    return '';
  }
}

/// Configuración del escáner de códigos de barras
class BarcodeScannerConfig {
  int minCodeLength;
  int maxCodeLength;
  int maxSingleCodeLength;
  int maxHistorySize;
  String allowedCharactersPattern;
  Duration debounceTime;

  BarcodeScannerConfig({
    this.minCodeLength = 4,
    this.maxCodeLength = 20,
    this.maxSingleCodeLength = 25,
    this.maxHistorySize = 100,
    this.allowedCharactersPattern = r'^[a-zA-Z0-9\-_.]+$',
    this.debounceTime = const Duration(milliseconds: 300),
  });

  void updateFrom(BarcodeScannerConfig other) {
    minCodeLength = other.minCodeLength;
    maxCodeLength = other.maxCodeLength;
    maxSingleCodeLength = other.maxSingleCodeLength;
    maxHistorySize = other.maxHistorySize;
    allowedCharactersPattern = other.allowedCharactersPattern;
    debounceTime = other.debounceTime;
  }
}

/// Widget wrapper para el manejo del escáner HT330
class _HT330Wrapper extends StatefulWidget {
  final FocusNode focusNode;
  final TextEditingController hiddenController;
  final Function(String) onCodeScanned;
  final Widget child;

  const _HT330Wrapper({
    required this.focusNode,
    required this.hiddenController,
    required this.onCodeScanned,
    required this.child,
  });

  @override
  State<_HT330Wrapper> createState() => _HT330WrapperState();
}

class _HT330WrapperState extends State<_HT330Wrapper> {
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Configurar foco inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Campo invisible para capturar el escáner
        Positioned(
          left: -1000,
          top: -1000,
          child: SizedBox(
            width: 1,
            height: 1,
            child: RawKeyboardListener(
              focusNode: widget.focusNode,
              onKey: _handleKeyEvent,
              child: TextField(
                controller: widget.hiddenController,
                readOnly: true,
                showCursor: false,
                enableInteractiveSelection: false,
                decoration: const InputDecoration.collapsed(hintText: ''),
                style: const TextStyle(color: Colors.transparent),
              ),
            ),
          ),
        ),
        // Contenido principal
        GestureDetector(
          onTap: _refocusScanner,
          child: widget.child,
        ),
      ],
    );
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final character = event.character;
      if (character != null && character.isNotEmpty) {
        widget.hiddenController.text += character;
      }

      // Detectar Enter (fin de código)
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _processScannedData();
      }
    }
  }

  void _processScannedData() {
    final scannedData = widget.hiddenController.text.trim();
    widget.hiddenController.clear();

    if (scannedData.isNotEmpty) {
      // Debounce para evitar lecturas múltiples
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        widget.onCodeScanned(scannedData);
      });
    }
  }

  void _refocusScanner() {
    if (mounted) {
      FocusScope.of(context).unfocus();
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          widget.focusNode.requestFocus();
        }
      });
    }
  }
}
