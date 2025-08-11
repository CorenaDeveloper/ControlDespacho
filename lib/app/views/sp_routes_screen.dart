import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/sabipy_theme/theme_controller.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/sp_images.dart';

class SPRoutesScreen extends StatefulWidget {
  const SPRoutesScreen({super.key});

  @override
  SPRoutesScreenState createState() => SPRoutesScreenState();
}

class SPRoutesScreenState extends State<SPRoutesScreen> {
  late ThemeData theme;
  ThemeController themeController = Get.put(ThemeController());

  @override
  void initState() {
    super.initState();
    theme =
        Get.isDarkMode ? SPWalletTheme.spDarkTheme : SPWalletTheme.spLightTheme;
  }

  double horizontalPadding = 15.0;

  // Lista de rutas de ejemplo
  final List<Map<String, dynamic>> routes = [
    {
      'name': 'Ruta Centro',
      'distance': '5.2 km',
      'time': '15 min',
      'price': '\$2.50',
      'status': 'Activa',
      'icon': transferIcon,
    },
    {
      'name': 'Ruta Norte',
      'distance': '8.7 km',
      'time': '25 min',
      'price': '\$3.80',
      'status': 'Disponible',
      'icon': homeIcon2,
    },
    {
      'name': 'Ruta Sur',
      'distance': '12.1 km',
      'time': '35 min',
      'price': '\$5.20',
      'status': 'Ocupada',
      'icon': scanIcon,
    },
    {
      'name': 'Ruta Express',
      'distance': '3.8 km',
      'time': '10 min',
      'price': '\$4.00',
      'status': 'Activa',
      'icon': requestIcon,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          themeController.isDarkMode ? spDarkPrimary : spColorLightBg,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              20.height,
              _buildSearchBar(),
              20.height,
              Text(
                'Rutas Disponibles',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              15.height,
              _buildRoutesList(),
              130.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: spColorPrimary900.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            searchIcon,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              Get.isDarkMode ? spColorGrey400 : spColorGrey500,
              BlendMode.srcIn,
            ),
          ),
          15.width,
          Expanded(
            child: Text(
              'Buscar ruta...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Get.isDarkMode ? spColorGrey400 : spColorGrey500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        return _buildRouteCard(route, index);
      },
    );
  }

  Widget _buildRouteCard(Map<String, dynamic> route, int index) {
    Color statusColor = _getStatusColor(route['status']);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? spCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: spColorPrimary900.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? spColorGrey700 : spColorGrey100,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              route['icon'],
              colorFilter: ColorFilter.mode(
                Get.isDarkMode ? Colors.white : spTextColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          15.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      route['name'],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      route['price'],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: spColorPrimary,
                      ),
                    ),
                  ],
                ),
                5.height,
                Row(
                  children: [
                    Text(
                      '${route['distance']} • ${route['time']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Get.isDarkMode ? spColorGrey400 : spColorGrey500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        route['status'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activa':
        return spColorSuccess500;
      case 'disponible':
        return spColorPrimary;
      case 'ocupada':
        return spColorError500;
      default:
        return spColorGrey500;
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor:
          themeController.isDarkMode ? spDarkPrimary : spColorLightBg,
      leadingWidth: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'Lista de Rutas',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        InkWell(
          onTap: () {},
          child: Container(
            width: 44,
            margin: const EdgeInsets.only(right: 20),
            height: 44,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Get.isDarkMode ? spDarkPrimary : Colors.white,
              boxShadow: [
                BoxShadow(
                  spreadRadius: -4,
                  color: spTextColor.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SvgPicture.asset(
              settingIcon,
              height: 12,
              width: 12,
              colorFilter: ColorFilter.mode(
                Get.isDarkMode ? Colors.white : spTextColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        )
      ],
    );
  }
}
