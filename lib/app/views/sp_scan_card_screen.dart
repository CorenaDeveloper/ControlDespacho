import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sabipay/app/controller/sp_scan_card_controller.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/constant/sp_images.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:get/get.dart';

import '../../constant/sp_strings.dart';

class SPScanCardScreen extends StatefulWidget {
  const SPScanCardScreen({super.key});

  @override
  SPScanCardScreenState createState() => SPScanCardScreenState();
}

class SPScanCardScreenState extends State<SPScanCardScreen> {
  SPScanCardController controller = Get.put(SPScanCardController());
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    theme =
        Get.isDarkMode ? SPWalletTheme.spDarkTheme : SPWalletTheme.spLightTheme;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SPScanCardController>(
        init: controller,
        tag: 'sp_scan_card',
        // theme: theme,
        builder: (controller) {
          return Scaffold(
            appBar: _buildAppBar(),
            backgroundColor: spColorGrey900,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        scanAreaIcon1,
                        width: 275,
                        height: 420,
                      ),
                      Image.asset(
                        creditCardImage1,
                        width: 265,
                        height: 390,
                      ),
                    ],
                  ),
                  _buildBottomWidget(),
                ],
              ),
            ),
          );
        });
  }

  _buildBottomWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 15,right: 15,top: 30),
      child: Center(
        child: Text(
          placeYourCardRightTheBoxArea,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge
              ?.copyWith(fontWeight: FontWeight.w400, color: Colors.white),
        ),
      ),
    );
  }

  _buildAppBar() {
    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness:Brightness.light, // Change to Brightness.dark for dark icons
      ),
      centerTitle: true,
      title: Text(
        scanQRCode,
        style: theme.textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      backgroundColor: spColorGrey900,
      leading: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          width: 44,
          height: 44,
          margin: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: spColorGrey800,
            border: Border.all(color: spColorGrey700),
            boxShadow: [
              BoxShadow(
                spreadRadius: -4,
                color: spTextColor.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_sharp,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
