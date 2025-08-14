// ===== lib/services/app_update_service.dart =====
// VERSIÓN SÚPER SIMPLE - SOLO DESCARGA MANUAL

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sabipay/constant/sp_colors.dart';

class AppUpdateService extends GetxService {
  static AppUpdateService get instance => Get.find<AppUpdateService>();

  // 🎯 CONFIGURACIÓN SIMPLE - SOLO CAMBIAR ESTOS 2 VALORES:
  static const String NUEVA_VERSION = '1.4.3'; // ← CAMBIAR VERSIÓN
  static const String ONEDRIVE_FOLDER_URL =
      'https://drive.google.com/drive/folders/1AGgB08i9Vz5URibFXEcZY0oxb7OUtP6D'; // ← CARPETA ONEDRIVE
  static const bool FORZAR_ACTUALIZACION = true; // ← true = obligatoria

  // Estados reactivos
  final currentVersion = '1.0.0'.obs;

  @override
  void onInit() {
    super.onInit();
    _setupVersion();
    _checkUpdateAfterDelay();
  }

  /// Obtener versión actual
  Future<void> _setupVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      currentVersion.value = info.version;
    } catch (e) {
      currentVersion.value = '1.0.0';
    }
  }

  /// Verificar actualización después de 3 segundos
  void _checkUpdateAfterDelay() {
    Future.delayed(Duration(seconds: 3), () {
      if (_needsUpdate()) {
        print('🔄 Actualización disponible');
        if (FORZAR_ACTUALIZACION) {
          _showForceDialog();
        } else {
          _showNotification();
        }
      } else {
        print('✅ App actualizada');
      }
    });
  }

  /// ¿Necesita actualización?
  bool _needsUpdate() {
    return currentVersion.value != NUEVA_VERSION;
  }

  /// Notificación opcional
  void _showNotification() {
    Get.snackbar(
      '🔄 Nueva Versión',
      'Versión $NUEVA_VERSION disponible. ¡Toca para actualizar!',
      backgroundColor: spColorPrimary,
      colorText: Colors.white,
      duration: Duration(seconds: 6),
      onTap: (_) => showUpdateDialog(),
      margin: EdgeInsets.all(16),
      borderRadius: 12,
      icon: Icon(Icons.system_update, color: Colors.white),
    );
  }

  /// Diálogo forzado (obligatorio)
  void _showForceDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              Icon(Icons.warning_rounded, color: Colors.red, size: 48),
              SizedBox(height: 8),
              Text('Actualización Obligatoria',
                  style: TextStyle(color: Colors.red)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Debes actualizar para continuar usando la app.',
                  textAlign: TextAlign.center),
              SizedBox(height: 12),
              Text('Versión requerida: $NUEVA_VERSION',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Versión actual: ${currentVersion.value}',
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: openOneDrive,
              icon: Icon(Icons.cloud_download),
              label: Text('Ir a OneDrive'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Diálogo opcional
  void showUpdateDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.system_update, color: spColorPrimary, size: 28),
            SizedBox(width: 8),
            Text('Nueva Versión Disponible'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nueva versión: $NUEVA_VERSION'),
            Text('Versión actual: ${currentVersion.value}'),
            SizedBox(height: 16),

            // Instrucciones simples
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('Pasos para actualizar:',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('1. Se abrirá OneDrive'),
                  Text('2. Busca: SabiPay_v$NUEVA_VERSION.apk'),
                  Text('3. Descarga el archivo'),
                  Text('4. Instálalo tocando el archivo'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!FORZAR_ACTUALIZACION)
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Más tarde'),
            ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              openOneDrive();
            },
            icon: Icon(Icons.cloud_download),
            label: Text('Abrir OneDrive'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: Size(200, 48),
            ),
          ),
        ],
      ),
    );
  }

  /// ===== FUNCIÓN PRINCIPAL: ABRIR ONEDRIVE =====

  Future<void> openOneDrive() async {
    try {
      final url = Uri.parse(ONEDRIVE_FOLDER_URL);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);

        Get.snackbar(
          '☁️ OneDrive Abierto',
          'Busca y descarga: SabiPay_v$NUEVA_VERSION.apk',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 8),
          icon: Icon(Icons.cloud_download, color: Colors.white),
          mainButton: TextButton(
            onPressed: () => _showInstructionsDialog(),
            child: Text('AYUDA',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
      } else {
        throw Exception('No se puede abrir OneDrive');
      }
    } catch (e) {
      print('❌ Error abriendo OneDrive: $e');
      _showError('No se pudo abrir OneDrive. Verifica tu conexión.');
    }
  }

  /// Diálogo de instrucciones detalladas
  void _showInstructionsDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue, size: 28),
            SizedBox(width: 8),
            Text('Instrucciones'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sigue estos pasos para actualizar:'),
            SizedBox(height: 16),
            _buildStep(1,
                'En OneDrive, busca el archivo: SabiPay_v$NUEVA_VERSION.apk'),
            _buildStep(2, 'Toca el archivo para descargarlo'),
            _buildStep(3, 'Una vez descargado, ve a Descargas'),
            _buildStep(4, 'Toca el archivo APK para instalarlo'),
            _buildStep(5, 'Permite "Fuentes desconocidas" si aparece'),
            _buildStep(6, 'Sigue las instrucciones de instalación'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              openOneDrive(); // Abrir OneDrive de nuevo
            },
            child: Text('Abrir OneDrive'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Widget para pasos numerados
  Widget _buildStep(int number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text('$number',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  /// Mostrar error
  void _showError(String message) {
    Get.snackbar(
      '❌ Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.error, color: Colors.white),
    );
  }

  /// ===== WIDGET PARA CONFIGURACIONES =====

  Widget buildSettingsCard() {
    return Obx(() {
      final needsUpdate = _needsUpdate();

      return Card(
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (needsUpdate ? Colors.orange : Colors.green)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      needsUpdate ? Icons.system_update : Icons.check_circle,
                      color: needsUpdate ? Colors.orange : Colors.green,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          needsUpdate
                              ? 'Actualización Disponible'
                              : 'App Actualizada',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Versión actual: ${currentVersion.value}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        if (needsUpdate)
                          Text(
                            'Nueva versión: $NUEVA_VERSION',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (needsUpdate) ...[
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: openOneDrive,
                  icon: Icon(Icons.cloud_download, size: 18),
                  label: Text('Ir a OneDrive'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  /// Verificar manualmente (para botón de refresh)
  Future<void> checkForUpdates() async {
    await _setupVersion();

    if (_needsUpdate()) {
      showUpdateDialog();
    } else {
      Get.snackbar(
        '✅ Actualizada',
        'Ya tienes la última versión (${currentVersion.value})',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        icon: Icon(Icons.check_circle, color: Colors.white),
      );
    }
  }
}
