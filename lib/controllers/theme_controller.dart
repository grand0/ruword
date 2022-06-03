import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  var isLightTheme = true.obs;
  final _prefs = SharedPreferences.getInstance();

  @override
  void onInit() async {
    super.onInit();
    final prefs = await _prefs;
    isLightTheme.value = prefs.getBool('light_theme') ?? true;
    Get.changeThemeMode(isLightTheme.value ? ThemeMode.light  : ThemeMode.dark);
  }

  void switchTheme() {
    isLightTheme.toggle();
    Get.changeThemeMode(isLightTheme.value ? ThemeMode.light : ThemeMode.dark);
    _saveTheme();
  }

  void _saveTheme() async {
    final prefs = await _prefs;
    prefs.setBool('light_theme', isLightTheme.value);
  }
}