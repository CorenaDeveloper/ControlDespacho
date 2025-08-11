// app/views/sp_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sabipay/constant/sp_colors.dart';
import 'package:sabipay/sabipy_theme/sp_wallet_theme.dart';
import 'package:sabipay/sabipy_theme/theme_controller.dart';
import 'package:sabipay/route/my_route.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nb_utils/nb_utils.dart';

class SPHomeScreen extends StatefulWidget {
  const SPHomeScreen({super.key});

  @override
  SPHomeScreenState createState() => SPHomeScreenState();
}

class SPHomeScreenState extends State<SPHomeScreen>
    with TickerProviderStateMixin {
  ThemeController themeController = Get.put(ThemeController());
  late ThemeData theme;
  final box = GetStorage();
  late FocusNode _focusNode;

  // Controladores de animación para efectos visuales
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Para trackear qué tecla está presionada
  int? _pressedKey;

  @override
  void initState() {
    super.initState();
    theme =
        Get.isDarkMode ? SPWalletTheme.spDarkTheme : SPWalletTheme.spLightTheme;
    _focusNode = FocusNode();

    // Configurar animación de pulso
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Solicitar focus para capturar teclas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Manejar teclas presionadas
  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      int? keyNumber;

      switch (event.logicalKey) {
        case LogicalKeyboardKey.f1:
          keyNumber = 1;
          break;
        case LogicalKeyboardKey.f2:
          keyNumber = 2;
          break;
        case LogicalKeyboardKey.f3:
          keyNumber = 3;
          break;
        case LogicalKeyboardKey.f4:
          keyNumber = 4;
          break;
      }

      if (keyNumber != null) {
        _executeAction(keyNumber);
        _animateKeyPress(keyNumber);
        return true; // Indica que el evento fue manejado
      }
    }
    return false;
  }

  // Ejecutar acción según el número
  void _executeAction(int actionNumber) {
    switch (actionNumber) {
      case 1:
        Get.toNamed(MyRoute.spScanBarcodeScreen);
        break;
      case 2:
        Get.toNamed(MyRoute.spPHistoryScreen);
        break;
      case 3:
        Get.toNamed(MyRoute.spConsolidadoScreen);
        break;
      case 4:
        Get.toNamed(MyRoute.sPProfileScreen);
        break;
    }
  }

  // Animar cuando se presiona una tecla
  void _animateKeyPress(int keyNumber) {
    setState(() {
      _pressedKey = keyNumber;
    });

    _pulseController.forward().then((_) {
      _pulseController.reverse().then((_) {
        setState(() {
          _pressedKey = null;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = box.read('user_name') ?? 'Usuario';
    final userCode = box.read('user_code') ?? '';

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor:
            themeController.isDarkMode ? spDarkPrimary : spColorLightBg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con saludo
                _buildHeader(userName, userCode),
                20.height,
                // Funciones principales
                _buildMainActions(),
                20.height,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String userName, String userCode) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [spColorPrimary, spColorPrimary600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: spColorPrimary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 29,
            ),
          ),
          20.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                4.height,
                Text(
                  userName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (userCode.isNotEmpty) ...[
                  4.height,
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ID: $userCode',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opciones Principales',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: themeController.isDarkMode ? Colors.white : spTextColor,
          ),
        ),
        12.height,
        // Layout vertical: 4 opciones en fila, una debajo de la otra
        Column(
          children: [
            // F1: Escanear
            _buildMainActionCard(
              icon: Icons.qr_code_scanner,
              title: 'Escanear',
              keyLabel: 'F1',
              color: spColorPrimary,
              isPressed: _pressedKey == 1,
              onTap: () => _executeAction(1),
            ),
            8.height,
            // F2: Historial
            _buildMainActionCard(
              icon: Icons.history,
              title: 'Historial',
              keyLabel: 'F2',
              color: spColorTeal600,
              isPressed: _pressedKey == 2,
              onTap: () => _executeAction(2),
            ),
            8.height,
            // F3: Consolidados
            _buildMainActionCard(
              icon: Icons.inventory_2,
              title: 'Consolidados',
              keyLabel: 'F3',
              color: spColorViolet700,
              isPressed: _pressedKey == 3,
              onTap: () => _executeAction(3),
            ),
            8.height,
            // F4: Configuración
            _buildMainActionCard(
              icon: Icons.settings,
              title: 'Configuración',
              keyLabel: 'F4',
              color: spColorGrey600,
              isPressed: _pressedKey == 4,
              onTap: () => _executeAction(4),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainActionCard({
    required IconData icon,
    required String title,
    required String keyLabel,
    required Color color,
    required VoidCallback onTap,
    bool isPressed = false,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = isPressed ? _pulseAnimation.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity, // Ocupa todo el ancho disponible
              height: 80, // Altura más baja para formato de barra
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isPressed
                    ? color.withOpacity(0.1)
                    : (themeController.isDarkMode ? spCardDark : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isPressed
                      ? color.withOpacity(0.5)
                      : (Get.isDarkMode ? spColorGrey700 : spColorGrey300),
                  width: isPressed ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isPressed
                        ? color.withOpacity(0.3)
                        : color.withOpacity(0.1),
                    blurRadius: isPressed ? 15 : 8,
                    offset: Offset(0, isPressed ? 8 : 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 28,
                    ),
                  ),
                  16.width,
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: themeController.isDarkMode
                            ? Colors.white
                            : spTextColor,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      keyLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
