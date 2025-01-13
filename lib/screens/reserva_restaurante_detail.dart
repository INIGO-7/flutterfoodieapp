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
        title: Text('Reservation Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Restaurant: ${reservation['restaurantName']}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Date: ${formatDate(reservation['date'])}'),
            Text('Time: ${reservation['time']}'),
            Text('Number of people: ${reservation['people']}'),
            SizedBox(height: 16),
            Text(
              'Comments: ${reservation['comments'] ?? 'No comments'}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 32),
            if (reservation['comments'] == null || reservation['comments']!.isEmpty)
              Text(
                'No comments',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await onStatusChange(reservation['id'], 'Accepted');
                    Navigator.pop(context);  // Regresar a la pantalla anterior
                  },
                  child: Text('Accept'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await onStatusChange(reservation['id'], 'Rejected');
                    Navigator.pop(context);  // Regresar a la pantalla anterior
                  },
                  child: Text('Reject'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
