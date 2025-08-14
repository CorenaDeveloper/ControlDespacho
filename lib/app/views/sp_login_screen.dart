import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/constant/sp_images.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/widgets/sp_app_widget.dart';
import 'package:sabipay/widgets/sp_common_button.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../controller/sp_login_controller.dart';

class SPLoginScreen extends StatefulWidget {
  const SPLoginScreen({super.key});

  @override
  SPLoginScreenState createState() => SPLoginScreenState();
}

class SPLoginScreenState extends State<SPLoginScreen> {
  SPLoginController controller = Get.put(SPLoginController());
  late ThemeData theme;

  //Modificar siempre que se actualice la version al usuario
  String appVersion = '1.0.2';

  @override
  void initState() {
    super.initState();
    theme =
        Get.isDarkMode ? SPWalletTheme.spDarkTheme : SPWalletTheme.spLightTheme;
    _getAppVersion();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SPLoginController>(
        init: controller,
        tag: 'sp_login',
        builder: (controller) {
          return Scaffold(
            backgroundColor: Get.isDarkMode ? spDarkPrimary : spColorLightBg,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      30.height,
                      // Logo y título
                      Center(
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              logoImg,
                              height: 30,
                              width: 30,
                            ),
                            10.height,
                            Text(
                              'DispatchOK',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w200,
                                color: spColorPrimary,
                              ),
                            ),
                            10.height,
                            Text(
                              'Ingresa tu codigo de empleado y contraseña',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w100,
                                color: Get.isDarkMode
                                    ? spColorGrey400
                                    : spColorGrey500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      15.height,

                      // Campo Usuario
                      Text.rich(
                        TextSpan(
                          text: 'Usuario',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Get.isDarkMode
                                ? spColorGrey400
                                : spColorGrey500,
                          ),
                          children: [
                            TextSpan(
                              text: ' *',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: spColorError500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      8.height,
                      Obx(
                        () => TextFormField(
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Get.isDarkMode ? whiteColor : spTextColor,
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          focusNode: controller.f1,
                          onChanged: (_) {
                            controller.usernameFieldFocused.value = true;
                            controller.passwordFieldFocused.value = false;
                          },
                          autovalidateMode:
                              controller.usernameFieldFocused.value
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu usuario';
                            }
                            return null;
                          },
                          onFieldSubmitted: (v) {
                            controller.f1.unfocus();
                            FocusScope.of(context).requestFocus(controller.f2);
                          },
                          controller: controller.usernameController,
                          decoration: spInputDecoration(
                            context,
                            prefixIconColor: Get.isDarkMode
                                ? spColorGrey400
                                : spColorGrey500,
                            prefixIcon: userIcon,
                            borderColor: Get.isDarkMode
                                ? spColorGrey400
                                : spColorGrey200,
                            fillColor: Colors.transparent,
                            hintColor: spColorGrey400,
                            hintText: 'Ingresa tu usuario',
                          ),
                        ),
                      ),
                      15.height,

                      // Campo Contraseña
                      Text.rich(
                        TextSpan(
                          text: 'Contraseña',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Get.isDarkMode
                                ? spColorGrey400
                                : spColorGrey500,
                          ),
                          children: [
                            TextSpan(
                              text: ' *',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: spColorError500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      8.height,
                      Obx(
                        () => TextFormField(
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Get.isDarkMode ? whiteColor : spTextColor,
                          ),
                          textInputAction: TextInputAction.done,
                          obscureText:
                              controller.isShowCurrentPasswordIcon.value,
                          keyboardType: TextInputType.text,
                          focusNode: controller.f2,
                          onChanged: (_) {
                            controller.usernameFieldFocused.value = false;
                            controller.passwordFieldFocused.value = true;
                          },
                          autovalidateMode:
                              controller.passwordFieldFocused.value
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu contraseña';
                            }
                            if (value.length < 4) {
                              return 'La contraseña debe tener al menos 4 caracteres';
                            }
                            return null;
                          },
                          onFieldSubmitted: (v) {
                            controller.f2.unfocus();
                            controller.attemptLogin();
                          },
                          controller: controller.passwordController,
                          decoration: spInputDecoration(
                            context,
                            onSuffixPressed: () {
                              controller.isShowCurrentPasswordIcon.value =
                                  !controller.isShowCurrentPasswordIcon.value;
                            },
                            suffixIcon:
                                (controller.isShowCurrentPasswordIcon.value)
                                    ? eyeSplashIcon
                                    : eyeIcon,
                            prefixIcon: lockIcon,
                            prefixIconColor: Get.isDarkMode
                                ? spColorGrey400
                                : spColorGrey500,
                            borderColor: Get.isDarkMode
                                ? spColorGrey400
                                : spColorGrey200,
                            fillColor: Colors.transparent,
                            hintColor: spColorGrey400,
                            hintText: 'Ingresa tu contraseña',
                          ),
                        ),
                      ),

                      20.height,

                      // Botón de Login
                      Obx(() => SPCommonButton(
                            height: 48,
                            textStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: spColorGrey900,
                              fontWeight: FontWeight.w600,
                            ),
                            bgColor: controller.isLoading.value
                                ? spColorGrey300
                                : spColorPrimary300,
                            onPressed: controller.isLoading.value
                                ? () {}
                                : () => controller.attemptLogin(),
                            text: controller.isLoading.value
                                ? 'Iniciando sesión...'
                                : 'Iniciar Sesión',
                          )),

                      30.height,

                      Center(
                        child: Text(
                          'Versión $appVersion',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Get.isDarkMode
                                ? spColorGrey400
                                : spColorGrey500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // Mostrar diálogo o ir a pantalla de recuperación
                            _showForgotPasswordDialog();
                          },
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: spColorPrimary,
                              decoration: TextDecoration.underline,
                              decorationColor: spColorPrimary,
                            ),
                          ),
                        ),
                      ),

                      60.height,
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<void> _getAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        appVersion = info.version;
      });
    } catch (e) {
      setState(() {
        appVersion = '1.0.Dev';
      });
    }
  }

  void _showForgotPasswordDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.isDarkMode ? spCardDark : Colors.white,
        title: Text(
          'Recuperar Contraseña',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Contacta al administrador del sistema para recuperar tu contraseña.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Entendido',
              style: TextStyle(color: spColorPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
