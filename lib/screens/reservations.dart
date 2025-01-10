import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ReservationScreen extends StatefulWidget {
  final String restaurantName;
  final String restaurantAddress;
  final String restaurantImage;

  ReservationScreen({
    required this.restaurantName,
    required this.restaurantAddress,
    required this.restaurantImage,
  });

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

      if (pickedDateTime.isAfter(now.add(Duration(minutes: 59)))) {
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
    final uuid = Uuid();
    final reservation = {
      'id': uuid.v4(),
      'restaurantName': widget.restaurantName,
      'restaurantAddress': widget.restaurantAddress,
      'restaurantImage': widget.restaurantImage,
      'name': nameController.text,
      'phone': phoneController.text,
      'people': peopleController.text,
      'comments': commentsController.text,
      'status': 'Pending',
      'date': selectedDate.toIso8601String(),
      'time': selectedTime.format(context),
    };

    final directory = Directory.current;
    final filePath = '${directory.path}/reservations.json';
    final file = File(filePath);

    List<Map<String, dynamic>> reservations = [];
    if (await file.exists()) {
      final fileContent = await file.readAsString();
      reservations = List<Map<String, dynamic>>.from(json.decode(fileContent));
    }

    reservations.add(reservation);

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
    final String imageUrl = widget.restaurantImage;
    final String location = widget.restaurantAddress;

    return Scaffold(
      appBar: AppBar(
        title: Text("Reserve a Table at ${widget.restaurantName}"),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.3,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    // Primero los campos de fecha y hora
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

                    // Luego los campos de nombre, teléfono, etc.
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Your Name'),
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: 'Your Phone'),
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: TextField(
                            controller: peopleController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(labelText: 'Nº People'),
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
                    SizedBox(height: 10),
                    TextField(
                      controller: commentsController,
                      decoration: InputDecoration(labelText: 'Any Comments?'),
                      //maxLines: 3,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: (nameController.text.isNotEmpty &&
                              phoneController.text.isNotEmpty)
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
                                      _buildInfoRow("DAY",
                                        '${formatDateWithSuffix(selectedDate)}'),
                                      SizedBox(height: 10),
                                      _buildInfoRow("TIME",
                                          selectedTime.format(context)),
                                      SizedBox(height: 10),
                                      _buildInfoRow(
                                          "AMOUNT OF PEOPLE",
                                          peopleController.text),
                                      SizedBox(height: 10),
                                      _buildInfoRow(
                                          "NAME OF WHO IS RESERVING",
                                          nameController.text),
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
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          backgroundColor: Colors.teal,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
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
                    SizedBox(height: 30,)
                  ],
                ),
              ),
            ]),
          ),
        ],
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
