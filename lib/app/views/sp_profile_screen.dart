import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sabipay/app/controller/sp_profile_controller.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/constant/sp_images.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/sabipy_theme/theme_controller.dart';
import 'package:sabipay/widgets/sp_app_widget.dart';
import 'package:sabipay/widgets/sp_common_button.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../route/my_route.dart';
import '../../constant/sp_strings.dart';

class SPProfileScreen extends StatefulWidget {
  const SPProfileScreen({super.key});

  @override
  SPProfileScreenState createState() => SPProfileScreenState();
}

class SPProfileScreenState extends State<SPProfileScreen> {
  SpProfileController controller = Get.put(SpProfileController());
  late ThemeData theme;
  final box = GetStorage();
  ThemeController themeController = Get.put(ThemeController());

  @override
  void initState() {
    super.initState();
    theme = themeController.isDarkMode
        ? SPWalletTheme.spDarkTheme
        : SPWalletTheme.spLightTheme;
  }

  double horizontalPadding = 15.0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SpProfileController>(
        init: controller,
        tag: 'sp_profile',
        // theme: theme,
        builder: (controller) {
          return Scaffold(
            backgroundColor:
                themeController.isDarkMode ? spDarkPrimary : spColorLightBg,
            appBar: _buildAppBar(),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildProfileWidget(),
                    20.height,
                    _darkModeWidgets(),
                    20.height,
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
                    130.height,
                  ],
                ),
              ),
            ),
          );
        });
  }

  _showLogoutDialog() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          5.height,

          // Título del modal
          Text(
            'Cerrar Sesión',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: themeController.isDarkMode ? Colors.white : spTextColor,
            ),
          ),

          15.height,

          // Divider
          Divider(
            color: spBorderColor.withOpacity(0.50),
            height: 1,
            thickness: 1,
          ),

          15.height,

          // Icono de advertencia
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: spColorError50,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.logout_rounded,
                size: 30,
                color: spColorError500,
              ),
            ),
          ),

          15.height,

          // Mensaje de confirmación
          Text(
            '¿Está seguro que desea cerrar la sesión de su perfil?',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: themeController.isDarkMode ? Colors.white : spTextColor,
            ),
          ),

          10.height,

          // Submensaje
          Text(
            'Deberá iniciar sesión nuevamente.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color:
                  themeController.isDarkMode ? spColorGrey400 : spColorGrey500,
            ),
          ),

          25.height,

          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón Cancelar
              Expanded(
                child: SPCommonButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: 'Cancelar',
                  height: 44,
                  borderColor: themeController.isDarkMode
                      ? spColorGrey400
                      : spBorderColor,
                  bgColor: Colors.transparent,
                  textColor: themeController.isDarkMode
                      ? Colors.white
                      : spColorGrey700,
                ),
              ),

              15.width,

              // Botón Cerrar Sesión
              Expanded(
                child: SPCommonButton(
                  onPressed: () async {
                    // Cerrar el modal primero
                    Navigator.pop(context);

                    // Ejecutar logout desde el controller
                    await controller.logout();
                  },
                  text: 'Cerrar Sesión',
                  height: 44,
                  bgColor: spColorError500,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),

          // Espaciado extra para iOS
          if (GetPlatform.isIOS) 20.height,
        ],
      ),
    );
  }

  _buildProfileWidget() {
    return Container(
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: spColorPrimary900.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  themeController.isDarkMode ? spColorGrey700 : spColorGrey200,
            ),
            child: Icon(
              Icons.person,
              size: 24,
              color: themeController.isDarkMode ? Colors.white : spTextColor,
            ),
          ),
          10.width,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.userName, // Usar getter del controller
                  style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: themeController.isDarkMode
                          ? Colors.white
                          : spTextColor),
                ),
                2.height,
                Text(
                  controller.userCode, // Usar getter del controller
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: themeController.isDarkMode
                          ? spColorGrey400
                          : spColorGrey500),
                ),
                2.height,
                Container(
                  decoration: BoxDecoration(
                    color: controller.isUserLoggedIn
                        ? spColorSuccess50
                        : spColorError50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Text(
                    controller.isUserLoggedIn ? 'Verificado' : 'No Verificado',
                    style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: controller.isUserLoggedIn
                            ? spColorSuccess700
                            : spColorError500),
                  ),
                ),
              ],
            ),
          ),
          10.width,
          InkWell(
            onTap: () {},
            child: Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    themeController.isDarkMode ? spDarkPrimary : Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: -4,
                    color: spTextColor.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                qrCodeIcon,
                height: 12,
                width: 12,
                colorFilter: ColorFilter.mode(
                    themeController.isDarkMode ? Colors.white : spTextColor,
                    BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _darkModeWidgets() {
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
          darkModeIcon,
          colorFilter: ColorFilter.mode(
              themeController.isDarkMode ? spColorPrimary : spTextColor,
              BlendMode.srcIn),
        ),
      ),
      title: Text(
        darkMode,
        style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w400,
            color: themeController.isDarkMode ? Colors.white : spTextColor),
      ),
      trailing: Transform.scale(
        scale: 0.9,
        // Adjust the scale factor to change the size
        child: CupertinoSwitch(
          thumbColor: Colors.white,
          activeColor: spColorPrimary,
          value: controller.isDarkMode.value,
          onChanged: (value) {
            controller.isDarkMode.value = value;
            controller.themeController.toggleTheme();
            Get.forceAppUpdate();
          },
        ),
      ),
    );
  }

  // Reemplaza tu método _buildAppBar() actual con este:
  _buildAppBar() {
    return AppBar(
      backgroundColor:
          themeController.isDarkMode ? spDarkPrimary : spColorLightBg,
      elevation: 0,
      leadingWidth: 70, // Dar espacio suficiente para el botón
      centerTitle: false,

      title: Padding(
        padding: const EdgeInsets.only(left: 10), // Ajustar si es necesario
        child: Text(
          'Regresar a Inicio',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: themeController.isDarkMode ? Colors.white : spTextColor,
          ),
        ),
      ),

      leading: Center(
        child: InkWell(
          onTap: () {
            // Navegar al inicio en lugar de hacer pop
            Get.offNamedUntil(
                MyRoute.spMainHomeScreen, (route) => route.isFirst);
          },
          child: Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeController.isDarkMode ? spDarkPrimary : Colors.white,
              boxShadow: [
                BoxShadow(
                  spreadRadius: -4,
                  color: spTextColor.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_sharp,
              size: 18,
              color: themeController.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),

      actions: [
        InkWell(
          onTap: () {
            Get.toNamed(MyRoute.spNotificationScreen);
          },
          child: Container(
            width: 44,
            margin: const EdgeInsets.only(right: 20),
            height: 44,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeController.isDarkMode ? spDarkPrimary : Colors.white,
              boxShadow: [
                BoxShadow(
                  spreadRadius: -4,
                  color: spTextColor.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SvgPicture.asset(
              notificationIcon,
              height: 12,
              width: 12,
              colorFilter: ColorFilter.mode(
                  themeController.isDarkMode ? Colors.white : spTextColor,
                  BlendMode.srcIn),
            ),
          ),
        )
      ],
    );
  }
}
