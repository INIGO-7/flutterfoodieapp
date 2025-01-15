import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/reserva_restaurante_detail.dart';
import 'package:flutter_foodybite/util/user_service.dart';
import 'package:intl/intl.dart';

class ManageReservationRequests extends StatefulWidget {
  const ManageReservationRequests({Key? key}) : super(key: key);

  @override
  _ManageReservationRequestsState createState() =>
      _ManageReservationRequestsState();
}

class _ManageReservationRequestsState extends State<ManageReservationRequests> {
  List<dynamic> _reservations = [];
  String? restaurantName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    await _loadUserRestaurant();
    await _loadReservations();
  }

  // Cargar el nombre del restaurante que administra el usuario logeado
  Future<void> _loadUserRestaurant() async {
    try {
      final UserService userServices = UserService();
      String? username = await userServices.getLoggedUserName();
      if (username != null) {
        final directory = Directory.current;
        final userFilePath = '${directory.path}/users.json';
        final userFile = File(userFilePath);

        if (await userFile.exists()) {
          final userContent = await userFile.readAsString();
          final userData = json.decode(userContent) as List<dynamic>;

          print(userData);

          // Encontrar al usuario logeado
          final adminUser = userData.firstWhere(
            (user) => user['username'] == username,
          );

          if (adminUser != null) {
            print(adminUser);
            restaurantName = adminUser['restaurantAdmin'];
            print(
                "Restaurante administrado por el usuario logeado: $restaurantName");
          }
        }
      }
    } catch (e) {
      print("Error al cargar el restaurante del usuario: $e");
    }
  }

  // Cargar las reservas desde el archivo JSON
  Future<void> _loadReservations() async {
    try {
      final directory = Directory.current;
      final filePath = '${directory.path}/reservations.json';
      final file = File(filePath);

      if (await file.exists()) {
        final fileContent = await file.readAsString();
        final data = json.decode(fileContent);

        List<dynamic> pendingReservations = data
            .where((reservation) =>
                reservation['status'] == 'Pending' &&
                reservation['restaurantName'] == restaurantName)
            .toList();

        setState(() {
          _reservations = pendingReservations;
          _isLoading = false;
        });
      } else {
        setState(() {
          _reservations = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading reservations: $e");
      setState(() {
        _reservations = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _updateReservationStatus(String id, String newStatus) async {
    final directory = Directory.current;

    final reservationsPath = '${directory.path}/reservations.json';
    final reservationsFile = File(reservationsPath);

    final notificationsPath = '${directory.path}/notifications.json';
    final notificationsFile = File(notificationsPath);

    if (await reservationsFile.exists() && await notificationsFile.exists()) {
      final reservationsFileContent = await reservationsFile.readAsString();
      final notificationsFileContent = await notificationsFile.readAsString();

      final reservationsData = json.decode(reservationsFileContent) as List<dynamic>;
      final notificationsData = json.decode(notificationsFileContent) as List<dynamic>;

      // Update reservation and add notification
      for (var reservation in reservationsData) {
        if (reservation['id'] == id) {
          reservation['status'] = newStatus;

          final notification = {
            "id": DateTime.now().millisecondsSinceEpoch.toString(),
            "receiver": reservation['user'], // Fix: Access fields from the matched reservation
            "sender": reservation['restaurantName'],
            "message": newStatus == 'Accepted'
                ? "We're glad to confirm that your reservation HAS BEEN ACCEPTED!"
                : "Unfortunately, we have to communicate that your reservation HAS BEEN REJECTED."
          };

          notificationsData.add(notification);
          break;
        }
      }

      // Save updated files
      await reservationsFile.writeAsString(json.encode(reservationsData), flush: true);
      await notificationsFile.writeAsString(json.encode(notificationsData), flush: true);

      // Reload reservations
      _loadReservations();
    }
  }

  // Función para mostrar la imagen según el tipo de fuente (Internet o Asset)
  Widget _loadImage(String imageUrl) {
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return Image.network(imageUrl, fit: BoxFit.cover, height: 100.0);
    } else {
      return Image.asset(imageUrl, fit: BoxFit.cover, height: 100.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Manage Reservation'.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _reservations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text('No pending reservations.',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'There are no reservations waiting for your approval at the moment.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _reservations.length,
                  itemBuilder: (context, index) {
                    var reservation = _reservations[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReservationDetailScreen(
                              reservation: reservation,
                              onStatusChange: (String id, String status) async {
                                await _updateReservationStatus(id, status);
                              },
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Reservation for ${reservation['name']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Colors.green, size: 18),
                                  SizedBox(width: 5),
                                  Text('${formatDate(reservation['date'])}'),
                                ],
                              ),
                              SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      color: Colors.green, size: 18),
                                  SizedBox(width: 5),
                                  Text('${reservation['time']}'),
                                ],
                              ),
                              SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Icon(Icons.people,
                                      color: Colors.green, size: 18),
                                  SizedBox(width: 5),
                                  Text('${reservation['people']}'),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon:
                                Icon(Icons.arrow_forward, color: Colors.green),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReservationDetailScreen(
                                    reservation: reservation,
                                    onStatusChange:
                                        (String id, String status) async {
                                      await _updateReservationStatus(
                                          id, status);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // Helper to format date
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String suffix = 'th';
    int day = dateTime.day;
    if (day == 1 || day == 21 || day == 31) suffix = 'st';
    if (day == 2 || day == 22) suffix = 'nd';
    if (day == 3 || day == 23) suffix = 'rd';
    return DateFormat("MMMM d'$suffix', yyyy").format(dateTime);
  }
}
