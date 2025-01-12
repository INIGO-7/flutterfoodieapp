import 'package:flutter/material.dart';

class Constants {
  static String appName = "Foody Bite";
  static Color lightPrimary = Color.fromARGB(255, 64, 64, 65);
  static Color darkPrimary = Colors.black;
  static Color lightAccent = Color.fromARGB(255, 85, 99, 255);
  static Color darkAccent = Color(0xff5563ff);
  static Color lightBG = Colors.white;
  static Color darkBG = Colors.black;
  static Color ratingBG = Color.fromARGB(255, 255, 218, 52);

  static ThemeData lightTheme = ThemeData(
    primaryColor: lightPrimary,
    colorScheme: ColorScheme.light(
      primary: lightPrimary,
      secondary: lightAccent,
      onPrimary: darkPrimary, // Color del texto en elementos primarios
      onSecondary: darkPrimary, // Color del texto en elementos secundarios
      onSurface: darkPrimary, // Color del texto en fondo
      surface: lightBG,
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
        color:
            darkPrimary, // Asegúrate de que el texto de la AppBar sea visible
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(
        color: darkPrimary, // Iconos de la AppBar también deben ser visibles
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: darkPrimary), // Estilo de texto normal
      bodyMedium: TextStyle(color: darkPrimary), // Estilo de texto más pequeño
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
      onPrimary: lightPrimary, // Color del texto en elementos primarios
      onSecondary: lightPrimary, // Color del texto en elementos secundarios
      onSurface: lightPrimary, // Color del texto en fondo
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
        color: lightBG, // Asegúrate de que el texto de la AppBar sea visible
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(
        color: lightBG, // Iconos de la AppBar también deben ser visibles
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: lightBG), // Estilo de texto normal
      bodyMedium: TextStyle(color: lightBG), // Estilo de texto más pequeño
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: darkAccent, // Color de fondo de los botones
      textTheme: ButtonTextTheme.primary, // Color de texto de los botones
    ),
  );
}
