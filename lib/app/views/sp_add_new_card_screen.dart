import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sabipay/app/controller/sp_add_new_controller.dart';
import 'package:sabipay/app/model/sp_credit_card.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/widgets/sp_app_widget.dart';
import 'package:sabipay/widgets/sp_common_button.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../route/my_route.dart';
import '../../constant/sp_images.dart';
import '../../constant/sp_strings.dart';
import '../../widgets/sp_validation.dart';

class SpAddNewCardScreen extends StatefulWidget {
  const SpAddNewCardScreen({super.key});

  @override
  SpAddNewCardScreenState createState() => SpAddNewCardScreenState();
}

class SpAddNewCardScreenState extends State<SpAddNewCardScreen> {
  SpAddNewController controller = Get.put(SpAddNewController());
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    theme =
        Get.isDarkMode ? SPWalletTheme.spDarkTheme : SPWalletTheme.spLightTheme;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SpAddNewController>(
        init: controller,
        tag: 'sp_add_new',
        // theme: theme,
        builder: (controller) {
          return Scaffold(
            appBar: spCommonAppBarWidget(context, titleText: addNewCard),
            backgroundColor: Get.isDarkMode ? spDarkPrimary : Colors.white,
            bottomNavigationBar: Padding(
              padding:  EdgeInsets.only(left: 20.0,right: 20.0,bottom:
              GetPlatform.isIOS ? MediaQuery.of(context).padding.bottom : 20,top: 20),
              child: SPCommonButton(
                text: connectCreditCard,
                onPressed: () {
                  // validateText(value, message)
                  if (controller.formKey.currentState!.validate()) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return _buildConnectCardSuccessBottomSheet();
                      },
                    );
                  }
                },
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardScanWidget(),
                    20.height,
                    _buildHintText(cardHolderName),
                    4.height,
                    TextFormField(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Get.isDarkMode
                            ? whiteColor
                            : spTextColor, // Set your desired text color
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      focusNode: controller.f1,
                      validator: (value) => validateText(
                          value!, 'Please enter your cardholder name'),
                      onFieldSubmitted: (v) {
                        controller.f1.unfocus();
                        FocusScope.of(context).requestFocus(controller.f3);
                      },
                      controller: controller.cardHolderNameController,
                      decoration: spInputDecoration(context,
                          borderColor:
                              Get.isDarkMode ? spColorGrey400 : spColorGrey200,
                          fillColor:
                              Get.isDarkMode ? spDarkPrimary : Colors.white,
                          hintColor: spColorGrey400,
                          hintText: enterYourCardHolderName),
                    ),
                    20.height,
                    _buildHintText(cardTypes),
                    4.height,
                    Obx(
                      () => DropdownMenu<CardType>(
                        // errorText:(controller.selectedCardType.value == null)?selectCardTypes:'' ,
                        width: MediaQuery.of(context).size.width * 0.9,
                        textStyle: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Get.isDarkMode
                              ? whiteColor
                              : spTextColor, // Set your desired text color
                        ),
                        initialSelection: controller.cardTypes[0],
                        // focusNode: controller.f2,
                        hintText: selectCardTypes,
                        controller: controller.cardTypeController,
                        requestFocusOnTap: false,
                        leadingIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SvgPicture.asset(
                            controller.selectedCardType.value.assetPath,
                            width: 24,
                            height: 24,
                          ),
                        ),
                        inputDecorationTheme: InputDecorationTheme(
                          suffixIconColor:
                              Get.isDarkMode ? spColorGrey400 : spColorGrey500,
                          fillColor:
                              Get.isDarkMode ? spDarkPrimary : Colors.white,
                          contentPadding: const EdgeInsets.all(15),
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: spColorGrey400,
                            fontWeight: FontWeight.w400,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: radius(12),
                            borderSide: BorderSide(
                                color: Get.isDarkMode
                                    ? spColorGrey400
                                    : spColorGrey200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: radius(12),
                            borderSide: BorderSide(
                                color: Get.isDarkMode
                                    ? spColorGrey400
                                    : spColorGrey200),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: radius(12),
                            borderSide: const BorderSide(
                                color: spColorError500, width: 1.0),
                          ),
                          errorStyle: theme.textTheme.bodySmall
                              ?.copyWith(color: spColorError500, fontSize: 13),
                        ),
                        onSelected: (value) {
                          controller.setSelectedCardType(value!);
                        },
                        dropdownMenuEntries: controller.cardTypes
                            .map<DropdownMenuEntry<CardType>>((CardType type) {
                          return DropdownMenuEntry<CardType>(
                            value: type,
                            label: type.name,
                            leadingIcon: SvgPicture.asset(
                              type.assetPath,
                              // Replace with the correct asset paths
                              width: 24,
                              height: 24,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    20.height,
                    _buildHintText(cardNumber),
                    4.height,
                    TextFormField(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Get.isDarkMode
                            ? whiteColor
                            : spTextColor, // Set your desired text color
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        CreditCardInputFormatter(),
                      ],
                      focusNode: controller.f3,
                      validator: (value) => controller.validateCreditCard(
                          controller.cardNumberController.text),
                      onFieldSubmitted: (v) {
                        controller.f3.unfocus();
                        FocusScope.of(context).requestFocus(controller.f4);
                      },
                      controller: controller.cardNumberController,
                      decoration: spInputDecoration(context,
                          borderColor:
                              Get.isDarkMode ? spColorGrey400 : spColorGrey200,
                          fillColor:
                              Get.isDarkMode ? spDarkPrimary : Colors.white,
                          hintColor: spColorGrey400,
                          hintText: enterYourCardNumber),
                    ),
                    20.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHintText(expiredDate),
                              4.height,
                              InkWell(
                                onTap: () {
                                  openDatePicker();
                                },
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: Get.isDarkMode
                                          ? whiteColor
                                          : spTextColor, // Set your desired text color
                                    ),
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.text,
                                    inputFormatters: const [],
                                    focusNode: controller.f4,
                                    validator: (value) => validateText(value!,
                                        'Please enter your expired date'),
                                    onFieldSubmitted: (v) {
                                      controller.f4.unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(controller.f5);
                                    },
                                    controller: controller.expiryDateController,
                                    decoration: spInputDecoration(context,
                                        borderColor: Get.isDarkMode
                                            ? spColorGrey400
                                            : spColorGrey200,
                                        fillColor: Get.isDarkMode
                                            ? spDarkPrimary
                                            : Colors.white,
                                        hintColor: spColorGrey400,
                                        hintText: expiredDateHint),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        10.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHintText(cvv),
                              4.height,
                              TextFormField(
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Get.isDarkMode
                                      ? whiteColor
                                      : spTextColor, // Set your desired text color
                                ),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(3),
                                  // Set the maximum length to 3 characters
                                ],
                                focusNode: controller.f5,
                                validator: (value) => validateText(
                                    value!, 'Please enter your cvv'),
                                onFieldSubmitted: (v) {
                                  controller.f5.unfocus();
                                },
                                controller: controller.cvvController,
                                decoration: spInputDecoration(context,
                                    borderColor: Get.isDarkMode
                                        ? spColorGrey400
                                        : spColorGrey200,
                                    fillColor: Get.isDarkMode
                                        ? spDarkPrimary
                                        : Colors.white,
                                    hintColor: spColorGrey400,
                                    hintText: '000'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  _buildCardScanWidget() {
    return GestureDetector(
      onTap: () {
        Get.toNamed(MyRoute.spScanCardScreen);
      },
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Get.isDarkMode ? spCardDark : spColorPrimary50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: -4,
                    color: spTextColor.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                cardScanIcon,
                width: 18,
                height: 14,
              ),
            ),
            10.width,
            Expanded(
                child: Text(
              scanCard,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            )),
            10.width,
            SvgPicture.asset(chevronRightIcon)
          ],
        ),
      ),
    );
  }

