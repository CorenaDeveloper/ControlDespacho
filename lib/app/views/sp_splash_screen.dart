import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sabipay/app/controller/sp_splash_controller.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/sp_images.dart';
import '../../constant/sp_strings.dart';

class SPSplashScreen extends StatefulWidget {
  const SPSplashScreen({super.key});

  @override
  SPSplashScreenState createState() => SPSplashScreenState();
}

class SPSplashScreenState extends State<SPSplashScreen> {
  SPSplashController controller = Get.put(SPSplashController());
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    theme =
        Get.isDarkMode ? SPWalletTheme.spDarkTheme : SPWalletTheme.spLightTheme;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SPSplashController>(
        init: controller,
        tag: 'sp_splash',
        // theme: theme,
        builder: (controller) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(logoImg, height: 41, width: 58).center(),
                  10.width,
                  Text(
                    appName,
                    style: theme.textTheme.displaySmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  )
                ],
              ),
            ),
          );
        });
  }
}
