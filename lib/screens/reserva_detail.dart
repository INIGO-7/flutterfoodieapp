import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ReservaDetailScreen extends StatelessWidget {
  final Map<String, dynamic> reservation;

  const ReservaDetailScreen({Key? key, required this.reservation}) : super(key: key);

  void _launchMaps(String location) async {
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$location');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
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
    final String restaurantName = reservation['restaurantName'] ?? 'Restaurant';
    final String imageUrl = reservation['restaurantImage'] ?? 
        'https://cdn-icons-png.flaticon.com/512/6643/6643359.png'; // URL de ejemplo
    final String location = reservation['restaurantAddress'] ?? 'East Side Gallery, Berlin';

    Widget imageWidget;
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      imageWidget = Image.network(imageUrl, fit: BoxFit.cover); // Imagen desde URL
    } else {
      imageWidget = Image.asset(imageUrl, fit: BoxFit.cover); // Imagen desde asset
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.4,
            pinned: true,
            leading: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // Fondo semitransparente
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5), // Fondo semitransparente
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: TextButton(
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
                                Navigator.pop(context);
                              }
                            },
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.red, fontSize: 15),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  imageWidget,
                  Container(
                    color: Colors.black.withOpacity(0.3), // Opacidad en la imagen
                  ),
                ],
              ),
              title: Text(
                restaurantName,
                style: const TextStyle(color: Colors.white),
              ),
              centerTitle: true, // Centrado del título
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([ 
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        restaurantName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(formatDate(reservation['date'] ?? '')),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(reservation['time'] ?? 'Not specified'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Number of people: ${reservation['people'] ?? 'Not specified'}'),
                    const SizedBox(height: 8),
                    // Comentarios
                    reservation['comments'] == null || reservation['comments'].trim().isEmpty
                        ? Center(
                            child: Text(
                              'No comments specified',
                              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                            ),
                          )
                        : Text('Comments: ${reservation['comments']}'),
                    const SizedBox(height: 8),
                    Text('Status: ${reservation['status'] ?? 'Pending'}'),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () => _launchMaps(location),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                location,
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
