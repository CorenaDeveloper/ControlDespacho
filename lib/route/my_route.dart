import 'package:get/get.dart';
import 'package:sabipay/app/views/sp_add_new_card_screen.dart';
//import 'package:sabipay/app/views/sp_biometric_scan_screen.dart';
//import 'package:sabipay/app/views/sp_biometric_setup_screen.dart';
//import 'package:sabipay/app/views/sp_forgot_password_screen.dart';
import 'package:sabipay/app/views/sp_login_screen.dart';
import 'package:sabipay/app/views/sp_main_home_screen.dart';
import 'package:sabipay/app/views/sp_my_account_screen.dart';
//import 'package:sabipay/app/views/sp_new_password_screen.dart';
//import 'package:sabipay/app/views/sp_notification_screen.dart';
//import 'package:sabipay/app/views/sp_onboarding_screen.dart';
//import 'package:sabipay/app/views/sp_otp_verify_screen.dart';
//import 'package:sabipay/app/views/sp_register_screen.dart';
import 'package:sabipay/app/views/sp_scan_card_screen.dart';
//import 'package:sabipay/app/views/sp_scan_me_screen.dart';
//import 'package:sabipay/app/views/sp_select_bank_screen.dart';
import 'package:sabipay/app/views/sp_settings_screen.dart';
import 'package:sabipay/app/views/sp_splash_screen.dart';
//import 'package:sabipay/app/views/sp_top_up_via_bank_screen.dart';
import 'package:sabipay/app/views/sp_scan_barcode_screen.dart';
import 'package:sabipay/app/views/sp_history_despacho_screen.dart';
import 'package:sabipay/app/views/sp_despacho_detalle_screen.dart';
import 'package:sabipay/app/views/sp_profile_screen.dart';
import 'package:sabipay/app/views/sp_consolidados_screen.dart';
import 'package:sabipay/app/views/sp_consolidado_detalle_screen.dart';

class MyRoute {
  /*------------------------------ EZWallet App -------------------------------------------*/

  static const spSplash = '/sp_splash_screen';
  static const spOnboarding = '/sp_onboarding_screen';
  static const spLogin = '/sp_login_screen';
  static const spForgotPassword = '/sp_forgot_password_screen';
  static const spOtpVerify = '/sp_otp_verify_screen';
  static const spNewPassword = '/sp_new_password_screen';
  static const spRegister = '/sp_register_screen';
  static const spBiometric = '/sp_biometric_screen';
  static const spBiometricScan = '/sp_biometric_scan_screen';
  static const spMainHomeScreen = '/sp_main_home_screen';
  static const spTopUpViaBankScreen = '/sp_top_up_via_bank_screen';
  static const spSelectBankScreen = '/sp_select_bank_screen';
  static const spNotificationScreen = '/sp_notification_screen';
  static const spScanMeScreen = '/sp_scan_me_screen';
  static const spScanQRCodeScreen = '/sp_scan_qr_code_screen';
  static const spAddNewCardScreen = '/sp_add_new_card_screen';
  static const spScanCardScreen = '/sp_scan_card_screen';
  static const spMyAccountScreen = '/sp_my_account_screen';
  static const spSettingsScreen = '/sp_settings_screen';
  static const spScanBarcodeScreen = '/sp_scan_barcode_screen';
  static const spPHistoryScreen = '/sp_history_despacho_screen';
  static const spDespachoDetalle = '/sp_despacho_detalle_screen';
  static const sPProfileScreen = '/sp_profile_screen';
  static const spConsolidadoScreen = '/sp_consolidados_screen';
  static const spConsolidadoDetalleScreen = '/sp_consolidado_detalle_screen';

  /*-----------------------------------------------------------------------------------*/
  static final routes = [
    /*------------------------------ EZWallet App -------------------------------------------*/

    GetPage(name: spSplash, page: () => const SPSplashScreen()),
    //GetPage(name: spOnboarding, page: () => const SPOnboardingScreen()),
    GetPage(name: spLogin, page: () => const SPLoginScreen()),
    //GetPage(name: spForgotPassword, page: () => const SPForgotPasswordScreen()),
    //GetPage(name: spOtpVerify, page: () => const SPOTPVerifyScreen()),
    //GetPage(name: spNewPassword, page: () => const SPNewPasswordScreen()),
    //GetPage(name: spRegister, page: () => const SPRegisterScreen()),
    //GetPage(name: spBiometric, page: () => const SPBiometricScreen()),
    //GetPage(name: spBiometricScan, page: () => const SPBiometricScanScreen()),
    GetPage(name: spMainHomeScreen, page: () => const SpMainHomeScreen()),
    //GetPage(name: spTopUpViaBankScreen, page: () => const SPTopUpViaBankScreen()),
    //GetPage(name: spSelectBankScreen, page: () => const SPSelectBankScreen()),
    //GetPage(name: spNotificationScreen, page: () => const SPNotificationScreen()),
    //GetPage(name: spScanMeScreen, page: () => const SPScanMeScreen()),
    GetPage(name: spScanBarcodeScreen, page: () => const SPScanBarcodeScreen()),
    GetPage(
        name: spConsolidadoScreen, page: () => const SPConsolidadosScreen()),
    GetPage(name: spAddNewCardScreen, page: () => const SpAddNewCardScreen()),
    GetPage(
        name: spConsolidadoDetalleScreen,
        page: () => SPConsolidadoDetalleScreen()),
    GetPage(name: spScanCardScreen, page: () => const SPScanCardScreen()),
    GetPage(name: spMyAccountScreen, page: () => const SPMyAccountScreen()),
    GetPage(name: spSettingsScreen, page: () => const SpSettingsScreen()),
    GetPage(name: spPHistoryScreen, page: () => const SPHistoryScreen()),
    GetPage(
        name: spDespachoDetalle, page: () => const SPDespachoDetalleScreen()),
    GetPage(name: sPProfileScreen, page: () => const SPProfileScreen()),

    /*-----------------------------------------------------------------------------------*/
  ];
}
