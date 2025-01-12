import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/main_screen.dart';
import 'package:flutter_foodybite/util/const.dart';
import 'package:flutter_foodybite/util/user_service.dart';
import 'package:window_size/window_size.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
void main() async {
  bool isLogged = false;
  UserService userService = UserService();
  userService.setUserLoggedIn(isLogged);

    // Establecer el tamaño de la ventana antes de ejecutar la app
  WidgetsFlutterBinding.ensureInitialized();
  setWindowTitle("Mi App Flutter");

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
      navigatorObservers: [routeObserver],
      title: Constants.appName,
      theme: Constants.lightTheme,
      darkTheme: Constants.darkTheme,
      home: MainScreen(isLogged : widget.isLogged), // Aquí puedes usar widget.isLogged si es necesario
    );
  }
}
