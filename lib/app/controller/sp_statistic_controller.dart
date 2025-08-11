import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sabipay/app/model/sp_transaction_history.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:get/get.dart';

class SPStatisticController extends GetxController {
  RxDouble topUpBalance = 5886.32.obs;
  List<SPTransactionHistory> transactionHistoryList =
      <SPTransactionHistory>[].obs;

  @override
  void onInit() {
    super.onInit();
    barChartData.value = _createSampleData(dropdownValue.value);
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

  var dropdownValue = 'Weekly'.obs;
  RxList<BarChartGroupData> barChartData = <BarChartGroupData>[].obs;

  void updateChartData(String period) {
    dropdownValue.value = period;
    barChartData.value = _createSampleData(period);
    update();
  }

  List<BarChartGroupData> _createSampleData(String period) {
    final weeklyData = [
      _createBarChartGroupData(0, 10),
      _createBarChartGroupData(1, 20),
      _createBarChartGroupData(2, 10),
      _createBarChartGroupData(3, 30),
      _createBarChartGroupData(4, 20),
      _createBarChartGroupData(5, 10),
      _createBarChartGroupData(6, 20),
    ];

    final quarterlyData = [
      _createBarChartGroupData(0, 70),
      _createBarChartGroupData(1, 90),
      _createBarChartGroupData(2, 80),
      _createBarChartGroupData(3, 130),
    ];

    final yearlyData = [
      _createBarChartGroupData(0, 350),
      _createBarChartGroupData(1, 400),
      _createBarChartGroupData(2, 450),
      _createBarChartGroupData(3, 480),
    ];

    switch (period) {
      case 'Weekly':
        return weeklyData;
      case 'Quarterly':
        return quarterlyData;
      case 'Yearly':
        return yearlyData;
      default:
        return weeklyData;
    }
  }

  BarChartGroupData _createBarChartGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: spColorPrimary400,
          width: 32,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }
}
