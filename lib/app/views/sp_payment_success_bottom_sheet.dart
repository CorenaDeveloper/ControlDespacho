import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sabipay/app/controller/sp_transfer_money_controller.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../route/my_route.dart';
import '../../constant/sp_colors.dart';
import '../../constant/sp_images.dart';
import '../../constant/sp_strings.dart';
import '../../widgets/sp_app_widget.dart';
import '../../widgets/sp_common_button.dart';
import '../../widgets/sp_dashed_divider.dart';

class SpPaymentSuccessBottomSheet extends StatefulWidget {
  final ThemeData theme;
  final String userName;
  final String amount;

  const SpPaymentSuccessBottomSheet(
      {super.key, required this.theme, required this.userName, required this.amount});

  @override
  State<SpPaymentSuccessBottomSheet> createState() =>
      SpPaymentSuccessBottomSheetState();
}

class SpPaymentSuccessBottomSheetState
    extends State<SpPaymentSuccessBottomSheet> {
  SPTransferMoneyController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        // height: MediaQuery.of(context).size.height * 0.75,
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
            Center(
              child: SvgPicture.asset(
                checkCircleIcon,
                width: 64,
                height: 64,
              ),
            ),
            5.height,

            Center(
              child: Text(
                paymentSuccess,
                style: widget.theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            20.height,
            const SPDashedDivider(
              height: 1,
              dashWidth: 8,
              color:  spColorGrey300,
            ),
            15.height,
            Center(
              child: Text(
                amount,
                style: widget.theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Get.isDarkMode ? spColorGrey400 : spColorGrey500),
              ),
            ),
            5.height,
            Center(
              child: Text(
                '\$${widget.amount}',
                style: widget.theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            15.height,
            _buildUserBankProfileWidget(),
            15.height,
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Get.isDarkMode ? spColorGrey400 : spColorGrey200),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildRowWidget('From:', '4032 8739 0081 6621'),
                  5.height,
                  _buildRowWidget('To:', '0324 01278 0938 9822'),
                  5.height,
                  _buildRowWidget('Fee', 'Free'),
                ],
              ),
            ),
            15.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SPCommonButton(
                    onPressed: () {},
                    text: seeDetail,
                    bgColor: Colors.transparent,
                    textColor: Get.isDarkMode ? Colors.white : spTextColor,
                    borderColor: Get.isDarkMode ? spColorGrey400 : spColorGrey200,
                  ),
                ),
                10.width,
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color:
                          Get.isDarkMode ? spColorGrey400 : spColorGrey200)),
                  child: SvgPicture.asset(
                    shareIcon,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                        Get.isDarkMode ? Colors.white : spTextColor,
                        BlendMode.srcIn),
                  ),
                )
              ],
            ),
            20.height,
            SPCommonButton(
              bgColor: spColorPrimary300,
              onPressed: () {
                Get.offNamedUntil(
                    MyRoute.spMainHomeScreen, (route) => route.isFirst);
              },
              text: backToHome,
            ),
          ],
        ),
      ),
    );
  }

  _buildRowWidget(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: widget.theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w400,
              color: Get.isDarkMode ? spColorGrey400 : spColorGrey500),
        ),
        Text(
          subtitle,
          style: widget.theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

/*  _buildProfileIconWidget() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: spColorPrimary50),
            child: Center(
              child: Text(
                getInitials('Leslie Alexander'),
                style: widget.theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600, color: spTextColor),
              ),
            ),
          ),
          Container(
            width: 70,
            height: 70,
            margin: const EdgeInsets.only(left: 80),
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: spColorPrimary50),
            child: Center(
              child: Text(
                getInitials(widget.userName),
                style: widget.theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600, color: spTextColor),
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0,
            top: 20,
            child: Container(
              alignment: Alignment.center,
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: SvgPicture.asset(arrowLeftRightIcon),
            ),
          ),
        ],
      ),
    );
  }*/

  _buildUserBankProfileWidget() {
    return Container(
      height: 80,
      padding: const EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color:Get.isDarkMode?spColorGrey400: spColorGrey200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:  BoxDecoration(
                shape: BoxShape.circle, color:Get.isDarkMode ? spColorGrey700: spColorPrimary50),
            child: Center(
              child: Text(
                getInitials(widget.userName),
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
                  widget.userName,
                  style: widget.theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Sbpy - 0324 01278 0938 9822',
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Get.isDarkMode ? spColorGrey400 : spColorGrey500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
