import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/login.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import necesario para SharedPreferences
import '../util/user_service.dart';
import 'reserva_detail.dart';

class ReservationsScreen extends StatefulWidget {
  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<dynamic> reservations = [];
  final UserService userService = UserService();
  bool isLoggedIn = false; // Valor inicial antes de verificar

  @override
  void initState() {
    super.initState();
    initializeScreen();
  }

  Future<void> initializeScreen() async {
    await checkLoginStatus(); // Verifica el estado de inicio de sesión
    if (isLoggedIn) {
      await loadReservations(); // Carga reservas solo si el usuario está logueado
    }
  }

  Future<void> checkLoginStatus() async {
    bool loggedInStatus = await userService.isUserLoggedIn(); // Llama a la función isUserLoggedIn
    setState(() {
      isLoggedIn = loggedInStatus;
    });
  }

  Future<void> loadReservations() async {
    final directory = Directory.current;
    final filePath = '${directory.path}/reservations.json';
    final file = File(filePath);

    if (await file.exists()) {
      final fileContent = await file.readAsString();
      final data = json.decode(fileContent);

      DateTime today = DateTime.now();
      DateTime startOfToday = DateTime(today.year, today.month, today.day);

      setState(() {
        reservations = data.where((reservation) {
          DateTime date = DateTime.parse(reservation['date'].split('T')[0]);
          return date.isAfter(startOfToday) || date.isAtSameMomentAs(startOfToday);
        }).toList();

        reservations.sort((a, b) {
          DateTime dateA = DateTime.parse(a['date']);
          DateTime dateB = DateTime.parse(b['date']);
          int dateComparison = dateA.compareTo(dateB);
          if (dateComparison != 0) {
            return dateComparison;
          }
          return compareTime(a['time'], b['time']);
        });
      });
    } else {
      setState(() {
        reservations = [];
      });
    }
  }

  String getSafeString(Map<String, dynamic> reservation, String key, {String defaultValue = 'N/A'}) {
    return reservation[key] ?? defaultValue;
  }

  String formatDisplayDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString.split('T')[0]);
    DateFormat formatter = DateFormat('MMMM dd, yyyy');
    String formattedDate = formatter.format(dateTime);

    DateTime now = DateTime.now();
    DateTime tomorrow = now.add(Duration(days: 1));

    if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
      return 'Today';
    } else if (dateTime.year == tomorrow.year && dateTime.month == tomorrow.month && dateTime.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      return formattedDate;
    }
  }

  int compareTime(String time1, String time2) {
    final format = DateFormat("h:mm a");
    DateTime parsedTime1 = format.parse(time1);
    DateTime parsedTime2 = format.parse(time2);
    return parsedTime1.compareTo(parsedTime2);
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: Text('Your Reservations')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center, // Asegura que el texto esté centrado
                child: Text(
                  'You must be logged in to view your reservations.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center, // Centra el texto dentro del widget
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()), // Asegúrate de importar LoginScreen
                ).then((_) {
                  checkLoginStatus();
                  if (isLoggedIn) {
                    loadReservations();
                  }
                });
                }, // Aquí deberías añadir la acción para iniciar sesión
                child: Text('Login'),
              ),
            ],
          ),
        ),
      );
    } else {
      if (reservations.isEmpty) {
        return Scaffold(
          appBar: AppBar(title: Text('Your Reservations')),
          body: Center(
            child: Text(
              'You have no reservations pending.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      }

      Map<String, List<dynamic>> groupedReservations = {};
      for (var reservation in reservations) {
        String date = getSafeString(reservation, 'date');
        String dateOnly = date.split('T')[0];
        if (!groupedReservations.containsKey(dateOnly)) {
          groupedReservations[dateOnly] = [];
        }
        groupedReservations[dateOnly]!.add(reservation);
      }

      groupedReservations.forEach((date, reservationsList) {
        reservationsList.sort((a, b) {
          return compareTime(a['time'], b['time']);
        });
      });

      return Scaffold(
        appBar: AppBar(
          title: const Text('Your Reservations'),
          automaticallyImplyLeading: false, // Elimina la flecha de retroceso
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body: ListView(
          children: groupedReservations.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    formatDisplayDate(entry.key),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Column(
                  children: entry.value.map<Widget>((reservation) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ReservaDetailScreen(reservation: reservation),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    getSafeString(reservation, 'restaurantImage')?.isNotEmpty ?? false
                                      ? getSafeString(reservation, 'restaurantImage')
                                      : 'https://chin-chin-bar.de/wp-content/uploads/2022/08/Beitragsbild-chin-chin-restaurant-regensburg.jpg',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getSafeString(
                                        reservation, 'restaurantName'),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      'Time: ${getSafeString(reservation, 'time')}'),
                                  Text(
                                      'Status: ${getSafeString(reservation, 'status', defaultValue: 'Pending')}'),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Implementar lógica de cancelación
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          }).toList(),
        ),
      );
    }
  }
}
