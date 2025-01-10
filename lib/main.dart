import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/main_screen.dart';
import 'package:flutter_foodybite/util/const.dart';

void main() async {
  bool isLogged = false;
  runApp(MyApp(isLogged: isLogged)); // Pasamos el argumento isLogged
}

class MyApp extends StatefulWidget {
  final bool isLogged;  // Declaramos una propiedad isLogged

  // Modificamos el constructor para aceptar el argumento isLogged
  MyApp({required this.isLogged});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.appName,
      theme: Constants.lightTheme,
      darkTheme: Constants.darkTheme,
      home: MainScreen(isLogged : widget.isLogged), // Aquí puedes usar widget.isLogged si es necesario
    );
  }
}
