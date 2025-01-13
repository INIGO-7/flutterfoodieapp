import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/reserva_restaurante_detail.dart';

class ManageReservationRequests extends StatefulWidget {
  const ManageReservationRequests({Key? key}) : super(key: key);

  @override
  _ManageReservationRequestsState createState() =>
      _ManageReservationRequestsState();
}

class _ManageReservationRequestsState extends State<ManageReservationRequests> {
  List<dynamic> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  // Cargar las reservas desde el archivo JSON
  Future<void> _loadReservations() async {
    final directory = Directory.current;
    final filePath = '${directory.path}/reservations.json';
    final file = File(filePath);

    if (await file.exists()) {
      final fileContent = await file.readAsString();
      final data = json.decode(fileContent);

      // Filtrar las reservas con status 'Pending'
      List<dynamic> pendingReservations = data
          .where((reservation) => reservation['status'] == 'Pending')
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
        title: Text('Manage Reservation Requests'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _reservations.isEmpty
              ? Center(child: Text('No pending reservations.'))
              : ListView.builder(
                  itemCount: _reservations.length,
                  itemBuilder: (context, index) {
                    var reservation = _reservations[index];
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
