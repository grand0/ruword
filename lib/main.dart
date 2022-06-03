import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruword/bindings/initial_binding.dart';
import 'package:ruword/pages/home_page.dart';

void main() {
  runApp(GetMaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.light,
    ),
    darkTheme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.dark,
    ),
    themeMode: ThemeMode.system,
    initialBinding: InitialBinding(),
    initialRoute: '/',
    getPages: [
      GetPage(
        name: '/',
        page: () => const HomePage(),
      ),
    ],
  ));
}