  _buildHintText(String label) {
    return Text.rich(
      TextSpan(
        text: label,
        style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Get.isDarkMode ? spColorGrey400 : spColorGrey500),
        children: [
          TextSpan(
              text: starStr,
              style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500, color: spColorError500)),
        ],
      ),
    );
  }

  void openDatePicker() async {
    DateTime initialDate = DateTime.now();

    if (controller.expiryDateController.text.isNotEmpty) {
      try {
        initialDate =
            DateFormat('MM/yy').parse(controller.expiryDateController.text);
      } catch (e) {
        // If the parsing fails, we'll just use the current date.
        initialDate = DateTime.now();
      }
    }
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            // Customize the theme of the date picker dialog here
            data: Get.isDarkMode
                ? ThemeData.dark().copyWith(
                    primaryColor: spColorPrimary,
                    // Change primary color

                    colorScheme:
                        const ColorScheme.dark(primary: spColorPrimary),
                    // Change color scheme
                    dialogBackgroundColor:
                        Colors.white, // Change background color
                    // Add more customizations as needed
                  )
                : ThemeData.light().copyWith(
                    primaryColor: spColorPrimary,
                    // Change primary color

                    colorScheme:
                        const ColorScheme.light(primary: spColorPrimary),
                    // Change color scheme
                    dialogBackgroundColor:
                        Colors.white, // Change background color
                    // Add more customizations as needed
                  ),
            child: child!,
          );
        });
    if (pickedDate != null) {
      String formattedDate = DateFormat('MM/yy').format(pickedDate);
      // print('formattedDate $formattedDate');
      controller.expiryDateController.text =
          formattedDate; // Update the controller with the selected date
    }
  }

  _buildConnectCardSuccessBottomSheet() {
    return IntrinsicHeight(
      child: Container(
        // height: 400,
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
            20.height,
            Center(
              child: SvgPicture.asset(
                checkCircleIcon,
                width: 64,
                height: 64,
              ),
            ),
            20.height,
            Center(
              child: Text(
                congratulationsNewCardLinked,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            15.height,
            Text.rich(
              TextSpan(
                text: 'Your card has been linked to your',
                style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: Get.isDarkMode ? spColorGrey400 : spColorGrey500),
                children: [
                  TextSpan(
                    text: ' Sabipay ',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: 'account successfully!',
                    style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                        color:
                            Get.isDarkMode ? spColorGrey400 : spColorGrey500),
                  ),
                ],
              ),
            ),
            30.height,
            SPCommonButton(
              bgColor: spColorPrimary300,
              onPressed: () {
                Get.offNamedUntil(
                  MyRoute.spMainHomeScreen,
                  (route) => route.isFirst,
                );
              },
              text: continueText,
            ),
          ],
        ),
      ),
    );
  }
}

class CreditCardInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove any non-numeric characters
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Format the text with spaces every 4 digits
    String formattedText = '';
    for (int i = 0; i < text.length; i++) {
      if (i % 4 == 0 && i != 0) {
        formattedText += ' ';
      }
      formattedText += text[i];
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
