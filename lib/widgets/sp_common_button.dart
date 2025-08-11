import 'package:flutter/material.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';

class SPCommonButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double? width;
  final double? height;
  final double? fontSize;
  final Color? bgColor;
  final Color? borderColor;
  final Color? textColor;
  final BoxBorder? boxBorder;
  final TextStyle? textStyle;

  const SPCommonButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height,
    this.fontSize,
    this.bgColor,
    this.textColor,
    this.borderColor,
    this.boxBorder,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 48.0,
      decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? Colors.transparent),
          borderRadius: BorderRadius.circular(30.0),
          color: bgColor ?? spColorPrimary300),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            // side: BorderSide(color:borderColor ?? Colors.transparent,width: 1 )
          ),
          elevation: 4,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: textStyle ??
              TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? spTextColor,
                  fontFamily: SPWalletTheme.fontFamily),
        ),
      ),
    );
  }
}
