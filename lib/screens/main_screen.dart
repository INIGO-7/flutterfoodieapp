import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/reviews.dart';
import 'package:flutter_foodybite/screens/home.dart';
import 'package:flutter_foodybite/screens/label.dart';

import '../screens/login.dart';
import 'package:flutter_foodybite/screens/profile.dart'; // Asegúrate de importar Profile
import 'package:flutter_foodybite/screens/profile.dart';
import 'package:flutter_foodybite/screens/reservations.dart';
import 'package:flutter_foodybite/screens/reservations_agenda.dart';

//import 'package:flutter_foodybite/util/user_service.dart';
import 'notifications.dart';

class MainScreen extends StatefulWidget {
  final bool isLogged;

  MainScreen({required this.isLogged});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PageController _pageController = PageController();
  int _page = 0;

  List icons = [
    Icons.home,
    Icons.calendar_month_outlined,
    Icons.star,
    Icons.notifications,
    Icons.person,
  ];

  List<Widget> pages = [
    Home(),
    ReservationsScreen(),
    ReviewScreen(),
    Notifications(),
    LoginScreen(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: Text(
          widget.isLogged
              ? 'Welcome ${LoginScreen.getUserName()}'
              : 'Guest Session',
        ),
      ),*/
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children:
            pages.sublist(0, 6), // Mostrar solo las 5 pestañas principales
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(icons.length, (index) => buildTabIcon(index)),
        ),
        shape: CircularNotchedRectangle(),
      ),
    );
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  buildTabIcon(int index) {
    return IconButton(
      icon: Icon(
        icons[index],
        size: 24.0,
      ),
      color: _page == index
          ? Theme.of(context).colorScheme.secondary
          : Theme.of(context).colorScheme.primary,
      onPressed: () {
        if (index == 4) { // Si el usuario hace clic en el ícono del perfil
          print("Hola");
          if (!widget.isLogged) { 
            // Si el usuario no está logueado, lleva al login
            _pageController.jumpToPage(4); // Índice de la pantalla de login
            print("Aqui llega");
          } else {
            // Si el usuario está logueado, lleva a la pantalla de perfil
            _pageController.jumpToPage(5); // Índice de la pantalla de perfil
          }
        } else {
          _pageController.jumpToPage(index); // Otras páginas
        }
      },
    );
  }
}