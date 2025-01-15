import 'dart:convert';
import 'dart:io';
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

  // Actualizar una reserva y recargar la lista
  Future<void> _updateReservationStatus(String id, String newStatus) async {
    final directory = Directory.current;
    final filePath = '${directory.path}/reservations.json';
    final file = File(filePath);

    if (await file.exists()) {
      final fileContent = await file.readAsString();
      final data = json.decode(fileContent);

      // Buscar la reserva por ID y actualizar su status
      for (var reservation in data) {
        if (reservation['id'] == id) {
          reservation['status'] = newStatus;
          break;
        }
      }

      // Guardar el archivo actualizado
      await file.writeAsString(json.encode(data), flush: true);

      // Recargar las reservas
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
