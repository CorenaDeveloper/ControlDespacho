import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sabipay/app/controller/sp_home_controller.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sabipay/route/my_route.dart';

import '../../constant/sp_colors.dart';
import '../../constant/sp_images.dart';
import '../../constant/sp_strings.dart';
import '../../widgets/sp_app_widget.dart';
import '../../widgets/sp_common_button.dart';

class SPBankTransferTopUpBottomSheet extends StatefulWidget {
  final ThemeData theme;

  const SPBankTransferTopUpBottomSheet({
    super.key,
    required this.theme,
  });

  @override
  State<SPBankTransferTopUpBottomSheet> createState() =>
      _SPBankTransferTopUpBottomSheetState();
}

class _SPBankTransferTopUpBottomSheetState
    extends State<SPBankTransferTopUpBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
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
                      topUp,
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
            Text(
              amount,
              style: widget.theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Get.isDarkMode ? spColorGrey400 : spColorGrey500),
            ),
            Obx(
              () => TextField(
                controller: SPHomeController.bankAmountController.value,
                readOnly: true,
                // Make the TextField read-only
                showCursor: true,
                style: widget.theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  prefixText: '\$ ',
                  prefixStyle: widget.theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
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
            20.height,
            Expanded(
              child: _buildKeyboard(),
            ),
            SPCommonButton(
              bgColor: spColorPrimary300,
              onPressed: () {
                final amountPrice =
                    SPHomeController.bankAmountController.value.text;
                if (amountPrice.isNotEmpty) {
                  double? enteredAmount = double.tryParse(amountPrice);
                  if (enteredAmount == null) {
                    Get.snackbar('Error', 'Please enter valid amount',backgroundColor: Colors.grey);
                    return;
                  }
                  if (enteredAmount > maxAmount) {
                    Get.snackbar('Error',
                        'The amount should not exceed \$${maxAmount.toStringAsFixed(2)}',backgroundColor: Colors.grey);
                  } else {
                    Get.toNamed(MyRoute.spTopUpViaBankScreen);
                  }
                } else {
                  Get.snackbar('Error', 'Please enter an amount',backgroundColor: Colors.grey);
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
        SPHomeController.bankAmountController.value.text = amount;
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
    setState(() {
      if (value == 'DEL') {
        if (SPHomeController.bankAmountController.value.text.isNotEmpty) {
          SPHomeController.bankAmountController.value.text =
              SPHomeController.bankAmountController.value.text.substring(0,
                  SPHomeController.bankAmountController.value.text.length - 1);
        }
      } else {
        SPHomeController.bankAmountController.value.text += value;
      }
    });
  }
}
