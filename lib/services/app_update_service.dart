// ===== lib/services/easy_update_service.dart =====
// VERSIÓN COMPLETA Y CORREGIDA

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sabipay/constant/sp_colors.dart';

class EasyUpdateService extends GetxService {
  static EasyUpdateService get instance => Get.find<EasyUpdateService>();

  // 🎯 CONFIGURACIÓN SÚPER SIMPLE - SOLO CAMBIAR ESTOS 3 VALORES:
  static const String NUEVA_VERSION =
      '1.4.0'; // ← CAMBIAR cuando subas nueva versión
  static const String GOOGLE_DRIVE_ID =
      '1AGgB08i9Vz5URibFXEcZY0oxb7OUtP6D'; // ← Tu ID de Drive
  static const bool FORZAR_ACTUALIZACION =
      true; // ← true = obligatoria, false = opcional

  // 🔧 URL CONSTRUIDA AUTOMÁTICAMENTE - NO TOCAR
  static const String DRIVE_DOWNLOAD_URL =
      'https://drive.google.com/uc?export=download&id=$GOOGLE_DRIVE_ID';

  // Estados
  final downloading = false.obs;
  final progress = 0.0.obs;
  final currentVersion = '1.0.0'.obs;

  @override
  void onInit() {
    super.onInit();
    _setupVersion();
    _checkAfterDelay();
  }

