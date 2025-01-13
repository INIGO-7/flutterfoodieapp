import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_foodybite/util/categories.dart';
import 'package:geocoding/geocoding.dart';  // Importar el paquete geocoding

import '../util/restaurants.dart'; // Asegúrate de que la ruta sea correcta

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

  final String filePath = 'assets/restaurants_data.json';

  String? selectedCategory;
  Location? _selectedLocation;  // Para almacenar las coordenadas obtenidas

  @override
  void initState() {
    super.initState();
    _loadPersistedRestaurants();
  }

  Future<void> _loadPersistedRestaurants() async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonData = jsonDecode(contents);
        restaurants.clear();
        restaurants.addAll(jsonData.map((data) => Map<String, String>.from(data)));
      }
    } catch (e) {
      debugPrint('Error loading persisted restaurants: $e');
    }
  }

  Future<void> _persistRestaurants() async {
    try {
      final file = File(filePath);
      await file.writeAsString(jsonEncode(restaurants));
    } catch (e) {
      debugPrint('Error persisting restaurants: $e');
    }
  }

  // Función para obtener las coordenadas de la dirección
  Future<void> _getCoordinatesFromAddress() async {
    print(addressController.text);
    try {
      List<Location> locations = await locationFromAddress(addressController.text);
      print(locations);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        setState(() {
          _selectedLocation = location;  // Guardar la ubicación seleccionada
        });
        print('Lat: ${location.latitude}, Lng: ${location.longitude}');
      } else {
        print('No se encontró la dirección.');
      }
    } catch (e) {
      print('Error al obtener coordenadas: $e');
    }
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
                  final imageName = 'food${index + 1}.${index == 11 ? 'jpg' : 'jpeg'}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Register Restaurant',
          style: TextStyle(color: Colors.white),
        ),
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
                            ? const Icon(Icons.restaurant, size: 50.0, color: Colors.white)
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
                  hintText: 'e.g., 1278 Loving Acres Road, Kansas City, MO 64110',
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
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                  ),
                  onPressed: () async {
                    await _getCoordinatesFromAddress();
                    print(_selectedLocation?.latitude.toString());
                    print(_selectedLocation?.longitude.toString());
                    final newRestaurant = {
                      "adminName": adminNameController.text,
                      "adminPassword": adminPasswordController.text,
                      "img": imgController.text,
                      "title": titleController.text,
                      "address": addressController.text,
                      "foodType": selectedCategory ?? '',
                      "openingTime": openingTimeController.text,
                      "closingTime": closingTimeController.text,
                      "latitude": _selectedLocation?.latitude.toString() ?? "0.0",  // Guardar la latitud
                      "longitude": _selectedLocation?.longitude.toString() ?? "0.0",  // Guardar la longitud
                    };

                    print(newRestaurant);

                    restaurants.add(newRestaurant);

                    print(restaurants);

                    await _persistRestaurants();
                  },
                  child: const Text(
                    'Save Restaurant Data',
                    style: TextStyle(color: Colors.white),
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
