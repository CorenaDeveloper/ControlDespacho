import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../model/countries.dart';

class SpMyAccountController extends GetxController {

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  FocusNode f3 = FocusNode();
  final formKey = GlobalKey<FormState>();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getCountryList();
    fullNameController.text='abc';
    phoneNumberController.text='9922111111';
    emailController.text='abc@gmail.com';
  }
  var errorTextMobile = ''.obs;
  RxList<SPCountries> listOfCountries = <SPCountries>[].obs;

  Future<List<SPCountries>> getCountryList() async {
    listOfCountries.clear();
    String jsonData = await rootBundle
        .loadString("assets/sabipay/data/country_list.json");
    dynamic data = json.decode(jsonData);
    List<dynamic> jsonArray = data['country_list'];

    for (int i = 0; i < jsonArray.length; i++) {
      listOfCountries.add(SPCountries.fromJson(jsonArray[i]));
    }
    return listOfCountries;
  }

  var selectedCountryCode =
      SPCountries(code: 'IN', name: 'India', dialCode: '+91').obs;

  var dropdownValue = ''.obs;

}
