import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sabipay/constant/sp_colors.dart';

class SPOtpTextField extends StatelessWidget {
  final FocusNode focusNode;
  final Function(String) onTextChanged;

  final ThemeData theme;

  const SPOtpTextField({
    super.key,
    required this.focusNode,
    required this.onTextChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // color: Get.isDarkMode ? foodCardDark : colorGrey50,
        shape: BoxShape.rectangle,
        border: Border.all(
          width: 1,
          color: Get.isDarkMode ? spColorGrey400 : spColorGrey200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: TextField(
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          maxLength: 1,
          decoration: const InputDecoration(
            counter: Offstage(),
            border: InputBorder.none,
          ),
          onChanged: onTextChanged,
        ),
      ),
    );
  }
}

/*
class SPOtpTextField extends StatelessWidget {
  final SPOTPVerifyController controller;

  final Function(String) onChanged;

  SPOtpTextField({super.key, required this.onChanged})
      : controller = Get.put(SPOTPVerifyController());

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        4,
        (index) => SizedBox(
          width: 60, // Adjust the width based on the number of fields
          height: 60,
          child: TextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            textAlignVertical: TextAlignVertical.center,
            focusNode: controller.focusNodes[index],
            controller: controller.controllers[index],
            onChanged: (value) {
              controller.onChanged(index, value);
              onChanged(controller.getOTP());
            },
            decoration: InputDecoration(
              counterText: "",
              contentPadding: const EdgeInsets.all(12),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: spColorPrimary300,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Get.isDarkMode ? spColorGrey400 : spColorGrey200,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: TextStyle(
                fontSize: 20,
                fontFamily: SPWalletTheme.fontFamily,
                fontWeight: FontWeight.w300),
            // Adjust the font size as needed
            strutStyle: const StrutStyle(
              height: 1,
              leading: 1,
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
            ],
          ),
        ),
      ),
    );
  }
}
*/
