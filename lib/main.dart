import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruword/theme.dart' as theme;
import 'package:ruword/bindings/initial_binding.dart';
import 'package:ruword/pages/game_page.dart';
import 'package:ruword/pages/home_page.dart';

void main() {
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme.lightTheme,
    darkTheme: theme.darkTheme,
    themeMode: ThemeMode.system,
    initialBinding: InitialBinding(),
    initialRoute: '/',
    getPages: [
      GetPage(
        name: '/',
        page: () => const HomePage(),
      ),
      GetPage(
        name: '/game',
        page: () => GamePage(),
      ),
    ],
  ));
}
