import 'package:flutter/material.dart';

class Constants {

  static String appName = "Foody Bite";

  // Backgrounds
  static Color lightBG = Colors.white;
  static Color darkBG = Colors.black;
  // Primary colors
  static Color lightPrimary = Color.fromARGB(255, 178, 220, 179);
  static Color darkPrimary = Color.fromARGB(255, 33, 33, 33);
  // Secondary colors
  // static Color lightSecondary = Color.fromARGB(255, 64, 64, 65);
  // static Color darkSecondary = Color.fromARGB(255, 33, 33, 33);
  // Accents
  static Color lightAccent = Colors.green;
  static Color darkAccent = Colors.green;
  static Color ratingBG = Color.fromARGB(255, 255, 218, 52);
  // Text colors
  static Color lightPrimaryText = Color.fromARGB(255, 64, 64, 64);
  static Color darkPrimaryText = Colors.white;
  static Color lightSecondaryText = Color.fromARGB(255, 113, 113, 113);
  static Color darkSecondaryText = Color.fromARGB(255, 170, 170, 170);
  // Text fonts
  static const TextStyle robotoFlexBlack = TextStyle(
    fontFamily: 'RobotoFlex', // Name from pubspec.yaml
    fontWeight: FontWeight.w600, // Heavy weight
    fontSize: 14,
  );

  static ThemeData lightTheme = ThemeData(
    primaryColor: lightPrimary,
    colorScheme: ColorScheme.light(
      primary: lightPrimary,
      secondary: lightAccent,
      onPrimary: lightPrimaryText, // Color del texto en elementos primarios
      onSecondary: lightSecondaryText, // Color del texto en elementos secundarios
      onSurface: lightSecondaryText, // Color del texto en fondo
      surface: lightBG
    ),
    scaffoldBackgroundColor: lightBG,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: lightAccent,
      selectionColor:
          lightAccent.withOpacity(0.3), // Color de selección de texto
      selectionHandleColor: lightAccent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightBG,
      titleTextStyle: TextStyle(
        color: lightPrimaryText, // Asegúrate de que el texto de la AppBar sea visible
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(
        color: lightPrimary, // Iconos de la AppBar también deben ser visibles
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: lightPrimaryText), // Estilo de texto normal
      bodyMedium: TextStyle(color: lightSecondaryText), // Estilo de texto más pequeño
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: lightAccent, // Color de fondo de los botones
      textTheme: ButtonTextTheme.primary, // Color de texto de los botones
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    colorScheme: ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkAccent,
      onPrimary: darkPrimaryText, // Color del texto en elementos primarios
      onSecondary: darkSecondaryText, // Color del texto en elementos secundarios
      onSurface: darkSecondaryText, // Color del texto en fondo
      surface: darkBG,
    ),
    scaffoldBackgroundColor: darkBG,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: darkAccent,
      selectionColor:
          darkAccent.withOpacity(0.3), // Color de selección de texto
      selectionHandleColor: darkAccent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBG,
      titleTextStyle: TextStyle(
        color: darkPrimaryText, // Asegúrate de que el texto de la AppBar sea visible
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(
        color: darkPrimary, // Iconos de la AppBar también deben ser visibles
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: darkPrimaryText), // Estilo de texto normal
      bodyMedium: TextStyle(color: darkSecondaryText), // Estilo de texto más pequeño
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: darkAccent, // Color de fondo de los botones
      textTheme: ButtonTextTheme.primary, // Color de texto de los botones
    ),
  );
}
