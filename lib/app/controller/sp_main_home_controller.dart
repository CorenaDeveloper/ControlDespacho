import 'package:sabipay/constant/sp_images.dart';
import 'package:sabipay/sabipy_theme/theme_controller.dart';
import 'package:sabipay/widgets/sp_animated_bottom_bar.dart';
import 'package:get/get.dart';

class SpMainHomeController extends GetxController {
  List<IconModel> list = [];

  @override
  void onInit() {
    // Nuevo menú: Inicio, Escaneo, Lista de Rutas, Perfil
    list.add(IconModel(
        id: 0,
        iconName: homeIcon,
        selectedIconName: homeSelectedIcon,
        name: 'Inicio'));

    list.add(IconModel(
        id: 1,
        iconName: scanIcon,
        selectedIconName: scanIcon, // Usar el mismo icono para seleccionado
        name: 'Escaner'));

    list.add(IconModel(
        id: 2,
        iconName:
            statisticIcon, // Reutilizamos el icono de estadísticas para "Lista de Rutas"
        selectedIconName: statisticSelectedIcon,
        name: 'Despachos'));

    list.add(IconModel(
        id: 3,
        iconName: profileIcon,
        selectedIconName: profileSelectedIcon,
        name: 'Perfil'));

    super.onInit();
  }

  RxInt currentIndex = 0.obs;

  void changeTabIndex(int index) {
    currentIndex.value = index;
  }

  ThemeController themeController = Get.put(ThemeController());
}
