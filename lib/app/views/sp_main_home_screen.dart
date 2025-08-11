import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sabipay/app/views/sp_home_screen.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:get/get.dart';
import 'package:sabipay/sabipy_theme/theme_controller.dart';

class SpMainHomeScreen extends StatefulWidget {
  const SpMainHomeScreen({super.key});

  @override
  SpMainHomeScreenState createState() => SpMainHomeScreenState();
}

class SpMainHomeScreenState extends State<SpMainHomeScreen> {
  final ThemeController themeController = Get.put(ThemeController());
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    theme = themeController.isDarkMode
        ? SPWalletTheme.spDarkTheme
        : SPWalletTheme.spLightTheme;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            themeController.isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness:
            themeController.isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor:
            themeController.isDarkMode ? spDarkPrimary : Colors.white,
        body: const SPHomeScreen(), // Solo mostrar el home
      ),
    );
  }
}
