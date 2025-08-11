import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sabipay/app/model/sp_cards.dart';
import 'package:get/get.dart';

class SPCardsController extends GetxController {

  RxDouble topUpBalance = 5886.32.obs;
  RxList<SPCards> cardList = <SPCards>[].obs;

  Future<List<SPCards>> getCardList() async {
    cardList.clear();
    await Future.delayed(const Duration(seconds: 1));
    String jsonData = await rootBundle.loadString(
        "assets/sabipay/data/card_list.json");
    dynamic data = json.decode(jsonData);
    List<dynamic> jsonArray = data['card_list'];
    for (int i = 0; i < jsonArray.length; i++) {
      cardList.add(SPCards.fromJson(jsonArray[i]));
    }
    return cardList;
  }


  @override
  void onInit() {
    getCardList();
    super.onInit();
  }
}
