import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sabipay/route/my_route.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/sabipy_theme/theme_controller.dart';
import 'package:sabipay/services/api_service.dart';
import 'package:sabipay/services/app_update_service.dart';
import 'package:sabipay/services/auth_services.dart';
import 'package:sabipay/services/route_service.dart';
import 'package:sabipay/services/api_despacho.dart';
import 'package:sabipay/services/scan_services.dart';
import 'package:sabipay/app/controller/sp_history_despacho_controller.dart'; // Agregar import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(BarcodeScannerService(), permanent: true);
  Get.put(AppUpdateService());
  ;
  // Registrar servicios en el orden correcto
  await Get.putAsync<ApiService>(() async => ApiService(), permanent: true);
  await Get.putAsync<AuthService>(() async => AuthService(), permanent: true);
  await Get.putAsync<RouteService>(() async => RouteService(), permanent: true);

  //Acceso para las api de inciar session en despacho
  await Get.putAsync<DespachoService>(() async => DespachoService(),
      permanent: true);

  // Agregar SPHistoryController
  Get.lazyPut(() => SPHistoryController());

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final ThemeController controller = Get.put(ThemeController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Get.isDarkMode ? Brightness.light : Brightness.dark,
      statusBarIconBrightness:
          Get.isDarkMode ? Brightness.light : Brightness.dark,
    ));
    return Obx(
      () {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: controller.isDarkMode
              ? SPWalletTheme.spDarkTheme
              : SPWalletTheme.spLightTheme,
          getPages: MyRoute.routes,
          initialRoute: MyRoute.spSplash,
          // home: BottomNavBar(),
        );
      },
      // ),
    );
  }
}
