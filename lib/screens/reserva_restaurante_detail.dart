import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReservationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> reservation;
  final Function(String id, String status) onStatusChange;

  const ReservationDetailScreen({
    Key? key,
    required this.reservation,
    required this.onStatusChange,
  }) : super(key: key);

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
        title: Text('Reservation Details'.toUpperCase(), 
          style: TextStyle(
            color: Colors.white,),),
        centerTitle: true,
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(
          color: Colors.white, // Cambia el color de la flecha a blanco
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Reservation Details', // Formato de la fecha
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            SizedBox(height: 15.0,),

            // Fecha con ícono
            Row(
              children: [
                SizedBox(width: 15),
                Icon(Icons.calendar_today, color: Colors.green),
                SizedBox(width: 15),
                Text(
                  '${formatDate(reservation['date'])}',
                  style: TextStyle(fontSize: 18,),
                ),
              ],
            ),
            SizedBox(height: 10),
            
            // Hora con ícono
            Row(
              children: [
                SizedBox(width: 15),
                Icon(Icons.access_time, color: Colors.green),
                SizedBox(width: 15),
                Text(
                  '${reservation['time']}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Número de personas con ícono
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
            
            SizedBox(height: 10),
            Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Customer Information', // Formato de la fecha
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            SizedBox(height: 10.0,),
            
            // Nombre y teléfono del cliente
            Row(
              children: [
                SizedBox(width: 15),
                Icon(Icons.person, color: Colors.green),
                SizedBox(width: 15),
                Text(
                  '${reservation['name']}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 15,),
            
            Row(
              children: [
                SizedBox(width: 15),
                Icon(Icons.phone, color: Colors.green),
                SizedBox(width: 15),
                Text(
                  '${reservation['phone'] ?? 'No phone number'}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            
            SizedBox(height: 10),
            Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
            SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.all(1.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Comments', // Formato de la fecha
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            SizedBox(height: 10.0,),

            // Comentarios
            Text(
              '${reservation['comments'] ?? 'No comments'}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            
            SizedBox(height: 5),

            // Mensaje si no hay comentarios
            if (reservation['comments'] == null || reservation['comments']!.isEmpty)
              Center(
                child: Text(
                  'No comments',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ),
            
            SizedBox(height: 32),
            SizedBox(height: 10),
            Expanded(child: Divider(color: Colors.white, thickness: 0)),
            SizedBox(height: 10),

            // Botones intercambiados: Aceptar y Rechazar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await onStatusChange(reservation['id'], 'Rejected');
                    Navigator.pop(context);  // Regresar a la pantalla anterior
                  },
                  child: Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: Size(MediaQuery.of(context).size.width * 0.3, 0),
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5.0,  
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await onStatusChange(reservation['id'], 'Accepted');
                    Navigator.pop(context);  // Regresar a la pantalla anterior
                  },
                  child: Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: Size(MediaQuery.of(context).size.width * 0.3, 0),
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5.0,  
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }
}
