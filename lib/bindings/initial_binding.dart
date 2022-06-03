import 'package:get/get.dart';
import 'package:ruword/controllers/theme_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController());
  }
}