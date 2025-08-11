import 'package:flutter/material.dart';
import 'package:sabipay/app/controller/sp_scan_me_controller.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/widgets/sp_app_widget.dart';
import 'package:sabipay/widgets/sp_common_button.dart';
import 'package:sabipay/route/my_route.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/sp_strings.dart';

class SPScanMeScreen extends StatefulWidget {
  const SPScanMeScreen({super.key});

  @override
  SPScanMeScreenState createState() => SPScanMeScreenState();
}

class SPScanMeScreenState extends State<SPScanMeScreen> {
  SPScanMeController controller = Get.put(SPScanMeController());
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    theme =
        Get.isDarkMode ? SPWalletTheme.spDarkTheme : SPWalletTheme.spLightTheme;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SPScanMeController>(
        init: controller,
        tag: 'sp_scan_me',
        // theme: theme,
        builder: (controller) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 10.0, bottom: 20.0),
              child: SPCommonButton(
                onPressed: () {
                  Get.toNamed(MyRoute.spScanQRCodeScreen);
                },
                text: scanQRCode,
              ),
            ),
            appBar: _buildAppBar(),
            backgroundColor: Get.isDarkMode ? spDarkPrimary : spColorLightBg,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        color: Get.isDarkMode ? spDarkPrimary : Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipOval(
                        child: spCommonCacheImageWidget(
                            'https://i.ibb.co/kKsF5hS/Photo.png', 48,
                            width: 48),
                      ),
                      title: Text(
                        'Leslie Alexander',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Sbpy - 0324 01278 0938 9822',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Get.isDarkMode
                                ? spColorGrey400
                                : spColorGrey500),
                      ),
                    ),
                  ),
                  20.height,
                  Center(
                    child: spCommonCacheImageWidget(
                      'https://i.ibb.co/2PN0mTX/QR-Area.png',
                      300,
                      fit: BoxFit.contain
                    ),
                  ),
                  20.height,
                  Center(
                    child: Text(
                      scanQRCodeReceivingTransaction,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  40.height,
                ],
              ),
            ),
          );
        });
  }

  _buildAppBar() {
    return spCommonAppBarWidget(
      context,
      titleText: scanMe,
    );
  }
}
