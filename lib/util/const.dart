import 'package:flutter/material.dart';

class Constants {
  static String appName = "Foody Bite";
  static Color lightPrimary = Color(0xfffcfcff);
  static Color darkPrimary = Colors.black;
  static Color lightAccent = Color.fromARGB(255, 85, 99, 255);
  static Color darkAccent = Color(0xff5563ff);
  static Color lightBG = Color(0xfffcfcff);
  static Color darkBG = Colors.black;
  static Color ratingBG = Color.fromARGB(255, 255, 218, 52);

  static ThemeData lightTheme = ThemeData(
    primaryColor: lightPrimary,
    colorScheme: ColorScheme.light(
      primary: lightPrimary,
      secondary: lightAccent,
      background: lightBG,
    ),
    scaffoldBackgroundColor: lightBG,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: lightAccent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightBG,
      titleTextStyle: TextStyle(
        color: darkBG,
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    colorScheme: ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkAccent,
      background: darkBG,
    ),
    scaffoldBackgroundColor: darkBG,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: darkAccent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBG,
      titleTextStyle: TextStyle(
        color: lightBG,
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
