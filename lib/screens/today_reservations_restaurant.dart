import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_foodybite/util/user_service.dart';
import 'package:intl/intl.dart';

class TodayReservationsRestaurant extends StatefulWidget {
  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<TodayReservationsRestaurant> {
  TextEditingController _searchController = TextEditingController();
  String customerName = ""; // Variable para almacenar el nombre del cliente
  String? restaurantName; // Nombre del restaurante administrado por el usuario
  List<dynamic> _reservations = [];
  List<dynamic> _filteredReservations = [];
  bool _isLoading =
      true; // Controlador para saber si estamos cargando los datos

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserRestaurant();
    if (restaurantName != null) {
      await _loadReservations();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

          final adminUser = userData.firstWhere(
            (user) => user['username'] == username,
            orElse: () => null,
          );

          if (adminUser != null) {
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

  Future<void> _loadReservations() async {
    try {
      final directory = Directory.current;
      final filePath = '${directory.path}/reservations.json';
      final file = File(filePath);

      if (await file.exists()) {
        final fileContent = await file.readAsString();
        final data = json.decode(fileContent);

        DateTime today = DateTime.now();

        List<dynamic> reservationsForToday = [];
        for (var reservation in data) {
          DateTime date = DateTime.parse(reservation['date']);
          if (date.year == today.year &&
              date.month == today.month &&
              date.day == today.day &&
              reservation['restaurantName'] == restaurantName &&
              reservation['status'] == "Accepted") {
            reservationsForToday.add(reservation);
          }
        }

        reservationsForToday.sort((a, b) {
          DateTime timeA = _parseTime(a['time']);
          DateTime timeB = _parseTime(b['time']);
          return timeA.compareTo(timeB);
        });

        setState(() {
          _reservations = reservationsForToday;
          _filteredReservations = _reservations;
          _isLoading = false;
        });

        print("Reservas de hoy: ${_reservations.length}");
      } else {
        setState(() {
          _reservations = [];
          _filteredReservations = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error al cargar las reservas: $e");
    }
  }

  DateTime _parseTime(String time) {
    DateFormat dateFormat = DateFormat("h:mm a");
    DateTime now = DateTime.now();
    return dateFormat.parse('${now.year}-${now.month}-${now.day} $time');
  }

  void _filterReservations() {
    setState(() {
      _filteredReservations = _reservations
          .where((reservation) => reservation['name']
              .toLowerCase()
              .contains(customerName.toLowerCase()))
          .toList();

      _filteredReservations.sort((a, b) {
        DateTime timeA = _parseTime(a['time']);
        DateTime timeB = _parseTime(b['time']);
        return timeA.compareTo(timeB);
      });
    });
  }

  bool _isValidUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String suffix = 'th';
    int day = dateTime.day;
    if (day == 1 || day == 21 || day == 31) suffix = 'st';
    if (day == 2 || day == 22) suffix = 'nd';
    if (day == 3 || day == 23) suffix = 'rd';
    return DateFormat("MMMM d'$suffix', yyyy").format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Reservations'.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  customerName = value;
                });
                _filterReservations();
              },
            ),
          ),
          SizedBox(height: 5.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Today: ${formatDate(DateTime.now().toString())}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredReservations.isEmpty
                    ? const Center(
                        child: Text("No reservations found for today"))
                    : ListView.builder(
                        itemCount: _filteredReservations.length,
                        itemBuilder: (context, index) {
                          var reservation = _filteredReservations[index];
                          bool isAssisted = false;

                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            color: Colors.white, // Color de la tarjeta
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16.0),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        reservation['name'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      SizedBox(width: 15),
                                      Icon(Icons.people, color: Colors.green),
                                      SizedBox(width: 15),
                                      Text(
                                        '${reservation['people']}',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      SizedBox(width: 15),
                                      Icon(Icons.access_time,
                                          color: Colors.green, size: 18),
                                      SizedBox(width: 15),
                                      Text(
                                        '${reservation['time']}',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
