import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:nb_utils/nb_utils.dart';

class AnimatedBottomBar extends StatelessWidget {
  final int currentIcon;
  final List<IconModel> icons;
  final ValueChanged<int>? onTap;
  final Color bgColor;

  const AnimatedBottomBar({
    super.key,
    required this.currentIcon,
    required this.onTap,
    required this.icons,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0),
            Colors.white.withOpacity(0.01)
          ]
        )
      ),
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: spTextColor.withOpacity(0.20),
              blurRadius: 40,
              offset: const Offset(0, 12), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: icons
              .map(
                (icon) => GestureDetector(
                  onTap: () => onTap?.call(icon.id),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 900),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            currentIcon == icon.id
                                ? icon.selectedIconName
                                : icon.iconName,
                            width: currentIcon == icon.id ? 26 : 23,
                            height: currentIcon == icon.id ? 26 : 23,
                            colorFilter: ColorFilter.mode(
                                currentIcon == icon.id
                                    ? spColorPrimary
                                    : spColorGrey300,
                                BlendMode.srcIn),
                          ),
                          4.height,
                          Text(
                            icon.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: SPWalletTheme.fontFamily,
                                fontSize: 11,
                                color: currentIcon == icon.id
                                    ? Colors.white
                                    : spColorGrey300),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class IconModel {
  int id;
  String iconName;
  String selectedIconName;
  String name;

  IconModel(
      {required this.id,
      required this.iconName,
      required this.selectedIconName,
      required this.name});
}
