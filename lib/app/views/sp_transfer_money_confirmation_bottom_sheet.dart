import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/sp_colors.dart';
import '../../constant/sp_images.dart';
import '../../constant/sp_strings.dart';
import '../../widgets/sp_app_widget.dart';

class SpTransferMoneyConfirmationBottomSheet extends StatefulWidget {
  final ThemeData theme;
  final String userName;
  final String amount;

  const SpTransferMoneyConfirmationBottomSheet(
      {super.key,
      required this.theme,
      required this.userName,
      required this.amount});

  @override
  State<SpTransferMoneyConfirmationBottomSheet> createState() =>
      _SPTransferMoneyBottomSheetState();
}

class _SPTransferMoneyBottomSheetState
    extends State<SpTransferMoneyConfirmationBottomSheet> {
  // SPTransferMoneyController controller = Get.find();
  TextEditingController noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom, // Adjust for keyboard
      ),
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
            _buildProfileIconWidget(),
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
            Text(
              addNote,
              style: widget.theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Get.isDarkMode ? Colors.white : spColorGrey500),
            ),
            5.height,
            TextFormField(
              controller: noteController,
              style: widget.theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              decoration: spInputDecoration(context,
                  hintText: enterYourNoteHere,
                  hintColor: spColorGrey400,
                  borderColor: Get.isDarkMode ? spColorGrey400 : spColorGrey200,
                  borderRadius: 12,
                  fillColor: Colors.transparent),
            ),
            20.height,
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

  _buildProfileIconWidget() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Get.isDarkMode ? spColorGrey100 : spColorPrimary50),
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
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Get.isDarkMode ? spColorGrey100 : spColorPrimary50),
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
              decoration: BoxDecoration(
                  color: Get.isDarkMode ? spColorPrimary200 : Colors.white,
                  shape: BoxShape.circle),
              child: SvgPicture.asset(arrowLeftRightIcon),
            ),
          ),
        ],
      ),
    );
  }

  _buildUserBankProfileWidget() {
    return Container(
      height: 80,
      padding: const EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Get.isDarkMode ? spColorGrey400 : spColorGrey200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Get.isDarkMode ? spColorGrey700 : spColorPrimary50),
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
