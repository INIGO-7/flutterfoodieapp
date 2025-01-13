import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/reserva_restaurante_detail.dart';
import 'package:flutter_foodybite/util/user_service.dart';

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
            print("Restaurante administrado por el usuario logeado: $restaurantName");
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

        print(data);

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
      return Image.network(imageUrl);
    } else {
      return Image.asset(imageUrl);
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
                        child: Text('No pending reservations.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child:Text('There are no reservations waiting for your approval at the moment.',
                            style: TextStyle(fontSize: 16, color: Colors.grey,),
                            textAlign: TextAlign.center,),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _reservations.length,
                  itemBuilder: (context, index) {
                    var reservation = _reservations[index];
                    print('*********************************************************************************************');
                    print(reservation);
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: _loadImage(reservation['restaurantImage']),
                        title: Text(reservation['restaurantName']),
                        subtitle: Text(
                            'Name: ${reservation['name']} - People: ${reservation['people']}'),
                        trailing: Text('Time: ${reservation['time']}'),
                        isThreeLine: true,
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
                      ),
                    );
                  },
                ),
    );
  }
}
