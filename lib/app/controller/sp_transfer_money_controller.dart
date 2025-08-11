import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sabipay/app/model/sp_bank.dart';
import 'package:sabipay/app/model/sp_user_data.dart';
import 'package:get/get.dart';

class SPTransferMoneyController extends GetxController {
  TextEditingController amountController = TextEditingController();


  List<String> catList = ['Sabipay',"Bank",'Favorites'];
  RxInt selectIndex = 0.obs;
  List<SPBank> bankList = <SPBank>[].obs;
  List<SPUserData> contactList = <SPUserData>[].obs;
  List<SPUserData> favoritesList = <SPUserData>[].obs;

  @override
  void onInit() {
    getList();
    super.onInit();
  }

  getList() async {
    contactList.clear();
    favoritesList.clear();
    bankList.clear();

    await Future.delayed(const Duration(seconds: 1));
    String jsonData = await rootBundle
        .loadString("assets/sabipay/data/quick_pay_list.json");
    dynamic data = json.decode(jsonData);
    List<dynamic> contactArray = data['contact_list'];
    for (int i = 0; i < contactArray.length; i++) {
      contactList.add(SPUserData.fromJson(contactArray[i]));
    }

    List<dynamic> favoriteArray = data['favorite_list'];
    for (int i = 0; i < favoriteArray.length; i++) {
      favoritesList.add(SPUserData.fromJson(favoriteArray[i]));
    }

    List<dynamic> bankArray = data['bank_list'];
    for (int i = 0; i < bankArray.length; i++) {
      bankList.add(SPBank.fromJson(bankArray[i]));
    }
  }
}
