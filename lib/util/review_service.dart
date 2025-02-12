import 'dart:convert';
import 'dart:io';

import 'package:flutter_foodybite/util/review.dart';

class ReviewService {
  late final String _filePath;

  ReviewService() {
    _initializeFilePath();
  }

  void _initializeFilePath() {
    // Utilizar el directorio actual para desarrollo local o proyectos compartidos
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
      print('Contenido del archivo: $content');

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

      // Escribir el contenido en el archivo
      await file.writeAsString(content);
      print('Reseñas guardadas correctamente en $_filePath');
    } catch (e) {
      print('Error al guardar las reseñas: $e');
      throw Exception("Error al guardar reseñas: $e");
    }
  }

  Future<List<Review>> getReviewsByRestaurant(String restaurantName) async {
    try {
      final reviews = await loadReviews();
      print('Reseñas cargadas: $reviews');

      // Filtrar las reseñas que correspondan al restaurante
      final filteredReviews = reviews.where((review) {
        return review['restaurant'] == restaurantName;
      }).toList();

      // Convertir las reseñas filtradas a objetos de tipo Review
      final reviewList = filteredReviews.map((reviewJson) {
        return Review.fromJson(reviewJson);
      }).toList();

      return reviewList;
    } catch (e) {
      print("Error al obtener las reseñas del restaurante: $e");
      return [];
    }
  }

  Future<void> addReview(
      String restaurant, String comment, double rating, String username) async {
    try {
      final reviews = await loadReviews();
      print('Reviews cargadas: $reviews');

      final newReview = {
        'restaurant': restaurant,
        'comment': comment,
        'rating': rating,
        'username': username, // Incluye el nombre de usuario en la reseña
        'createdAt': DateTime.now().toIso8601String(),
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
