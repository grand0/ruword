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

const redLight = Colors.red;
final redDark = Colors.red.shade800;
const yellowLight = Colors.yellow;
final yellowDark = Colors.yellow.shade800;
const greenLight = Colors.green;
final greenDark = Colors.green.shade800;
