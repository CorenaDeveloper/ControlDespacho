import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sabipay/app/controller/sp_settings_controller.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/constant/sp_images.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/sabipy_theme/theme_controller.dart';
import 'package:sabipay/widgets/sp_app_widget.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ AÑADIDO

import '../../../../route/my_route.dart';
import '../../constant/sp_strings.dart';
import '../../widgets/sp_common_button.dart';

class SpSettingsScreen extends StatefulWidget {
  const SpSettingsScreen({super.key});

  @override
  SpSettingsScreenState createState() => SpSettingsScreenState();
}

class SpSettingsScreenState extends State<SpSettingsScreen> {
  SPSettingsController controller = Get.put(SPSettingsController());
  late ThemeData theme;
  ThemeController themeController = Get.put(ThemeController());

  // URL del repositorio
  static const String REPOSITORY_URL =
      'https://drive.google.com/drive/folders/1AGgB08i9Vz5URibFXEcZY0oxb7OUtP6D';

  @override
  void initState() {
    super.initState();
    theme =
        Get.isDarkMode ? SPWalletTheme.spDarkTheme : SPWalletTheme.spLightTheme;
  }

  double horizontalPadding = 15.0;

  // para abrir repositorio
  Future<void> _openRepository() async {
    try {
      final url = Uri.parse(REPOSITORY_URL);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);

        Get.snackbar(
          '🌐 Navegador Abierto',
          'Se abrió el repositorio en tu navegador',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
          icon: Icon(Icons.open_in_browser, color: Colors.white),
        );
      } else {
        throw Exception('No se puede abrir el enlace');
      }
    } catch (e) {
      print('❌ Error abriendo repositorio: $e');
      Get.snackbar(
        '❌ Error',
        'No se pudo abrir el repositorio',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  // ✅ AÑADIDO: Widget del repositorio
  Widget _buildRepositoryCard() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
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
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.cloud_download,
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actualización Manual',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Descarga la última versión desde el repositorio',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openRepository,
              icon: Icon(Icons.open_in_browser, size: 18),
              label: Text('Ir a Repositorio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SPSettingsController>(
        init: controller,
        tag: 'sp_settings',
        // theme: theme,
        builder: (controller) {
          return Scaffold(
            backgroundColor: Get.isDarkMode ? spDarkPrimary : spColorLightBg,
            appBar: spCommonAppBarWidget(context, titleText: settings),
            body: SafeArea(
              child: SingleChildScrollView(
                // ✅ AÑADIDO: SingleChildScrollView
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Get.isDarkMode ? Colors.black : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ AÑADIDO: Widget del repositorio al inicio
                      _buildRepositoryCard(),

                      Text(
                        general,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Get.isDarkMode
                                ? spColorGrey400
                                : spColorGrey500),
                      ),
                      15.height,
                      _buildLanguageWidget(),
                      _buildContactUsWidget(),
                      15.height,
                      Text(
                        security,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Get.isDarkMode
                                ? spColorGrey400
                                : spColorGrey500),
                      ),
                      15.height,
                      _buildWalletPinWidget(),
                      _buildBiometricWidget(),
                      _buildPrivacyPolicyWidget(),
                      15.height,
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return _showLogoutDialog();
                            },
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: spColorError50,
                              borderRadius: BorderRadius.circular(40)),
                          child: Text(
                            logout,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: spColorError500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  _buildLanguageWidget() {
    return ListTile(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return _showLanguageDialog();
          },
        );
      },
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(10),
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: spColorGrey100),
        child: SvgPicture.asset(
          translateIcon,
          colorFilter: ColorFilter.mode(
              Get.isDarkMode ? spColorPrimary : spTextColor, BlendMode.srcIn),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            language,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w400),
          ),
          Obx(
            () => Text(
              controller.selectedLanguage.value,
              style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Get.isDarkMode ? spColorGrey400 : spColorGrey500),
            ),
          ),
        ],
      ),
      trailing: SvgPicture.asset(
        chevronRightIcon,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
            Get.isDarkMode ? Colors.white : spTextColor, BlendMode.srcIn),
      ),
    );
  }

  _buildContactUsWidget() {
    return ListTile(
      onTap: () {},
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(10),
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: spColorGrey100),
        child: SvgPicture.asset(
          callIncomingIcon,
          colorFilter: ColorFilter.mode(
              Get.isDarkMode ? spColorPrimary : spTextColor, BlendMode.srcIn),
        ),
      ),
      title: Text(
        contactus,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
      ),
      trailing: SvgPicture.asset(
        chevronRightIcon,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
            Get.isDarkMode ? Colors.white : spTextColor, BlendMode.srcIn),
      ),
    );
  }

  _buildWalletPinWidget() {
    return ListTile(
      onTap: () {},
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(10),
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: spColorGrey100),
        child: SvgPicture.asset(
          keyIcon,
          colorFilter: ColorFilter.mode(
              Get.isDarkMode ? spColorPrimary : spTextColor, BlendMode.srcIn),
        ),
      ),
      title: Text(
        changeWalletPin,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
      ),
      trailing: SvgPicture.asset(
        chevronRightIcon,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
            Get.isDarkMode ? Colors.white : spTextColor, BlendMode.srcIn),
      ),
    );
  }

  _buildBiometricWidget() {
    return ListTile(
      onTap: () {},
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(10),
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: spColorGrey100),
        child: SvgPicture.asset(
          fingerScanIcon,
          colorFilter: ColorFilter.mode(
              Get.isDarkMode ? spColorPrimary : spTextColor, BlendMode.srcIn),
        ),
      ),
      title: Text(
        biometric,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        enableFingerprintScanFaceID,
        style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w400,
            color: Get.isDarkMode ? spColorGrey400 : spColorGrey500),
      ),
      trailing: Transform.scale(
        alignment: Alignment.centerRight,
        scale: 0.9,
        // Adjust the scale factor to change the size
        child: Obx(
          () => CupertinoSwitch(
            thumbColor: Colors.white,
            activeColor: spColorPrimary,
            value: controller.isBiometricOn.value,
            onChanged: (value) {
              controller.isBiometricOn.value = !controller.isBiometricOn.value;
            },
          ),
        ),
      ),
    );
  }

  _buildPrivacyPolicyWidget() {
    return ListTile(
      onTap: () {},
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(10),
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: spColorGrey100),
        child: SvgPicture.asset(
          lockCloseIcon,
          colorFilter: ColorFilter.mode(
              Get.isDarkMode ? spColorPrimary : spTextColor, BlendMode.srcIn),
        ),
      ),
      title: Text(
        privacyPolicy,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
      ),
      trailing: SvgPicture.asset(
        chevronRightIcon,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
            Get.isDarkMode ? Colors.white : spTextColor, BlendMode.srcIn),
      ),
    );
  }

  _showLogoutDialog() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          5.height,
          Text(logout,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          15.height,
          Divider(
            color: spBorderColor.withOpacity(0.50),
            height: 1,
            thickness: 1,
          ),
          15.height,
          Text('Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Get.isDarkMode ? Colors.white : spTextColor)),
          20.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: SPCommonButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                text: cancel,
                height: 44,
                borderColor: spBorderColor,
                bgColor: Colors.transparent,
                textColor: Get.isDarkMode ? whiteColor : spColorPrimary,
              )),
              15.width,
              Expanded(
                  child: SPCommonButton(
                      onPressed: () {
                        Get.offNamedUntil(
                            MyRoute.spLogin, (route) => route.isFirst);
                      },
                      text: 'Yes Logout',
                      height: 44)),
            ],
          ),
          if (GetPlatform.isIOS) 20.height,
        ],
      ),
    );
  }

  _showLanguageDialog() {
    return Dialog(
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            5.height,
            Text(language,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
            15.height,
            Divider(
              color: spBorderColor.withOpacity(0.50),
              height: 1,
              thickness: 1,
            ),
            15.height,
            Flexible(
              child: Obx(
                () => ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  // physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.listOfLanguages.length,
                  itemBuilder: (context, index) {
                    final language = controller.listOfLanguages[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Text(
                        language,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      trailing: SizedBox(
                        height: 30,
                        width: 30,
                        child: Obx(
                          () => Radio(
                            activeColor: spColorPrimary,
                            value: language,
                            groupValue: controller.selectedLanguage.value,
                            onChanged: (value) {
                              controller.setSelectedLanguage(value!);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
