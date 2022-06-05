import 'package:flutter/material.dart';

const colorSchemeSeed = Colors.indigo;

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: colorSchemeSeed,
  brightness: Brightness.light,
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: colorSchemeSeed,
  brightness: Brightness.dark,
);

final redLight = Colors.red.shade400;
final redDark = Colors.red.shade900;
final yellowLight = Colors.yellow.shade400;
final yellowDark = Colors.yellow.shade900;
final greenLight = Colors.green.shade400;
final greenDark = Colors.green.shade900;
