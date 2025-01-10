import 'package:flutter/material.dart';

class Constants {
  static String appName = "Foody Bite";
  static Color lightPrimary = Colors.green;
  static Color darkPrimary = Colors.black;
  static Color lightAccent = Color(0xff5563ff);
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
      onPrimary: darkPrimary,  // Color del texto en elementos primarios
      onSecondary: darkPrimary, // Color del texto en elementos secundarios
      onBackground: darkPrimary, // Color del texto en fondo
    ),
    scaffoldBackgroundColor: lightBG,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: lightAccent,
      selectionColor: lightAccent.withOpacity(0.3), // Color de selección de texto
      selectionHandleColor: lightAccent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightBG,
      titleTextStyle: TextStyle(
        color: darkPrimary,  // Asegúrate de que el texto de la AppBar sea visible
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(
        color: darkPrimary,  // Iconos de la AppBar también deben ser visibles
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: darkPrimary),  // Estilo de texto normal
      bodyMedium: TextStyle(color: darkPrimary),  // Estilo de texto más pequeño
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: lightAccent,  // Color de fondo de los botones
      textTheme: ButtonTextTheme.primary,  // Color de texto de los botones
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    colorScheme: ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkAccent,
      background: darkBG,
      onPrimary: lightPrimary,  // Color del texto en elementos primarios
      onSecondary: lightPrimary, // Color del texto en elementos secundarios
      onBackground: lightPrimary, // Color del texto en fondo
    ),
    scaffoldBackgroundColor: darkBG,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: darkAccent,
      selectionColor: darkAccent.withOpacity(0.3), // Color de selección de texto
      selectionHandleColor: darkAccent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBG,
      titleTextStyle: TextStyle(
        color: lightBG,  // Asegúrate de que el texto de la AppBar sea visible
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(
        color: lightBG,  // Iconos de la AppBar también deben ser visibles
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: lightBG),  // Estilo de texto normal
      bodyMedium: TextStyle(color: lightBG),  // Estilo de texto más pequeño
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: darkAccent,  // Color de fondo de los botones
      textTheme: ButtonTextTheme.primary,  // Color de texto de los botones
    ),
  );
}
