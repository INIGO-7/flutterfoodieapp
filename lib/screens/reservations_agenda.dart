import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'reserva_detail.dart';

class ReservationsScreen extends StatefulWidget {
  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<dynamic> reservations = [];
  bool isLoggedIn = true;

  @override
  void initState() {
    super.initState();
    loadReservations();
  }

  Future<void> loadReservations() async {
    final directory = Directory.current;
    final filePath = '${directory.path}/reservations.json';
    final file = File(filePath);

    if (await file.exists()) {
      final fileContent = await file.readAsString();
      final data = json.decode(fileContent);

      // Truncar la hora actual al inicio del día
      DateTime today = DateTime.now();
      DateTime startOfToday = DateTime(today.year, today.month, today.day);

      setState(() {
        reservations = data.where((reservation) {
          DateTime date = DateTime.parse(reservation['date'].split('T')[0]);
          return date.isAfter(startOfToday) || date.isAtSameMomentAs(startOfToday);
        }).toList();

        // Ordenar las reservas por fecha y hora
        reservations.sort((a, b) {
          DateTime dateA = DateTime.parse(a['date']);
          DateTime dateB = DateTime.parse(b['date']);
          // Primero ordenamos por fecha
          int dateComparison = dateA.compareTo(dateB);
          if (dateComparison != 0) {
            return dateComparison;
          }
          // Si las fechas son iguales, ordenamos por hora
          return compareTime(a['time'], b['time']);
        });
      });
    } else {
      setState(() {
        reservations = [];
      });
    }
  }


  Future<void> _cancelReservation(String reservationId) async {
    final directory = Directory.current;
    final filePath = '${directory.path}/reservations.json';
    final file = File(filePath);

    if (await file.exists()) {
      final fileContent = await file.readAsString();
      List<dynamic> data = json.decode(fileContent);

      // Filtrar las reservas para eliminar la correspondiente por su ID
      data.removeWhere((reservation) => reservation['id'] == reservationId);

      // Guardar los cambios nuevamente en el archivo
      await file.writeAsString(json.encode(data));

      print('Reservation with ID $reservationId has been cancelled');
    }
  }

  String getSafeString(Map<String, dynamic> reservation, String key, {String defaultValue = 'N/A'}) {
    return reservation[key] ?? defaultValue;
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString.split('T')[0]);
    DateFormat formatter = DateFormat('MM/dd/yyyy');
    return formatter.format(dateTime);
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
              Text('You must be logged in to view your reservations.', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    if (reservations.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Your Reservations')),
        body: Center(child: Text('You have no reservations pending.', style: TextStyle(fontSize: 16))),
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
      appBar: AppBar(title: Text('Your Reservations')),
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
                          builder: (context) => ReservaDetailScreen(reservation: reservation),
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
                                image: NetworkImage('https://cdn-icons-png.flaticon.com/512/6643/6643359.png'),
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
                                  getSafeString(reservation, 'restaurantName'),
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text('Time: ${getSafeString(reservation, 'time')}'),
                                Text('Status: ${getSafeString(reservation, 'status', defaultValue: 'Pending')}'),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Mostrar un diálogo de confirmación antes de cancelar
                              bool? confirmCancel = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Confirm Cancelation"),
                                    content: Text("Are you sure you want to cancel this reservation?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false); // Cancelar
                                        },
                                        child: Text("No"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true); // Confirmar cancelación
                                        },
                                        child: Text("Yes"),
                                      ),
                                    ],
                                  );
                                },
                              );

                              // Si el usuario confirma, eliminar la reserva
                              if (confirmCancel ?? false) {
                                String reservationId = reservation['id']; // Usar el ID de la reserva para buscarla
                                await _cancelReservation(reservationId); // Llamar a la función para cancelar
                                loadReservations(); // Volver a cargar las reservas después de la cancelación
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('Cancel', style: TextStyle(color: Colors.white)),
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
