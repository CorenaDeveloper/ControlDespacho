import 'package:flag/flag_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sabipay/app/controller/sp_my_account_controller.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/constant/sp_images.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/sabipy_theme/theme_controller.dart';
import 'package:sabipay/widgets/sp_app_widget.dart';
import 'package:sabipay/widgets/sp_common_button.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/sp_strings.dart';
import '../../widgets/sp_validation.dart';
import '../model/countries.dart';

class SPMyAccountScreen extends StatefulWidget {
  const SPMyAccountScreen({super.key});

  @override
  SPMyAccountScreenState createState() => SPMyAccountScreenState();
}

class SPMyAccountScreenState extends State<SPMyAccountScreen> {
  SpMyAccountController controller = Get.put(SpMyAccountController());
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
    return GetBuilder<SpMyAccountController>(
        init: controller,
        tag: 'sp_my_account',
        // theme: theme,
        builder: (controller) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 10, bottom: 20),
              child: SPCommonButton(
                  height: 48,
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: spColorGrey900, fontWeight: FontWeight.w600),
                  bgColor: spColorPrimary300,
                  onPressed: () {
                    controller.errorTextMobile.value = validatePhoneNumber(
                        controller.phoneNumberController.text);
                    if (!controller.formKey.currentState!.validate()) {
                      return;
                    }
                    if (controller.errorTextMobile.value.isNotEmpty) {
                      return;
                    }
                  },
                  text: saveChange),
            ),
            backgroundColor:
                themeController.isDarkMode ? spCardDark : Colors.white,
            appBar: spCommonAppBarWidget(context, titleText: myAccount),
            body: SafeArea(
              child: SingleChildScrollView(
                // padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: controller.formKey,
                  child: Stack(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        color: themeController.isDarkMode
                            ? spDarkPrimary
                            : spColorLightBg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            20.height,
                            Center(
                              child: ClipOval(
                                child: spCommonCacheImageWidget(
                                    'https://i.ibb.co/s2HC0TF/Change-Profile-Pic.png',
                                    100,
                                    width: 100),
                              ),
                            ),
                            10.height,
                            Center(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    cameraIcon,
                                    width: 15,
                                    height: 13,
                                    colorFilter: ColorFilter.mode(
                                        Get.isDarkMode
                                            ? Colors.white
                                            : spTextColor,
                                        BlendMode.srcIn),
                                  ),
                                  5.width,
                                  Text(
                                    changePicture,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            60.height,
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                            color: Get.isDarkMode ? spCardDark : Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            20.height,
                            Text.rich(
                              TextSpan(
                                text: fullName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Get.isDarkMode
                                        ? spColorGrey400
                                        : spColorGrey500),
                                children: [
                                  TextSpan(
                                    text: '*',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: spColorError500),
                                  ),
                                ],
                              ),
                            ),
                            8.height,
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
                              onChanged: (_) {},
                              validator: (value) => validateText(
                                  value!, 'Please enter your full name'),
                              onFieldSubmitted: (v) {
                                controller.f1.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(controller.f2);
                              },
                              controller: controller.fullNameController,
                              decoration: spInputDecoration(context,
                                  prefixIconColor: Get.isDarkMode
                                      ? spColorGrey400
                                      : spColorGrey500,
                                  prefixIcon: userIcon,
                                  borderColor: Get.isDarkMode
                                      ? spColorGrey400
                                      : spColorGrey200,
                                  fillColor: Colors.transparent,
                                  hintColor: spColorGrey400,
                                  hintText: enterYourFullName),
                            ),
                            20.height,
                            Text.rich(
                              TextSpan(
                                text: emailAddress,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Get.isDarkMode
                                        ? spColorGrey400
                                        : spColorGrey500),
                                children: [
                                  TextSpan(
                                    text: '*',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: spColorError500),
                                  ),
                                ],
                              ),
                            ),
                            8.height,
                            TextFormField(
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Get.isDarkMode
                                    ? whiteColor
                                    : spTextColor, // Set your desired text color
                              ),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              focusNode: controller.f2,
                              onChanged: (_) {},
                              validator: (value) => validateEmail(value!),
                              onFieldSubmitted: (v) {
                                controller.f2.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(controller.f3);
                              },
                              controller: controller.emailController,
                              decoration: spInputDecoration(context,
                                  prefixIconColor: Get.isDarkMode
                                      ? spColorGrey400
                                      : spColorGrey500,
                                  prefixIcon: smsIcon,
                                  borderColor: Get.isDarkMode
                                      ? spColorGrey400
                                      : spColorGrey200,
                                  fillColor: Colors.transparent,
                                  hintColor: spColorGrey400,
                                  hintText: enterYourEmailAddress),
                            ),
                            20.height,
                            Text.rich(
                              TextSpan(
                                text: phoneNumber,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Get.isDarkMode
                                        ? spColorGrey400
                                        : spColorGrey500),
                                children: [
                                  TextSpan(
                                    text: '*',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: spColorError500),
                                  ),
                                ],
                              ),
                            ),
                            8.height,
                            Obx(
                              () => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: controller
                                            .errorTextMobile.value.isNotEmpty
                                        ? spColorError500
                                        : Get.isDarkMode
                                            ? spColorGrey400
                                            : spColorGrey200,
                                  ),
                                  color: Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    8.width,
                                    InkWell(
                                      child: Text(
                                        controller
                                            .selectedCountryCode.value.dialCode,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Get.isDarkMode
                                              ? whiteColor
                                              : spTextColor, // Set your desired text color
                                        ),
                                      ),
                                      onTap: () {
                                        showCountryDialog(context);
                                      },
                                    ),
                                    10.width,
                                    InkWell(
                                      onTap: () {
                                        showCountryDialog(context);
                                      },
                                      child: SvgPicture.asset(
                                        downIcon,
                                        width: 12,
                                        height: 12,
                                        colorFilter: ColorFilter.mode(
                                            Get.isDarkMode
                                                ? Colors.white
                                                : spTextColor,
                                            BlendMode.srcIn),
                                      ),
                                    ),
                                    10.width,
                                    Expanded(
                                      child: TextFormField(
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: Get.isDarkMode
                                              ? whiteColor
                                              : spTextColor, // Set your desired text color
                                        ),
                                        textInputAction: TextInputAction.done,
                                        keyboardType: GetPlatform.isIOS
                                            ? TextInputType.text
                                            : TextInputType.phone,
                                        focusNode: controller.f3,
                                        onChanged: (_) {
                                          controller.errorTextMobile.value =
                                              validatePhoneNumber(controller
                                                  .phoneNumberController.text);
                                        },
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(15),
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          // Allows only digits
                                          // Set the maximum length to 3 characters
                                        ],
                                        onFieldSubmitted: (v) {
                                          controller.f3.unfocus();
                                        },
                                        controller:
                                            controller.phoneNumberController,
                                        decoration: spInputDecoration(context,
                                            leftContentPadding: 5,
                                            borderColor: Colors.transparent,
                                            fillColor: Colors.transparent,
                                            hintColor: spColorGrey400,
                                            hintText: phoneNumber),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Obx(
                              () => Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Text(
                                  controller.errorTextMobile.value,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: spColorError500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      130.height,
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void showCountryDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    List<SPCountries> filteredCountries = controller.listOfCountries;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Select a Country',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextField(
                        controller: searchController,
                        decoration: spInputDecoration(context,
                            borderRadius: 8,
                            borderColor: Get.isDarkMode
                                ? spColorGrey400
                                : spColorGrey200,
                            fillColor:
                                Get.isDarkMode ? spDarkPrimary : Colors.white,
                            hintColor: spColorGrey400,
                            hintText: 'Search here...'),
                        onChanged: (value) {
                          setState(() {
                            // Filter the countries based on the search query
                            filteredCountries = controller.listOfCountries
                                .where((country) => country.name
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      height: MediaQuery.of(context).size.height *
                          0.5, // Adjust height as needed
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredCountries.length,
                        itemBuilder: (context, index) {
                          var country = filteredCountries[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Flag.fromString(
                              country.code,
                              height: 30,
                              width: 50,
                            ),
                            title: Text(
                              country.name,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            onTap: () {
                              // Do something when a country is selected
                              controller.selectedCountryCode.value = country;
                              if (kDebugMode) {
                                print('Selected: ${country.name}');
                              }
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
