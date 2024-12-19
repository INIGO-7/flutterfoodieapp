import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/add.dart';
import 'package:flutter_foodybite/screens/home.dart';
import 'package:flutter_foodybite/screens/label.dart';
import 'package:flutter_foodybite/screens/profile.dart'; // Asegúrate de importar Profile

import 'package:flutter_foodybite/util/user_service.dart';
import 'notifications.dart';
import 'login.dart'; // Agregamos LoginScreen

class MainScreen extends StatefulWidget {
  final bool isLogged;  // Propiedad para almacenar el valor

  MainScreen({required this.isLogged});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PageController _pageController = PageController();
  int _page = 0;

  List icons = [
    Icons.home,
    Icons.label,
    Icons.add,
    Icons.notifications,
    Icons.person,
  ];

  List pages = [
    Home(),
    Label(),
    Add(),
    Notifications(),
    Profile(),
    LoginScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isLogged
              ? 'Welcome ${LoginScreen.getUserName()}'  // Llamar al método estático de LoginScreen
              : 'Guest Session',
        ),
      ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: List.generate(6, (index) => pages[index]),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            buildTabIcon(0),
            buildTabIcon(1),
            buildTabIcon(3),
            buildTabIcon(4), // Icono de Profile
          ],
        ),
        shape: CircularNotchedRectangle(),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade400,
        elevation: 10.0,
        child: Icon(
          Icons.add,
        ),
        onPressed: () => _pageController.jumpToPage(2),
      ),
    );
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  buildTabIcon(int index) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        index == 3 ? 30 : 0, 
        0, 
        index == 1 ? 30 : 0, 
        0),
      child: IconButton(
        icon: Icon(
          icons[index],
          size: 24.0,
        ),
        color: _page == index
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.primary,
        onPressed: () {
          if(index == 4){
            final isLogged = UserService().isUserLoggedIn();
            if(widget.isLogged) // Si está logueado
              _pageController.jumpToPage(index); // Cambiar al índice correspondiente
            else
              _pageController.jumpToPage(5); // Cambiar a la página de Login
          }
          else
            _pageController.jumpToPage(index); // Cambiar al índice correspondiente
        },
      ),
    );
  }
}
