import 'package:get/get.dart';

import '../../../../route/my_route.dart';

class SPSplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    init();
  }

  void init() async {
    await Future.delayed(const Duration(seconds: 2));
    initialization();
  }

  void initialization() async {
    goToLoginScreen();
  }

  void goToLoginScreen() {
    // Ir directamente al login, eliminando onboarding
    Get.offNamed(MyRoute.spLogin);
  }
}
