import 'package:sabipay/sabipy_theme/theme_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sabipay/route/my_route.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:flutter/material.dart';

class SpProfileController extends GetxController {
  ThemeController themeController = Get.put(ThemeController());
  RxBool isDarkMode = false.obs;
  final GetStorage box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = themeController.isDarkMode;
  }

  /// Cerrar sesión y limpiar datos del usuario
  Future<void> logout() async {
    try {
      // Mostrar indicador de carga más pequeño
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            width: 140,
            height: 100,
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: spColorPrimary,
                    strokeWidth: 2.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Cerrando...',
                  style: TextStyle(
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
        barrierColor: const Color.fromARGB(77, 0, 0, 0),
      );

      // Simular un pequeño delay para mostrar el loading
      await Future.delayed(const Duration(milliseconds: 1500));
      // Limpiar todos los datos del usuario del storage
      await _clearUserData();
      // Cerrar el dialog de loading
      Get.back();
      // Redirigir al login y limpiar toda la pila de navegación
      Get.offNamedUntil(MyRoute.spLogin, (route) => false);
    } catch (e) {
      // Cerrar el dialog de loading si hay error
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Mostrar mensaje de error
      _showErrorMessage('Error al cerrar sesión: $e');
    }
  }

  /// Limpiar todos los datos del usuario
  Future<void> _clearUserData() async {
    try {
      // Lista de keys que queremos limpiar
      List<String> keysToRemove = [
        'user_name',
        'user_code',
        'user_token', // Si tienes token
        'user_email', // Si guardas email
        'last_login', // Si guardas fecha de último login
        'user_preferences', // Si guardas preferencias del usuario
      ];

      // Remover cada key individualmente
      for (String key in keysToRemove) {
        if (box.hasData(key)) {
          await box.remove(key);
        }
      }
    } catch (e) {
      throw e;
    }
  }

  /// Mostrar mensaje de error
  void _showErrorMessage(String message) {
    Get.snackbar(
      '❌ Error',
      message,
      backgroundColor: spColorError500,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Verificar si el usuario está logueado
  bool get isUserLoggedIn {
    return box.hasData('user_name') && box.hasData('user_code');
  }

  /// Obtener nombre del usuario
  String get userName {
    return box.read('user_name') ?? 'Usuario';
  }

  /// Obtener código del usuario
  String get userCode {
    return box.read('user_code') ?? '';
  }
}
