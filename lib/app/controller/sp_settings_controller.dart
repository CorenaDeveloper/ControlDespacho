import 'package:get/get.dart';

class SPSettingsController extends GetxController {

  RxBool isBiometricOn = true.obs;
  RxString selectedLanguage ='English (US)'.obs;

  void setSelectedLanguage(String language) {
    selectedLanguage.value = language;
  }

  final RxList<String> listOfLanguages = [
    "English (US)",
    "English (UK)",
    "Mandarin",
    "Hindi",
    "Spanish",
    "French",
    "Arabic",
    "Bengali",
    "Russian",
    "Indonesia",
  ].obs;
}
