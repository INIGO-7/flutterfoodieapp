import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import '../util/categories.dart';
import '../util/restaurants.dart';

class RestaurantRegister extends StatefulWidget {
  const RestaurantRegister({Key? key}) : super(key: key);

  @override
  _RestaurantRegisterState createState() => _RestaurantRegisterState();
}

class _RestaurantRegisterState extends State<RestaurantRegister> {
  final TextEditingController imgController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController openingTimeController = TextEditingController();
  final TextEditingController closingTimeController = TextEditingController();
  final TextEditingController adminNameController = TextEditingController();
  final TextEditingController adminPasswordController = TextEditingController();

  String? selectedCategory;
  Location? _selectedLocation;

  bool get _isFormValid =>
      imgController.text.isNotEmpty &&
      titleController.text.isNotEmpty &&
      addressController.text.isNotEmpty &&
      openingTimeController.text.isNotEmpty &&
      closingTimeController.text.isNotEmpty &&
      adminNameController.text.isNotEmpty &&
      adminPasswordController.text.isNotEmpty &&
      selectedCategory != null;

  Future<void> _getCoordinatesFromAddress() async {
    try {
      List<Location> locations =
          await locationFromAddress(addressController.text);
      if (locations.isNotEmpty) {
        _selectedLocation = locations.first;
      }
    } catch (e) {
      print('Error al obtener coordenadas: $e');
    }
  }

  Future<void> _saveData() async {
    // Guardar en restaurants_data.json
    final restaurantData = {
      "img": imgController.text,
      "title": titleController.text,
      "address": addressController.text,
      "rating": "0.0",
      "foodType": selectedCategory,
      "openingTime": openingTimeController.text,
      "closingTime": closingTimeController.text,
      "latitude": _selectedLocation?.latitude.toString() ?? "0.0",
      "longitude": _selectedLocation?.longitude.toString() ?? "0.0",
    };

    final directory = Directory.current;
    final restaurantFile =
        File('${directory.path}/assets/restaurants_data.json');
    List<dynamic> restaurantList = [];
    if (await restaurantFile.exists()) {
      restaurantList = jsonDecode(await restaurantFile.readAsString());
    }
    restaurantList.add(restaurantData);
    await restaurantFile.writeAsString(jsonEncode(restaurantList));

    // Guardar en users.json
    final userData = {
      "username": adminNameController.text,
      "password": adminPasswordController.text,
      "estado": "Restaurant",
      "profilePicture": imgController.text,
      "type": "restaurant",
      "restaurantAdmin": titleController.text,
    };

    final userFile = File('${directory.path}/users.json');
    List<dynamic> userList = [];
    if (await userFile.exists()) {
      userList = jsonDecode(await userFile.readAsString());
    }
    userList.add(userData);
    await userFile.writeAsString(jsonEncode(userList));
  }

  void seleccionarImagen() async {
    final imagenSeleccionada = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select an image for the restaurant'),
          content: SizedBox(
            height: 300.0,
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: List.generate(12, (index) {
                  final imageName =
                      'food${index + 1}.${index == 11 ? 'jpg' : 'jpeg'}';
                  final imagePath = 'assets/restaurant_photos/$imageName';
                  return ListTile(
                    leading: Image.asset(imagePath, width: 40, height: 40),
                    title: Text(imageName),
                    onTap: () => Navigator.of(context).pop(imagePath),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );

    if (imagenSeleccionada != null) {
      setState(() {
        imgController.text = imagenSeleccionada;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isOpeningTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.green, // Color principal del picker
            colorScheme: ColorScheme.light(
                primary: Colors.green), // Color del encabezado
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme
                  .primary, // Asegura que los botones sean legibles
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isOpeningTime) {
          openingTimeController.text = picked.format(context);
        } else {
          closingTimeController.text = picked.format(context);
        }
      });
    }
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Restaurant registered successfully!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to the home screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Register Restaurant'.toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: seleccionarImagen,
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundColor: Colors.green,
                        child: imgController.text.isEmpty
                            ? const Icon(Icons.restaurant,
                                size: 50.0, color: Colors.white)
                            : ClipOval(
                                child: Image.asset(
                                  imgController.text,
                                  fit: BoxFit.cover,
                                  width: 100.0,
                                  height: 100.0,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Tap to select an image',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              TextField(
                controller: adminNameController,
                decoration: const InputDecoration(
                  labelText: 'Admin Name',
                  hintText: 'e.g., John Doe',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: adminPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Admin Password',
                  hintText: 'Enter a secure password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Restaurant Name',
                  hintText: 'e.g., Fiesta Mexicana',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText:
                      'e.g., 1278 Loving Acres Road, Kansas City, MO 64110',
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Food Type',
                  hintText: 'Select a food type',
                ),
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['name'],
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context, true),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: openingTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Opening Time',
                            hintText: 'Select opening time',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context, false),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: closingTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Closing Time',
                            hintText: 'Select closing time',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.6, // 60% del ancho de la pantalla
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5.0,
                    ),
                    onPressed: _isFormValid
                        ? () async {
                            await _getCoordinatesFromAddress();
                            await _saveData();
                            _showSuccessDialog();
                          }
                        : null,
                    child: const Text(
                      'Register Restaurant',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
