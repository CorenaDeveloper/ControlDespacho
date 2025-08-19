import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sabipay/services/auth_services.dart';
import 'package:sabipay/route/my_route.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:get_storage/get_storage.dart';

class SPLoginController extends GetxController {
  final usernameFieldFocused = false.obs;
  final passwordFieldFocused = false.obs;
  final isLoading = false.obs;

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  final formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  RxBool isShowCurrentPasswordIcon = true.obs;

  // Servicio de autenticación
  final AuthService _authService = AuthService.instance;

  @override
  void onInit() {
    super.onInit();
    // Valores por defecto para testing (opcional)
    usernameController.text = '4259';
    passwordController.text = 'Hola*2025';
  }

  /// Realizar login con API
  Future<void> attemptLogin() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final username = usernameController.text.trim();
      final password = passwordController.text.trim();
      final response = await _authService.login(
        username: username,
        password: password,
      );

      if (response.isSuccess) {
        await _saveUserData(response.data);
        Get.offNamed(MyRoute.spMainHomeScreen);
      } else {
        // Login fallido
        print('❌ Login fallido: ${response.message}');
        _showErrorMessage(response.message);
      }
    } catch (e) {
      print('❌ Error inesperado en login: $e');
      _showErrorMessage('Error inesperado: $e');
    } finally {
      isLoading.value = false;
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
    );
  }

  Future<void> _saveUserData(Map<String, dynamic>? userData) async {
    if (userData != null) {
      final box = GetStorage();

      final dataList = userData['data'];
      if (dataList is List && dataList.isNotEmpty) {
        final userInfo = dataList.first;
        final name = userInfo['namE_EMPLOYEE'] ?? 'Usuario';
        final code = userInfo['useR_CODE'] ?? 'Usuario';
        await box.write('user_name', name);
        await box.write('user_code', code);
      } else {
        print(
            '⚠️ No se encontró información de usuario válida en la respuesta');
      }
    }
  }

  @override
  void onClose() {
    f1.dispose();
    f2.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