  /// Configurar versión actual
  Future<void> _setupVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      currentVersion.value = info.version;
      print('📱 Versión actual: ${currentVersion.value}');
      print('🎯 Versión objetivo: $NUEVA_VERSION');
      print('🔗 URL de descarga: $DRIVE_DOWNLOAD_URL');
    } catch (e) {
      currentVersion.value = '1.0.0';
    }
  }

  /// Verificar actualización después de 3 segundos
  void _checkAfterDelay() {
    Future.delayed(Duration(seconds: 3), () {
      if (_needsUpdate()) {
        print('🔄 Actualización necesaria detectada');
        if (FORZAR_ACTUALIZACION) {
          _showForceDialog();
        } else {
          _showNotification();
        }
      } else {
        print('✅ App está actualizada');
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
      '🔄 Nueva Versión Disponible',
      'Versión $NUEVA_VERSION lista. ¡Toca para actualizar!',
      backgroundColor: spColorPrimary,
      colorText: Colors.white,
      duration: Duration(seconds: 6),
      onTap: (_) => showUpdateDialog(),
      margin: EdgeInsets.all(16),
      borderRadius: 12,
      icon: Icon(Icons.system_update, color: Colors.white),
    );
  }

  /// Diálogo forzado (no se puede cerrar)
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
              SizedBox(height: 8),
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

  /// Diálogo opcional (se puede cerrar)
  void showUpdateDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.system_update, color: spColorPrimary, size: 28),
            SizedBox(width: 8),
            Text('Actualización Disponible'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nueva versión: $NUEVA_VERSION'),
            Text('Actual: ${currentVersion.value}'),
            SizedBox(height: 16),

            // Opción 1: Automática ⭐ RECOMENDADA
            _buildOption(
              icon: Icons.download,
              title: 'Descarga Automática',
              subtitle: 'Descarga e instala (Recomendado)',
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
              title: 'Abrir Google Drive',
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
          color: color.withOpacity(isRecommended ? 0.1 : 0.05),
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
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'RECOMENDADO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
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
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// ===== OPCIÓN 1: DESCARGA AUTOMÁTICA =====

  Future<void> downloadUpdate() async {
    if (!Platform.isAndroid) {
      openDriveLink();
      return;
    }

    downloading.value = true;
    progress.value = 0.0;

    try {
      print('🚀 Iniciando descarga automática...');

      // 1. Pedir permisos
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

      // 5. Instalar
      _showInstallDialog(filePath);
    } catch (e) {
      print('❌ Error en descarga automática: $e');
      Get.back(); // Cerrar progreso

      // Fallback automático a Drive
      Get.snackbar(
        '🔄 Alternativa Activada',
        'Abriendo Google Drive para descarga manual...',
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

  /// Descargar archivo APK
  Future<String> _downloadFile() async {
    final dir = await getExternalStorageDirectory();
    final fileName = 'SabiPay_v$NUEVA_VERSION.apk';
    final filePath = '${dir!.path}/$fileName';

    print('📥 Descargando desde: $DRIVE_DOWNLOAD_URL');
    print('📁 Guardando en: $filePath');

    await Dio().download(
      DRIVE_DOWNLOAD_URL,
      filePath,
      options: Options(
        followRedirects: true,
        maxRedirects: 5,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Android) Mobile App Updater',
        },
      ),
      onReceiveProgress: (received, total) {
        if (total > 0) {
          progress.value = received / total;
          print('📊 Progreso: ${(progress.value * 100).toInt()}%');
        }
      },
    );

    print('✅ Descarga completada: $filePath');
    return filePath;
  }

  /// Diálogo de progreso simple
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
                  Text(
                    'Descargando... ${(progress.value * 100).toInt()}%',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No cierres la aplicación',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              )),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Diálogo de instalación
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
                    child: Text(
                      'Archivo guardado en Descargas',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
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
              _installApk(filePath);
            },
            icon: Icon(Icons.install_mobile),
            label: Text('Instalar Ahora'),
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

  /// ===== OPCIÓN 2: ENLACE DIRECTO =====

  Future<void> openDriveLink() async {
    try {
      final url = Uri.parse(DRIVE_DOWNLOAD_URL);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);

        Get.snackbar(
          '📱 Google Drive Abierto',
          'Descarga el APK e instálalo manualmente',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
          icon: Icon(Icons.cloud_download, color: Colors.white),
        );
      } else {
        throw Exception('No se puede abrir el enlace');
      }
    } catch (e) {
      print('❌ Error abriendo Drive: $e');
      _showError('No se pudo abrir Google Drive');
    }
  }

  /// ===== FUNCIONES DE APOYO =====

  /// Pedir permisos simples
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
      print('❌ Error solicitando permisos: $e');
      return false;
    }
  }

  /// Diálogo de permisos
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
              openDriveLink(); // Fallback a descarga manual
            },
            child: Text('Descarga Manual'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: Text('Dar Permisos'),
          ),
        ],
      ),
    );
  }

  /// Instalar APK
  Future<void> _installApk(String path) async {
    try {
      print('📱 Abriendo instalador para: $path');

      final uri = Uri.file(path);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        Get.snackbar(
          '📱 Instalador Abierto',
          'Sigue las instrucciones para completar la instalación',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          icon: Icon(Icons.install_mobile, color: Colors.white),
        );
      } else {
        throw Exception('No se puede abrir el instalador');
      }
    } catch (e) {
      print('❌ Error abriendo instalador: $e');
      _showError('Error abriendo el instalador');
    }
  }

  /// ===== WIDGETS PARA USO FÁCIL =====

  /// Widget para poner en configuraciones
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
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text('Versión actual: ${currentVersion.value}'),
                        if (needsUpdate)
                          Text(
                            'Nueva versión: $NUEVA_VERSION',
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (needsUpdate) ...[
                // Mostrar botones de actualización
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: downloading.value ? null : downloadUpdate,
                        icon: downloading.value
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : Icon(Icons.download),
                        label: Text(downloading.value
                            ? 'Descargando...'
                            : 'Actualizar Auto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: openDriveLink,
                      icon: Icon(Icons.link),
                      label: Text('Drive'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // App actualizada - botón para verificar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _setupVersion(); // Re-verificar
                      Get.snackbar(
                        '✅ Verificado',
                        'Tienes la versión más reciente',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Verificar Actualizaciones'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: spColorPrimary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  /// Widget flotante compacto
  Widget buildFloatingUpdateBanner() {
    return Obx(() {
      if (!_needsUpdate()) return SizedBox.shrink();

      return Container(
        margin: EdgeInsets.all(16),
        child: Material(
          borderRadius: BorderRadius.circular(12),
          elevation: 4,
          child: InkWell(
            onTap: showUpdateDialog,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [spColorPrimary, spColorPrimary.withOpacity(0.8)],
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.system_update, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nueva Versión $NUEVA_VERSION',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Toca para actualizar',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// ===== FUNCIONES AUXILIARES =====

  void _showError(String message) {
    Get.snackbar(
      '❌ Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  /// Abrir configuración de la app
  Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('❌ Error abriendo configuración: $e');
    }
  }
}

// ===== PARA AGREGAR AL main.dart =====
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🆕 AGREGAR ESTA LÍNEA:
  Get.put(EasyUpdateService());
  
  runApp(MyApp());
}
*/

// ===== PARA USAR EN sp_settings_screen.dart =====
/*
// En el body de SPSettingsScreen, agregar:

final EasyUpdateService updateService = EasyUpdateService.instance;

// Luego en el Column de children:
updateService.buildSettingsCard(),
*/
