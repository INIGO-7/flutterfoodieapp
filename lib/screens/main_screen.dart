import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/reviews.dart';
import 'package:flutter_foodybite/screens/home.dart';
import 'package:flutter_foodybite/screens/login.dart';
import 'package:flutter_foodybite/screens/profile.dart';
import 'package:flutter_foodybite/screens/reservations_agenda.dart';
import 'package:flutter_foodybite/screens/notifications.dart';
import 'package:flutter_foodybite/screens/today_reservations_restaurant.dart';
import 'package:flutter_foodybite/screens/manage_reservation_requests.dart';

class MainScreen extends StatefulWidget {
  final bool isLogged;
  final String userType;

  MainScreen({required this.isLogged, required this.userType});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PageController _pageController = PageController();
  int _page = 0;

  List<IconData> userIcons = [
    Icons.home,
    Icons.calendar_month_outlined,
    Icons.star,
    Icons.notifications,
    Icons.person,
  ];

  List<IconData> restaurantIcons = [
    Icons.home, // Reservas del día
    Icons.edit_calendar_outlined, // Gestionar solicitudes de reserva
    Icons.person,
  ];

  // Definir las pantallas dependiendo del tipo de usuario
  List<Widget> userPages = [
    Home(),
    ReservationsScreen(),
    ReviewScreen(),
    Notifications(),
    LoginScreen(),
    Profile(),
  ];

  List<Widget> restaurantPages = [
    TodayReservationsRestaurant(), // Pantalla de reservas del día
    ManageReservationRequests(), // Pantalla para gestionar solicitudes de reserva
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: widget.userType == 'restaurant'
            ? restaurantPages
            : userPages,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.userType == 'restaurant' ? 3 : 5, (index) => buildTabIcon(index)),
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
        index < (widget.userType == 'restaurant' ? 3 : 5)
            ? (widget.userType == 'restaurant' ? restaurantIcons[index] : userIcons[index])
            : Icons.person, // El icono de perfil es común
        size: 27.0,
      ),
      color: _page == index || (index == 4 && _page == 5)
          ? Colors.white
          : Colors.grey.shade400,
      onPressed: () {
        // Si el icono seleccionado es el de perfil
        if (index == (widget.userType == 'restaurant' ? 2 : 4)) {
          if (!widget.isLogged) {
            // Si el usuario no está logueado, lleva al login
            _pageController.jumpToPage(widget.userType == 'restaurant' ? 2 : 4); // Página de login
          } else {
            // Si está logueado, lleva al perfil
            _pageController.jumpToPage(widget.userType == 'restaurant' ? 2 : 5); // Página de perfil
          }
        } else {
          // Si no es el icono de perfil, navega a la página correspondiente
          _pageController.jumpToPage(index);
        }
      },
    );
  }
}
