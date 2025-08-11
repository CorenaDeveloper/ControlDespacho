import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sabipay/app/controller/sp_statistic_controller.dart';
import 'package:sabipay/app/model/sp_transaction_history.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/sabipy_theme/theme_controller.dart';
import 'package:sabipay/widgets/sp_app_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/sp_images.dart';
import '../../constant/sp_strings.dart';

class SPStatisticScreen extends StatefulWidget {
  const SPStatisticScreen({super.key});

  @override
  SPStatisticScreenState createState() => SPStatisticScreenState();
}

class SPStatisticScreenState extends State<SPStatisticScreen> {
  SPStatisticController controller = Get.put(SPStatisticController());
  late ThemeData theme;
  ThemeController themeController = Get.put(ThemeController());

  @override
  void initState() {
    super.initState();
    theme =
        Get.isDarkMode ? SPWalletTheme.spDarkTheme : SPWalletTheme.spLightTheme;
  }

  double horizontalPadding = 15.0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SPStatisticController>(
        init: controller,
        tag: 'sp_statistic',
        // theme: theme,
        builder: (controller) {
          return Scaffold(
            backgroundColor:
                themeController.isDarkMode ? spDarkPrimary : spColorLightBg,
            appBar: _buildAppBar(),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentBalance,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color:
                              Get.isDarkMode ? spColorGrey400 : spColorGrey500),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '\$ ${controller.topUpBalance.value}',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: Get.isDarkMode ? Colors.black : Colors.white,
                          ),
                          child: Obx(
                            () => DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.dropdownValue.value,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Get.isDarkMode
                                      ? Colors.white
                                      : spTextColor,
                                ),
                                iconSize: 24,
                                elevation: 16,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                onChanged: (String? newValue) {
                                  controller.updateChartData(newValue!);
                                },
                                items: <String>[
                                  'Weekly',
                                  'Quarterly',
                                  'Yearly',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    30.height,
                    _buildChartView(),
                    20.height,
                    _buildIncomeExpenseCardView(),
                    20.height,
                    Text(
                      recentExpenses,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    10.height,
                    _getTransactionList(),
                    130.height,
                  ],
                ),
              ),
            ),
          );
        });
  }

  _buildChartView() {
    return SizedBox(
      height: 170,
      // padding: const EdgeInsets.all(8.0),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          barGroups: controller.barChartData,
          borderData: FlBorderData(
            show: false,
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            leftTitles: AxisTitles(
              axisNameSize: 50,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${value.toInt()}k',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color:
                            Get.isDarkMode ? spColorGrey400 : spColorGrey500),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (controller.dropdownValue.value) {
                    case 'Weekly':
                      return Text(
                          [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun'
                          ][value.toInt()],
                          style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Get.isDarkMode
                                  ? spColorGrey400
                                  : spColorGrey500));
                    case 'Quarterly':
                      return Text(['Q1', 'Q2', 'Q3', 'Q4'][value.toInt()],
                          style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Get.isDarkMode
                                  ? spColorGrey400
                                  : spColorGrey500));
                    case 'Yearly':
                      return Text(
                          ['2019', '2020', '2021', '2022'][value.toInt()],
                          style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Get.isDarkMode
                                  ? spColorGrey400
                                  : spColorGrey500));
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  _getTransactionList() {
    return FutureBuilder<List<SPTransactionHistory>>(
      future: controller.getTransactionHistoryList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: spColorPrimary,
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              SPTransactionHistory history =
                  controller.transactionHistoryList[index];
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                          color: spColorGrey100, shape: BoxShape.circle),
                      child:
                          spCommonCacheImageWidget(history.icon, 22, width: 22),
                    ),
                    10.width,
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            history.name,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            DateFormat('MMM dd,yyyy').format(history.date),
                            style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: themeController.isDarkMode
                                    ? spColorGrey400
                                    : spColorGrey500),
                          ),
                        ],
                      ),
                    ),
                    10.width,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${history.amount}',
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          history.status,
                          style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: (history.status == 'Paid')
                                  ? spColorSuccess500
                                  : spColorError500),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            itemCount: controller.transactionHistoryList.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
          );
        }
      },
    );
  }

  _buildAppBar() {
    return AppBar(
        backgroundColor: Get.isDarkMode ? spDarkPrimary : spColorLightBg,
        leadingWidth: 0,
        automaticallyImplyLeading: false,
        title: Text(
          statisticOverview,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              width: 44,
              margin: const EdgeInsets.only(right: 20),
              height: 44,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Get.isDarkMode ? spDarkPrimary : Colors.white,
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
                settingIcon,
                height: 12,
                width: 12,
                colorFilter: ColorFilter.mode(
                    Get.isDarkMode ? Colors.white : spTextColor,
                    BlendMode.srcIn),
              ),
            ),
          )
        ]);
  }

  _buildIncomeExpenseCardView() {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: spColorPrimary900.withOpacity(0.06),
              offset: const Offset(0, 24),
              blurRadius: 44,
              spreadRadius: 0),
        ],
        color: Get.isDarkMode ? spCardDark : Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIncExeResultView(arrowDownLeftIcon, 'Income', '\$5,440.00'),
          Container(
            height: 82,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.40),
                    offset: const Offset(8,0),
                    blurRadius: 22,
                    spreadRadius: -4),
              ],
              color: Get.isDarkMode ? spCardDark : Colors.white,
            ),
            width: 2,
          ),
          10.width,
          _buildIncExeResultView(arrowDownRightIcon, 'Expense', '\$2,209.32'),
        ],
      ),
    );
  }

  _buildIncExeResultView(String assetName, String title, String value) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(
                assetName,
                height: 12,
                width: 12,
              ),
              3.width,
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: Get.isDarkMode ? spColorGrey400 : spColorGrey500),
              ),
            ],
          ),
          Text(
            value,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
