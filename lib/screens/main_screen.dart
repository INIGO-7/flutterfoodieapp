import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/add.dart';
import 'package:flutter_foodybite/screens/home.dart';
import 'package:flutter_foodybite/screens/label.dart';
import 'package:flutter_foodybite/screens/profile.dart';
import 'package:flutter_foodybite/screens/reservations.dart';
import 'package:flutter_foodybite/screens/reservations_agenda.dart';

import 'notifications.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  PageController _pageController = PageController();
  int _page = 0;

  List icons = [
    Icons.home,
    Icons.calendar_month_outlined,
    Icons.add,
    Icons.notifications,
    Icons.person,
  ];

  List pages = [
    Home(),
    //Label(),
    ReservationsScreen(),
    ReservationScreen(restaurantName: "NEW RESTAURANT", restaurantAddress: "Dr.-Gessler-Strasse 15B", restaurantImage: "https://cdn-icons-png.flaticon.com/512/6643/6643359.png",),
    Notifications(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: List.generate(5, (index) =>  pages[index]),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            buildTabIcon(0),
            buildTabIcon(1),
            buildTabIcon(3),
            buildTabIcon(4),
          ],
        ),
        color: Theme.of(context).primaryColor,
        shape: CircularNotchedRectangle(),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        elevation: 10.0,
        child: Icon(Icons.add),
        onPressed: () => _pageController.jumpToPage(2),
        shape: CircleBorder(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  buildTabIcon(int index) {
    // Ajuste para centrar el ícono y hacerlo más consistente en altura
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0), // Asegura que todos estén alineados a la misma altura
      child: IconButton(
        icon: Icon(
          icons[index],
          size: 28.0, // Ajuste del tamaño para hacer que los íconos se vean uniformes
        ),
        color: _page == index
            ? Theme.of(context).colorScheme.secondary // Ícono seleccionado con color diferente
            : Theme.of(context).colorScheme.primary, // Ícono no seleccionado con color base
        onPressed: () => _pageController.jumpToPage(index),
      ),
    );
  }
}
