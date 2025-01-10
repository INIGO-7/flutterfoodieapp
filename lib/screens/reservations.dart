import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ReservationScreen extends StatefulWidget {
  final String restaurantName;

  ReservationScreen({required this.restaurantName});

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(
    hour: DateTime.now().hour + 2,
    minute: DateTime.now().minute,
  );

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController peopleController = TextEditingController(text: "4");
  TextEditingController commentsController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      final now = DateTime.now();
      final pickedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        picked.hour,
        picked.minute,
      );

      if (pickedDateTime.isAfter(now.add(Duration(hours: 1)))) {
        setState(() {
          selectedTime = picked;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select a time at least 1 hour from now.")),
        );
      }
    }
  }

  Future<void> _saveReservation() async {
    // Instancia de Uuid
    final uuid = Uuid();

    // Crear reserva con un ID único
    final reservation = {
      'id': uuid.v4(), // Genera un ID único
      'restaurantName': widget.restaurantName,
      'restaurantAddress': widget.restaurantName, //Cambiar
      'name': nameController.text,
      'phone': phoneController.text,
      'people': peopleController.text,
      'comments': commentsController.text,
      'status': 'Pending',
      'date': selectedDate.toIso8601String(),
      'time': selectedTime.format(context),
    };

    // Directorio relativo al proyecto
    final directory = Directory.current;
    final filePath = '${directory.path}/reservations.json';
    final file = File(filePath);

    // Leer o crear el archivo
    List<Map<String, dynamic>> reservations = [];
    if (await file.exists()) {
      final fileContent = await file.readAsString();
      reservations = List<Map<String, dynamic>>.from(json.decode(fileContent));
    }

    // Agregar la nueva reserva
    reservations.add(reservation);

    // Guardar el archivo
    await file.writeAsString(json.encode(reservations));
    print('Reservation saved at: $filePath');
  }

  String formatDateWithSuffix(DateTime date) {
    String day = DateFormat('d').format(date);
    String suffix;

    if (day.endsWith('1') && !day.endsWith('11')) {
      suffix = 'st';
    } else if (day.endsWith('2') && !day.endsWith('12')) {
      suffix = 'nd';
    } else if (day.endsWith('3') && !day.endsWith('13')) {
      suffix = 'rd';
    } else {
      suffix = 'th';
    }

    return '${DateFormat('MMMM d').format(date)}$suffix, ${DateFormat('y').format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final isButtonEnabled = nameController.text.isNotEmpty && phoneController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text("Reserve a Table at ${widget.restaurantName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Your Name'),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Your Phone'),
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
            ),
            Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    int currentCount = int.tryParse(peopleController.text) ?? 1;
                    if (currentCount > 1) {
                      setState(() {
                        peopleController.text = (currentCount - 1).toString();
                      });
                    }
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: peopleController,
                    decoration: InputDecoration(labelText: 'Number of People'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    int currentCount = int.tryParse(peopleController.text) ?? 1;
                    if (currentCount < 12) {
                      setState(() {
                        peopleController.text = (currentCount + 1).toString();
                      });
                    }
                  },
                ),
              ],
            ),
            TextField(
              controller: commentsController,
              decoration: InputDecoration(labelText: 'Any Comments?'),
              maxLines: 3,
            ),
            SizedBox(height: 20),
          ListTile(
            title: Text(
              'Date: ${formatDateWithSuffix(selectedDate)}',
              style: TextStyle(color: Colors.black),
            ),
            trailing: Icon(Icons.calendar_today),
            onTap: () => _selectDate(context),
          ),
            ListTile(
              title: Text('Time: ${selectedTime.format(context)}'),
              trailing: Icon(Icons.access_time),
              onTap: () => _selectTime(context),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isButtonEnabled
                  ? () async {
                      await _saveReservation();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Center(
                            child: Text(
                              "RESERVATION REQUESTED",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Divider(),
                              SizedBox(height: 10),
                              _buildInfoRow("DAY", selectedDate.toLocal().toString().split(' ')[0]),
                              SizedBox(height: 10),
                              _buildInfoRow("TIME", selectedTime.format(context)),
                              SizedBox(height: 10),
                              _buildInfoRow("AMOUNT OF PEOPLE", peopleController.text),
                              SizedBox(height: 10),
                              _buildInfoRow("NAME OF WHO IS RESERVING", nameController.text),
                              SizedBox(height: 20),
                              Text(
                                "The reservation must be accepted by the restaurant. You will be notified whether it is accepted or not.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  backgroundColor: Colors.teal, // Color principal
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  //Navigator.pop(context);
                                },
                                child: Text(
                                  "OK",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  : null,
              child: Text('Confirm Reservation'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
