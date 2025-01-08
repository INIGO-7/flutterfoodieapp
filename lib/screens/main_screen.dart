import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/reviews.dart';
import 'package:flutter_foodybite/screens/home.dart';
import 'package:flutter_foodybite/screens/label.dart';
import 'package:flutter_foodybite/screens/profile.dart';
import 'package:flutter_foodybite/util/user_service.dart';
import 'notifications.dart';
import 'login.dart';

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
    Icons.label,
    Icons.star, // Ícono de estrella para las reseñas
    Icons.notifications,
    Icons.person,
  ];

  List<Widget> pages = [
    Home(),
    Label(),
    ReviewScreen(),
    Notifications(),
    Profile(),
    LoginScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isLogged
              ? 'Welcome ${LoginScreen.getUserName()}'
              : 'Guest Session',
        ),
      ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children:
            pages.sublist(0, 5), // Mostrar solo las 5 pestañas principales
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
        if (index == 4) {
          final isLogged = UserService().isUserLoggedIn();
          if (widget.isLogged)
            _pageController.jumpToPage(index);
          else
            _pageController.jumpToPage(5); // Cambiar a la página de Login
        } else {
          _pageController.jumpToPage(index);
        }
      },
    );
  }
}
