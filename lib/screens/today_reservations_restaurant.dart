import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Importa intl para formatear la hora

class TodayReservationsRestaurant extends StatefulWidget {
  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<TodayReservationsRestaurant> {
  TextEditingController _searchController = TextEditingController();
  String customerName = "";  // Variable para almacenar el nombre del cliente
  List<dynamic> _reservations = [];
  List<dynamic> _filteredReservations = [];
  bool _isLoading = true;  // Controlador para saber si estamos cargando los datos

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  // Cargar las reservas desde un archivo JSON
  Future<void> _loadReservations() async {
    final directory = Directory.current;
    final filePath = '${directory.path}/reservations.json';
    final file = File(filePath);

    if (await file.exists()) {
      final fileContent = await file.readAsString();
      final data = json.decode(fileContent);

      DateTime today = DateTime.now();

      // Filtrar las reservas de hoy
      List<dynamic> reservationsForToday = [];
      for (var reservation in data) {
        DateTime date = DateTime.parse(reservation['date']);
        if (date.year == today.year && date.month == today.month && date.day == today.day && reservation['restaurantName'] == "NEW RESTAURANT" && reservation['status'] == "Accepted") {
          print("Reserva encontrada: ${reservation['name']} para ${reservation['restaurantName']} a las ${reservation['time']} con ${reservation['people']} personas");
          reservationsForToday.add(reservation);
        }
      }

      // Ordenar las reservas por hora
      reservationsForToday.sort((a, b) {
        DateTime timeA = _parseTime(a['time']);
        DateTime timeB = _parseTime(b['time']);
        return timeA.compareTo(timeB);
      });

      // Actualizar las reservas filtradas
      setState(() {
        _reservations = reservationsForToday;
        _filteredReservations = _reservations;
        _isLoading = false;  // Ya no estamos cargando
      });

      print("Reservas de hoy: ${_reservations.length}");  // Mostrar cuántas reservas fueron encontradas
    } else {
      setState(() {
        _reservations = [];
        _filteredReservations = [];
        _isLoading = false;  // Ya no estamos cargando
      });
    }
  }

  // Función para convertir la hora de formato AM/PM a DateTime
  DateTime _parseTime(String time) {
    DateFormat dateFormat = DateFormat("h:mm a");  // Formato de 12 horas con AM/PM
    DateTime now = DateTime.now();
    return dateFormat.parse('${now.year}-${now.month}-${now.day} $time');
  }

  // Filtrar las reservas por nombre del cliente
  void _filterReservations() {
    setState(() {
      _filteredReservations = _reservations
          .where((reservation) => reservation['name']
              .toLowerCase()
              .contains(customerName.toLowerCase()))  // Filtra por el nombre de la persona
          .toList();

      // Ordenar las reservas por hora
      _filteredReservations.sort((a, b) {
        DateTime timeA = _parseTime(a['time']);
        DateTime timeB = _parseTime(b['time']);
        return timeA.compareTo(timeB);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reservations"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  customerName = value;
                });
                _filterReservations();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())  // Mostrar cargando
                : _filteredReservations.isEmpty
                    ? Center(child: Text("No hay reservas registradas para hoy"))
                    : ListView.builder(
                        itemCount: _filteredReservations.length,
                        itemBuilder: (context, index) {
                          var reservation = _filteredReservations[index];
                          return Card(
                            margin: EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: Image.network(reservation['restaurantImage']),
                              title: Text(reservation['restaurantName']),
                              subtitle: Text(
                                'Name: ${reservation['name']} - ${reservation['people']} people',
                              ),
                              trailing: Text('Time: ${reservation['time']}'),
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
