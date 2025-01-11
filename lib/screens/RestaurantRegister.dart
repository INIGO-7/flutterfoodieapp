import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
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
  final TextEditingController foodTypeController = TextEditingController();
  final TextEditingController openingTimeController = TextEditingController();
  final TextEditingController closingTimeController = TextEditingController();
  final TextEditingController adminNameController = TextEditingController();
  final TextEditingController adminPasswordController = TextEditingController();

  final String filePath = 'assets/restaurants_data.json';

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
      // Handle error if necessary
      debugPrint('Error loading persisted restaurants: $e');
    }
  }

  Future<void> _persistRestaurants() async {
    try {
      final file = File(filePath);
      await file.writeAsString(jsonEncode(restaurants));
    } catch (e) {
      // Handle error if necessary
      debugPrint('Error persisting restaurants: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Restaurant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                controller: imgController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Image Path',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.photo_library),
                    onPressed: seleccionarImagen,
                  ),
                ),
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
              TextField(
                controller: foodTypeController,
                decoration: const InputDecoration(
                  labelText: 'Food Type',
                  hintText: 'e.g., Mexican',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: openingTimeController,
                decoration: const InputDecoration(
                  labelText: 'Opening Time',
                  hintText: 'e.g., 11:00',
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: closingTimeController,
                decoration: const InputDecoration(
                  labelText: 'Closing Time',
                  hintText: 'e.g., 22:00',
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final newRestaurant = {
                      "adminName": adminNameController.text,
                      "adminPassword": adminPasswordController.text,
                      "img": imgController.text,
                      "title": titleController.text,
                      "address": addressController.text,
                      "foodType": foodTypeController.text,
                      "openingTime": openingTimeController.text,
                      "closingTime": closingTimeController.text,
                    };

                    // Add new restaurant to the list
                    restaurants.add(newRestaurant);

                    // Persist restaurants
                    await _persistRestaurants();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Restaurant data saved successfully!'),
                      ),
                    );
                  },
                  child: const Text('Save Restaurant Data'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
