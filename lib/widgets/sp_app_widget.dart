import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/sp_colors.dart';

const double maxAmount = 100000.00; // Example maximum amount

Widget ezText(
  String? text, {
  var fontSize = 16,
  Color? textColor,
  var fontFamily,
  var isCentered = false,
  var maxLine = 1,
  var latterSpacing = 0.5,
  bool textAllCaps = false,
  var isLongText = false,
  bool lineThrough = false,
}) {
  return Text(
    textAllCaps ? text!.toUpperCase() : text!,
    textAlign: isCentered ? TextAlign.center : TextAlign.start,
    maxLines: isLongText ? null : maxLine,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: textColor ?? spColorPrimary,
      height: 1.5,
      letterSpacing: latterSpacing,
      decoration:
          lineThrough ? TextDecoration.lineThrough : TextDecoration.none,
    ),
  );
}

Widget spCommonCacheImageWidget(String? url, double height,
    {double? width, BoxFit? fit, Color? color}) {
  if (url.validate().startsWith('http')) {
    if (isMobile) {
      return CachedNetworkImage(
        placeholder:
            placeholderWidgetFn() as Widget Function(BuildContext, String)?,
        imageUrl: '$url',
        height: height,
        width: width,
        color: color,
        fit: fit ?? BoxFit.cover,
        errorWidget: (_, __, ___) {
          return SizedBox(height: height, width: width);
        },
      );
    } else {
      return Image.network(url!,
          height: height, width: width, fit: fit ?? BoxFit.cover);
    }
  } else {
    return Image.asset(url!,
        height: height, width: width, fit: fit ?? BoxFit.cover);
  }
}

Widget? Function(BuildContext, String) placeholderWidgetFn() =>
    (_, s) => placeholderWidget();

Widget placeholderWidget() =>
    Image.asset('assets/placeholder.jpg', fit: BoxFit.cover);

PreferredSizeWidget spCommonAppBarWidget(
  BuildContext context, {
  String? titleText,
  Widget? actionWidget,
  Widget? actionWidget2,
  Widget? actionWidget3,
  Widget? leadingWidget,
  Color? backgroundColor,
  bool? isTitleCenter,
  double? leftPadding,
  bool isback = true,
}) {
  Color bgColor = Get.isDarkMode ? spDarkPrimary : spColorLightBg;

  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: AppBar(
      backgroundColor: backgroundColor ?? bgColor,
      leading: isback
          ? InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Center(
                child: Container(
                  width: 44,
                  height: 44,
                  margin: EdgeInsets.only(left: leftPadding ?? 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bgColor,
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
            )
          : leadingWidget,
      title: Text(
        titleText ?? "",
        textAlign: isTitleCenter == true ? TextAlign.center : TextAlign.start,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: SPWalletTheme.fontFamily,
            ),
      ),
      centerTitle: isTitleCenter ?? true,
      actions: [
        if (actionWidget != null) actionWidget,
        if (actionWidget2 != null) actionWidget2,
        if (actionWidget3 != null) actionWidget3,
      ],
    ),
  );
}

InputDecoration spInputDecoration(
  BuildContext context, {
  String? prefixIcon,
  String? suffixIcon,
  String? labelText,
  double? borderRadius,
  String? hintText,
  bool? isSvg,
  Color? fillColor,
  Color? borderColor,
  Color? hintColor,
  Color? prefixIconColor,
  double? leftContentPadding,
  double? rightContentPadding,
  double? topContentPadding,
  double? bottomContentPadding,
  double? borderWidth,
  VoidCallback? onSuffixPressed,
}) {
  return InputDecoration(
    // prefixIconColor: prefixIconColor,
    counterText: "",
    contentPadding: EdgeInsets.fromLTRB(
        leftContentPadding ?? 15,
        topContentPadding ?? 15,
        rightContentPadding ?? 15,
        bottomContentPadding ?? 15),
    labelText: labelText,
    labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: hintColor ?? spTextColor.withOpacity(0.6),
        fontWeight: FontWeight.w400,
        fontFamily: SPWalletTheme.fontFamily),
    alignLabelWithHint: true,
    hintText: hintText.validate(),
    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: hintColor ?? spTextColor.withOpacity(0.6),
        fontWeight: FontWeight.w400,
        fontFamily: SPWalletTheme.fontFamily),
    isDense: true,
    prefixIcon: prefixIcon != null
        ? Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: isSvg == null
                ? SvgPicture.asset(
                    prefixIcon,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                        prefixIconColor ?? spTextColor, BlendMode.srcIn),
                  )
                : Image.asset(
                    prefixIcon,
                    width: 24,
                    height: 24,
                  ),
          )
        : null,
    prefixIconConstraints: const BoxConstraints(
      minWidth: 20,
      minHeight: 20,
    ),
    suffixIconConstraints: const BoxConstraints(
      minWidth: 20,
      minHeight: 20,
    ),
    suffixIcon: suffixIcon != null
        ? InkWell(
            onTap: onSuffixPressed ?? () {},
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: isSvg == null
                  ? SvgPicture.asset(
                      suffixIcon,
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                          prefixIconColor ?? spTextColor, BlendMode.srcIn),
                    )
                  : Image.asset(
                      suffixIcon,
                      width: 24,
                      height: 24,
                    ),
            ),
          )
        : null,
    enabledBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? 12),
      borderSide: BorderSide(
          color: borderColor ?? spColorGrey200, width: borderWidth ?? 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? 12),
      borderSide: BorderSide(
          color: borderColor ?? spColorGrey200, width: borderWidth ?? 1.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? 12),
      borderSide: BorderSide(color: spColorError500, width: borderWidth ?? 0.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? 12),
      borderSide: BorderSide(color: spColorError500, width: borderWidth ?? 1.0),
    ),
    errorMaxLines: 2,
    errorStyle: primaryTextStyle(
        color: spColorError500, size: 13, fontFamily: SPWalletTheme.fontFamily),
    filled: true,
    fillColor: fillColor ?? Colors.white,
  );
}

String getInitials(userName) {
  List<String> names = userName.split(" ");
  String initials = "";

  if (names.length == 1) {
    return names[0].substring(0, 1); // Return initial of the single name
  }

  int numWords = 2;

  if (numWords < names.length) {
    numWords = names.length;
  }
  for (var i = 0; i < numWords; i++) {
    initials += names[i][0];
  }
  return initials;
}

extension Ext on BuildContext {
  ThemeData get theme => Theme.of(this);

  double get w => MediaQuery.of(this).size.width;

  double get h => MediaQuery.of(this).size.height;
}
