// ===== lib/services/app_update_service.dart =====
// VERSIÓN SIMPLE SIN DEPENDENCIAS PROBLEMÁTICAS

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sabipay/constant/sp_colors.dart';

class AppUpdateService extends GetxService {
  static AppUpdateService get instance => Get.find<AppUpdateService>();

  // 🎯 CONFIGURACIÓN - SOLO CAMBIAR ESTOS VALORES:
  static const String NUEVA_VERSION = '1.4.2'; // ← CAMBIAR AQUÍ
  static const String GOOGLE_DRIVE_ID =
      '1mZOzulRiVT8qDOSYE-Nsgn2pvscjU9fL'; // ← TU ID
  static const bool FORZAR_ACTUALIZACION = true; // ← true = obligatoria

  // 🔧 URL CONSTRUIDA AUTOMÁTICAMENTE
  static const String DRIVE_DOWNLOAD_URL =
      'https://drive.google.com/uc?export=download&id=$GOOGLE_DRIVE_ID';

  // Estados reactivos
  final downloading = false.obs;
  final progress = 0.0.obs;
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
      print('📱 Versión actual: ${currentVersion.value}');
      print('🎯 Versión objetivo: $NUEVA_VERSION');
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

  /// Diálogo forzado
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
              Text('Debes actualizar para continuar.',
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
              onPressed: downloadUpdate,
              icon: Icon(Icons.download),
              label: Text('Actualizar Ahora'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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
            Text('Nueva Versión'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nueva versión: $NUEVA_VERSION'),
            Text('Actual: ${currentVersion.value}'),
            SizedBox(height: 16),

            // Opción 1: Automática
            _buildOption(
              icon: Icons.download,
              title: 'Descarga Automática',
              subtitle: 'Descarga y abre el instalador',
              color: Colors.green,
              isRecommended: true,
              onTap: () {
                Get.back();
                downloadUpdate();
              },
            ),

            SizedBox(height: 12),

            // Opción 2: Manual
            _buildOption(
              icon: Icons.link,
              title: 'Google Drive',
              subtitle: 'Descarga manual desde Drive',
              color: Colors.blue,
              isRecommended: false,
              onTap: () {
                Get.back();
                openDriveLink();
              },
            ),
          ],
        ),
        actions: [
          if (!FORZAR_ACTUALIZACION)
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Más tarde'),
            ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isRecommended,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isRecommended ? color : color.withOpacity(0.3),
            width: isRecommended ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(isRecommended ? 0.05 : 0.02),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      if (isRecommended) ...[
                        SizedBox(width: 8),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'RECOMENDADO',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  /// ===== DESCARGA AUTOMÁTICA =====

  Future<void> downloadUpdate() async {
    if (downloading.value) return;

    downloading.value = true;
    progress.value = 0.0;

    try {
      // 1. Verificar permisos
      if (!await _requestPermissions()) {
        _showError('Necesito permisos para descargar');
        return;
      }

      // 2. Mostrar progreso
      _showProgressDialog();

      // 3. Descargar
      final filePath = await _downloadFile();

      // 4. Cerrar progreso
      Get.back();

      // 5. Mostrar diálogo de instalación
      _showInstallDialog(filePath);
    } catch (e) {
      print('❌ Error en descarga: $e');
      Get.back(); // Cerrar progreso

      // Fallback automático a Drive
      Get.snackbar(
        '🔄 Alternativa',
        'Abriendo Google Drive...',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      await Future.delayed(Duration(seconds: 1));
      openDriveLink();
    } finally {
      downloading.value = false;
      progress.value = 0.0;
    }
  }

  /// Descargar archivo
  Future<String> _downloadFile() async {
    final dir = await getExternalStorageDirectory();
    final fileName = 'SabiPay_v$NUEVA_VERSION.apk';
    final filePath = '${dir!.path}/$fileName';

    print('📥 Descargando: $DRIVE_DOWNLOAD_URL');
    print('📁 Guardando: $filePath');

    await Dio().download(
      DRIVE_DOWNLOAD_URL,
      filePath,
      options: Options(
        followRedirects: true,
        maxRedirects: 5,
        headers: {'User-Agent': 'Mozilla/5.0 (Android) Mobile App'},
      ),
      onReceiveProgress: (received, total) {
        if (total > 0) {
          progress.value = received / total;
          print('📊 ${(progress.value * 100).toInt()}%');
        }
      },
    );

    print('✅ Descarga completa: $filePath');
    return filePath;
  }

  /// Diálogo de progreso
  void _showProgressDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    value: progress.value,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(spColorPrimary),
                  ),
                  SizedBox(height: 16),
                  Text('Descargando... ${(progress.value * 100).toInt()}%',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('No cierres la aplicación',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              )),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Diálogo de instalación completada
  void _showInstallDialog(String filePath) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('¡Descarga Completada!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('La actualización se descargó correctamente.'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text('Archivo guardado en Descargas',
                          style: TextStyle(fontSize: 12))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!FORZAR_ACTUALIZACION)
            TextButton(onPressed: () => Get.back(), child: Text('Más tarde')),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              _installApk(filePath);
            },
            icon: Icon(Icons.install_mobile),
            label: Text('Abrir Instalador'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: Size(200, 48),
            ),
          ),
        ],
      ),
    );
  }

  /// ===== INSTALACIÓN SIMPLE =====

  /// FUNCIÓN PRINCIPAL DE INSTALACIÓN - SOLO URL LAUNCHER
  Future<void> _installApk(String filePath) async {
    try {
      print('📱 Abriendo instalador: $filePath');

      // Verificar que el archivo existe
      final file = File(filePath);
      if (!await file.exists()) {
        _showError('Archivo no encontrado');
        return;
      }

      // Usar url_launcher (método más compatible)
      await _openWithUrlLauncher(filePath);
    } catch (e) {
      print('❌ Error abriendo instalador: $e');
      _showManualInstallDialog(filePath);
    }
  }

  /// Método principal: URL Launcher
  Future<void> _openWithUrlLauncher(String filePath) async {
    try {
      // Intentar diferentes enfoques
      final uri = Uri.file(filePath);

      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          Get.snackbar(
            '📱 Instalador Abierto',
            'Sigue las instrucciones para instalar',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            icon: Icon(Icons.install_mobile, color: Colors.white),
          );
        } else {
          throw Exception('No se pudo lanzar');
        }
      } else {
        // Fallback: intentar con content URI
        await _openWithContentUri(filePath);
      }
    } catch (e) {
      throw Exception('Error url_launcher: $e');
    }
  }

  /// Fallback: Intentar con content URI
  Future<void> _openWithContentUri(String filePath) async {
    try {
      // Construir URI de contenido para Android
      final fileName = filePath.split('/').last;
      final contentUri = Uri.parse(
          'content://com.android.externalstorage.documents/document/primary%3AAndroid%2Fdata%2F${fileName}');

      if (await canLaunchUrl(contentUri)) {
        await launchUrl(contentUri, mode: LaunchMode.externalApplication);

        Get.snackbar(
          '📁 Archivo Abierto',
          'Busca el archivo APK y tócalo para instalar',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      } else {
        throw Exception('No se puede abrir con content URI');
      }
    } catch (e) {
      throw Exception('Error content URI: $e');
    }
  }

  /// Diálogo de instalación manual (último recurso)
  void _showManualInstallDialog(String filePath) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Instalación Manual'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Para instalar la actualización:'),
            SizedBox(height: 12),
            _buildStep(1, 'Ve a la carpeta Descargas'),
            _buildStep(2, 'Busca: SabiPay_v$NUEVA_VERSION.apk'),
            _buildStep(3, 'Toca el archivo para instalarlo'),
            _buildStep(4, 'Permite "Fuentes desconocidas" si se solicita'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Ruta: $filePath',
                style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _openFileManager(),
            child: Text('Abrir Archivos'),
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
              color: spColorPrimary,
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

  /// ===== GOOGLE DRIVE DIRECTO =====

  Future<void> openDriveLink() async {
    try {
      final url = Uri.parse(DRIVE_DOWNLOAD_URL);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        Get.snackbar(
          '📱 Google Drive',
          'Descarga el APK e instálalo manualmente',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
          icon: Icon(Icons.cloud_download, color: Colors.white),
        );
      }
    } catch (e) {
      print('❌ Error Drive: $e');
      _showError('No se pudo abrir Google Drive');
    }
  }

  /// ===== UTILIDADES =====

  Future<bool> _requestPermissions() async {
    if (!Platform.isAndroid) return true;

    try {
      Map<Permission, PermissionStatus> permissions = await [
        Permission.storage,
        Permission.requestInstallPackages,
      ].request();

      bool hasPermissions = permissions.values.any((status) =>
          status == PermissionStatus.granted ||
          status == PermissionStatus.limited);

      if (!hasPermissions) {
        _showPermissionDialog();
      }
      return hasPermissions;
    } catch (e) {
      print('❌ Error permisos: $e');
      return false;
    }
  }

  void _showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.security, color: Colors.orange),
            SizedBox(width: 8),
            Text('Permisos Necesarios'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Para actualizar automáticamente necesito:'),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.folder, color: Colors.blue),
                SizedBox(width: 8),
                Text('Acceso a almacenamiento'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.install_mobile, color: Colors.green),
                SizedBox(width: 8),
                Text('Instalar aplicaciones'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              openDriveLink();
            },
            child: Text('Descarga Manual'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: Text('Configuración'),
          ),
        ],
      ),
    );
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  Future<void> _openFileManager() async {
    try {
      // Intentar abrir gestor de archivos
      final uri = Uri.parse(
          'content://com.android.externalstorage.documents/root/primary%3ADownload');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showError('No se pudo abrir el gestor de archivos');
      }
    } catch (e) {
      print('❌ Error gestor: $e');
      _showError('No se pudo abrir el gestor de archivos');
    }
  }

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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => openDriveLink(),
                        icon: Icon(Icons.link, size: 18),
                        label: Text('Drive'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: downloading.value ? null : downloadUpdate,
                        icon: downloading.value
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(Icons.download, size: 18),
                        label: Text(downloading.value
                            ? 'Descargando...'
                            : 'Actualizar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  /// Verificar manualmente
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
