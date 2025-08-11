import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sabipay/app/model/payment_type.dart';
import 'package:sabipay/app/model/sp_transaction_history.dart';
import 'package:sabipay/app/model/sp_user_data.dart';
import 'package:sabipay/constant/sp_images.dart';
import 'package:get/get.dart';

import '../model/sp_credit_card.dart';

class SPHomeController extends GetxController {

  RxDouble topUpBalance = 5886.32.obs;
   Rx<TextEditingController> amountController = TextEditingController().obs;
  static Rx<TextEditingController> bankAmountController = TextEditingController().obs;

  List<PaymentType> paymentTypeList = <PaymentType>[].obs;
  List<SPUserData> contactList = <SPUserData>[].obs;
  List<SPTransactionHistory> transactionHistoryList =
      <SPTransactionHistory>[].obs;

  @override
  void onInit() {
    getPaymentTypeList();
    getContactList();
    super.onInit();
  }


  Future<List<PaymentType>> getPaymentTypeList() async {
    // paymentTypeList.clear();
    // await Future.delayed(const Duration(seconds: 1));
    String jsonData = await rootBundle
        .loadString("assets/sabipay/data/payment_type_list.json");
    dynamic data = json.decode(jsonData);
    List<dynamic> jsonArray = data['payment_type_list'];
    for (int i = 0; i < jsonArray.length; i++) {
      paymentTypeList.add(PaymentType.fromJson(jsonArray[i]));
    }

    paymentTypeList.add(PaymentType(name: 'More', icon: moreIcon, id: 999));
    return paymentTypeList;
  }

  Future<List<SPUserData>> getContactList() async {
    contactList.clear();
    // await Future.delayed(const Duration(seconds: 1));
    String jsonData = await rootBundle
        .loadString("assets/sabipay/data/contact_list.json");
    dynamic data = json.decode(jsonData);
    List<dynamic> jsonArray = data['contact_list'];
    for (int i = 0; i < jsonArray.length; i++) {
      contactList.add(SPUserData.fromJson(jsonArray[i]));
    }
    return contactList;
  }

  Future<List<SPTransactionHistory>> getTransactionHistoryList() async {
    transactionHistoryList.clear();
    await Future.delayed(const Duration(seconds: 1));
    String jsonData = await rootBundle.loadString(
        "assets/sabipay/data/transaction_history_list.json");
    dynamic data = json.decode(jsonData);
    List<dynamic> jsonArray = data['transaction_history_list'];
    for (int i = 0; i < jsonArray.length; i++) {
      transactionHistoryList.add(SPTransactionHistory.fromJson(jsonArray[i]));
    }
    return transactionHistoryList;
  }

  RxInt selectedCreditCardIndex = 0.obs;
  RxList<SPCreditCard> creditCardList = <SPCreditCard>[].obs;

  getCreditCardList() {
    creditCardList.clear();
    creditCardList.add(SPCreditCard(
        iconName: masterCardIcon,
        cardName: 'MasterCard',
        cardNumber: '•••• •••• ••••6621'));
    creditCardList.add(SPCreditCard(
        iconName: visaIcon,
        cardName: 'Visa',
        cardNumber: '•••• •••• ••••0093'));
    creditCardList.add(SPCreditCard(
        iconName: visaIcon,
        cardName: 'Visa',
        cardNumber: '•••• •••• ••••6670'));

    return creditCardList;
  }


}
