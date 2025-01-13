import 'package:flutter/material.dart';
import 'package:flutter_foodybite/util/restaurants.dart';
import 'dart:convert';
import 'dart:io';
import '../util/user_service.dart';

class ReviewService {
  late final String _filePath;

  ReviewService() {
    _initializeFilePath();
  }

  final UserService _userService = UserService();

  void _initializeFilePath() {
    _filePath = '${Directory.current.path}/reviews.json';
    print('Path del archivo: $_filePath');
  }

  Future<List<Map<String, dynamic>>> loadReviews() async {
    try {
      final file = File(_filePath);
      if (!await file.exists()) {
        print('El archivo no existe. Creando uno vacío.');
        await file.writeAsString('[]');
        return [];
      }

      final content = await file.readAsString();
      //print('Contenido del archivo: $content');

      if (content.isEmpty) {
        print('El archivo está vacío.');
        return [];
      }

      final decoded = jsonDecode(content);
      print('Contenido decodificado: $decoded');

      if (decoded is List) {
        return List<Map<String, dynamic>>.from(
          decoded.map((e) => Map<String, dynamic>.from(e)),
        );
      } else {
        throw Exception("El contenido del archivo no es una lista.");
      }
    } catch (e) {
      print("Error al cargar reseñas: $e");
      return [];
    }
  }

  Future<void> _saveReviews(List<Map<String, dynamic>> reviews) async {
    try {
      final file = File(_filePath);
      print('Intentando guardar las reseñas: $reviews');
      final content = jsonEncode(reviews);

      await file.writeAsString(content);
      print('Reseñas guardadas correctamente en $_filePath');
    } catch (e) {
      print('Error al guardar las reseñas: $e');
      throw Exception("Error al guardar reseñas: $e");
    }
  }

  Future<void> addReview(
      String restaurant, String comment, double rating) async {
    try {
      final reviews = await loadReviews();
      print('Reviews cargadas: $reviews');

      String? username = await _userService.getLoggedUserName();
      final avatarPath =
          await _userService.getImagenPerfil(username ?? 'NoImagen');

      final newReview = {
        'restaurant': restaurant,
        'comment': comment,
        'rating': rating,
        'createdAt': DateTime.now().toIso8601String(),
        'username': username,
        'avatarPath': avatarPath
      };
      print('Nueva reseña: $newReview');

      reviews.add(newReview);
      await _saveReviews(reviews);
      print('Reseña guardada correctamente');
    } catch (e) {
      print('Error en addReview: $e');
      throw Exception('Error al agregar la reseña: $e');
    }
  }
}

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({Key? key}) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedRestaurant;
  double rating = 0.0;
  String? avatarPath;
  final TextEditingController reviewController = TextEditingController();
  final ReviewService reviewService = ReviewService();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    reviewController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Método para enviar la reseña
  Future<void> _submitReview(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (selectedRestaurant != null) {
        try {
          // Agregar la reseña
          await reviewService.addReview(
            selectedRestaurant!,
            reviewController.text,
            rating,
          );

          // Verificar si el widget sigue montado antes de mostrar el SnackBar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Review submitted successfully!')),
            );

            setState(() {
              selectedRestaurant = null;
              rating = 0.0;
              reviewController.clear();
            });
          }
        } catch (e) {
          // Verificar si el widget sigue montado antes de mostrar el SnackBar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a restaurant.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Previene regresar atrás
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rate Restaurants'),
          automaticallyImplyLeading: false, // Elimina la flecha de retroceso
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selección de restaurante
                const Text(
                  'Select a restaurant:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedRestaurant,
                  hint: const Text('Select a restaurant'),
                  items:
                      restaurants.map<DropdownMenuItem<String>>((restaurant) {
                    return DropdownMenuItem<String>(
                      value: restaurant['title'] as String,
                      child: Text(restaurant['title'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRestaurant = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select a restaurant' : null,
                ),
                const SizedBox(height: 16),

                // Sistema de calificación
                const Text(
                  'What rating would you give?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          rating = index + 1.0;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Campo de texto para la reseña
                const Text(
                  'Write your review:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: reviewController,
                  focusNode: _focusNode,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Write your experience here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.all(12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please write a review';
                    }
                    return null;
                  },
                ),
                const Spacer(),

                // Botón de envío
                ElevatedButton(
                  onPressed: () {
                    _submitReview(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5.0,
                  ),
                  child: const Text(
                    'Submit Your Review',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
