import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sabipay/app/controller/sp_home_controller.dart';
import 'package:sabipay/app/controller/sp_transfer_money_controller.dart';
import 'package:sabipay/app/model/sp_bank.dart';
import 'package:sabipay/app/model/sp_user_data.dart';
import 'package:sabipay/app/views/sp_transfer_money_confirmation_bottom_sheet.dart';
import 'package:sabipay/widgets/sp_app_widget.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/sp_colors.dart';
import '../../constant/sp_images.dart';
import '../../constant/sp_strings.dart';
import '../../widgets/sp_common_button.dart';

class SPTransferMoneyBottomSheet extends StatefulWidget {
  final ThemeData theme;

  const SPTransferMoneyBottomSheet({super.key, required this.theme});

  @override
  State<SPTransferMoneyBottomSheet> createState() =>
      _SPTransferMoneyBottomSheetState();
}

class _SPTransferMoneyBottomSheetState
    extends State<SPTransferMoneyBottomSheet> {
  SPTransferMoneyController controller = Get.put(SPTransferMoneyController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SPTransferMoneyController>(
        init: controller,
        tag: 'sp_transfer_money',
        builder: (controller) {
          return SingleChildScrollView(
            child: Container(
              // height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  color: Get.isDarkMode ? spColorGrey900 : Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  8.height,
                  Center(
                    child: SvgPicture.asset(
                      homeIndicatorIcon,
                      width: 66,
                      height: 5,
                    ),
                  ),
                  15.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        sendPay,
                        style: widget.theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 73,
                          height: 34,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Get.isDarkMode
                                    ? spColorGrey400
                                    : spColorGrey200),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Center(
                            child: Text(
                              cancel,
                              textAlign: TextAlign.center,
                              style: widget.theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Get.isDarkMode
                                      ? spColorGrey400
                                      : spColorGrey500),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  15.height,
                  TextFormField(
                    style: widget.theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                    decoration: spInputDecoration(context,
                        fillColor: Get.isDarkMode ? Colors.transparent :spColorGrey100,
                        hintText: 'Search...',
                        prefixIcon: searchIcon,
                        prefixIconColor: Get.isDarkMode ? Colors.white : spTextColor,
                        borderColor:Get.isDarkMode ? Colors.white60: spColorGrey100,
                        borderRadius: 32,
                        hintColor: spColorGrey400),
                  ),
                  15.height,
                  HorizontalList(
                    itemCount: controller.catList.length,
                    itemBuilder: (context, index) {
                      return _buildUserView(
                          index, controller, controller.catList[index]);
                    },
                  ),
                  // 15.height,
                  Obx(
                    () => Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.selectIndex.value == 0)
                          _getSabipayListView(controller),
                        if (controller.selectIndex.value == 1)
                          _getBankListView(controller),
                        if (controller.selectIndex.value == 2)
                          _getFavoritesListView(controller),
                      ],
                    ),
                  ),

                  15.height,
                ],
              ),
            ),
          );
        });
  }

  _buildUserView(int index, SPTransferMoneyController controller, String data) {
    return Obx(
      () => InkWell(
        onTap: () {
          controller.selectIndex.value = index;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: (controller.selectIndex.value == index)
                ? spColorPrimary300
                : Colors.transparent,
            border: Border.all(
                color: (controller.selectIndex.value == index)
                    ? spColorPrimary300
                    : spColorGrey200),
          ),
          child: Center(
            child: Text(
              data,
              style: widget.theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: (controller.selectIndex.value == index)
                      ? spTextColor
                      : Get.isDarkMode
                          ? spColorGrey400
                          : spColorGrey500),
            ),
          ),
        ),
      ),
    );
  }

  _getSabipayListView(SPTransferMoneyController controller) {
    // controller.amountController.text = '';
    return Obx(
      () => ListView.builder(
        itemBuilder: (context, index) {
          SPUserData user = controller.contactList[index];
          return InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  controller.amountController.text = '';
                  return _buildCardInputAmountBottomSheet(user.name);
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration:  BoxDecoration(
                            shape: BoxShape.circle, color:  Get.isDarkMode ? spColorGrey700 :spColorPrimary50),
                        child: Center(
                          child: Text(
                            getInitials(user.name),
                            style: widget.theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: spColorPrimary),
                          ),
                        ),
                      ),
                      10.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: widget.theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Sbpy - 0324 01278 0938 9822',
                              style: widget.theme.textTheme.bodyMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: Get.isDarkMode
                                          ? spColorGrey400
                                          : spColorGrey500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  5.height,
                   Divider(
                    color:Get.isDarkMode ? spColorGrey800 : spColorGrey200,
                  )
                ],
              ),
            ),
          );
        },
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.contactList.length,
      ),
    );
  }

  _getBankListView(SPTransferMoneyController controller) {
    // controller.amountController.text = '';
    return Obx(
      () => ListView.builder(
        itemBuilder: (context, index) {
          SPBank user = controller.bankList[index];
          return InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  controller.amountController.text = '';
                  return _buildCardInputAmountBottomSheet(user.name);
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration:  BoxDecoration(
                                shape: BoxShape.circle,
                                color:  Get.isDarkMode ? spColorGrey700 :spColorPrimary50),
                            child: Center(
                              child: Text(
                                getInitials(user.name),
                                style: widget.theme.textTheme.bodyLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: spColorPrimary),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // spCommonCacheImageWidget(user.icon, 40, width: 40),
                      10.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: widget.theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Sbpy - 0324 01278 0938 9822',
                              style: widget.theme.textTheme.bodyMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: Get.isDarkMode
                                          ? spColorGrey400
                                          : spColorGrey500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  5.height,
                   Divider(
                    color:Get.isDarkMode ? spColorGrey700: spColorGrey200,
                  )
                ],
              ),
            ),
          );
        },
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.bankList.length,
      ),
    );
  }

  _getFavoritesListView(SPTransferMoneyController controller) {
    // controller.amountController.text = '';
    return Obx(
      () => ListView.builder(
        itemBuilder: (context, index) {
          SPUserData user = controller.favoritesList[index];
          return InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  controller.amountController.text = '';
                  return _buildCardInputAmountBottomSheet(user.name);
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration:  BoxDecoration(
                            shape: BoxShape.circle, color: Get.isDarkMode ? spColorGrey700 : spColorPrimary50),
                        child: Center(
                          child: Text(
                            getInitials(user.name),
                            style: widget.theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: spColorPrimary),
                          ),
                        ),
                      ),
                      10.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: widget.theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Sbpy - 0324 01278 0938 9822',
                              style: widget.theme.textTheme.bodyMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: Get.isDarkMode
                                          ? spColorGrey400
                                          : spColorGrey500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  5.height,
                   Divider(
                    color: Get.isDarkMode ? spColorGrey700: spColorGrey200,
                  )
                ],
              ),
            ),
          );
        },
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.favoritesList.length,
      ),
    );
  }

  _buildCardInputAmountBottomSheet(String userName) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            color: Get.isDarkMode ? spColorGrey900 : Colors.white),
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom:
            GetPlatform.isIOS ? MediaQuery.of(context).padding.bottom : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            8.height,
            Center(
              child: SvgPicture.asset(
                homeIndicatorIcon,
                width: 66,
                height: 5,
              ),
            ),
            15.height,
            SizedBox(
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      sendTo,
                      textAlign: TextAlign.center,
                      style: widget.theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Get.isDarkMode ? spColorGrey700 : Colors.white,
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
                          color: Get.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            15.height,
            Container(
              height: 80,
              padding: const EdgeInsets.only(left: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color:  Get.isDarkMode ? spColorGrey500 :spColorGrey200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration:  BoxDecoration(
                        shape: BoxShape.circle, color:  Get.isDarkMode ? spColorGrey700 :spColorPrimary50),
                    child: Center(
                      child: Text(
                        getInitials(userName),
                        style: widget.theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600, color: spColorPrimary),
                      ),
                    ),
                  ),
                  10.width,
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: widget.theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Sbpy - 0324 01278 0938 9822',
                          style: widget.theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: Get.isDarkMode
                                  ? spColorGrey400
                                  : spColorGrey500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            15.height,
            Text(
              amount,
              style: widget.theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Get.isDarkMode ? spColorGrey400 : spColorGrey500),
            ),
            /*Obx(
              () => */TextField(
                controller: controller.amountController,
                readOnly: true,
                // Make the TextField read-only
                showCursor: true,
                style: widget.theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: const [],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  prefixText: '\$ ',
                  prefixStyle: widget.theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            // ),
            15.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountButton('100'),
                _buildAmountButton('200'),
                _buildAmountButton('300'),
                _buildAmountButton('400'),
              ],
            ),
            15.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  availableBalance,
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Get.isDarkMode ? spColorGrey400 : spColorGrey500),
                ),
                Text(
                  '\$ ${SPHomeController().topUpBalance.value}',
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            15.height,
            Expanded(
              child: _buildKeyboard(),
            ),
            SPCommonButton(
              bgColor: spColorPrimary300,
              onPressed: () {
                final amountPrice = controller.amountController.text;
                if (amountPrice.isNotEmpty) {
                  if (double.parse(amountPrice) >=
                      SPHomeController().topUpBalance.value) {
                    Fluttertoast.showToast(
                        msg: 'Not sufficient balance available.',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } else {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return SpTransferMoneyConfirmationBottomSheet(
                          theme: widget.theme,
                          userName: userName,
                          amount: controller.amountController.text,
                        );
                      },
                    );
                  }
                } else {
                  // Show an error message
                  Fluttertoast.showToast(
                      msg: 'Please enter an amount',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
              text: continueText,
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildAmountButton(String amount) {
    return InkWell(
      onTap: () {
        controller.amountController.text = amount;
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
                color: Get.isDarkMode ? spColorGrey400 : spColorGrey200)),
        child: Text(
          '\$$amount',
          style: widget.theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    return IntrinsicHeight(
      child: Column(
        children: [
          _buildHorizontalLine(),
          _buildKeyboardRow(['1', '2', '3']),
          _buildHorizontalLine(),
          _buildKeyboardRow(['4', '5', '6']),
          _buildHorizontalLine(),
          _buildKeyboardRow(['7', '8', '9']),
          _buildHorizontalLine(),
          _buildKeyboardRow(['.', '0', 'DEL']),
        ],
      ),
    );
  }

  _buildHorizontalLine() {
    return Container(
      width: double.infinity,
      height: 1,
      decoration: BoxDecoration(
        // color: spBorderColor,
        gradient: LinearGradient(
          colors: [
            spBorderColor.withOpacity(0.01),
            spBorderColor,
            spBorderColor.withOpacity(0.01),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalLine() {
    return Container(
      width: 1,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            spBorderColor.withOpacity(0.01),
            spBorderColor,
            spBorderColor.withOpacity(0.01),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    List<Widget> rowChildren = [];
    for (int i = 0; i < keys.length; i++) {
      rowChildren.add(
        Expanded(
          child: InkWell(
            onTap: () => _onKeyTap(keys[i]),
            child: Container(
              height: 60,
              alignment: Alignment.center,
              child: keys[i] == 'DEL'
                  ? SvgPicture.asset(
                      deleteKeyIcon,
                      width: 21,
                      height: 14,
                    )
                  : Text(
                      keys[i],
                      style: widget.theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ),
      );
      if (i < keys.length - 1) {
        rowChildren.add(_buildVerticalLine());
      }
    }
    return Expanded(
      child: Row(
        children: rowChildren,
      ),
    );
  }

  void _onKeyTap(String value) {
    // setState(() {
    if (value == 'DEL') {
      if (controller.amountController.text.isNotEmpty) {
        controller.amountController.text = controller
            .amountController.text
            .substring(0, controller.amountController.text.length - 1);
      }
    } else {
      controller.amountController.text += value;
    }
    // });
  }
}
