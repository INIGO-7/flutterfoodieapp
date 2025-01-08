class Review {
  final String restaurant; // El nombre o identificador del restaurante
  final String comment; // El comentario de la reseña
  final double rating; // La calificación
  final DateTime createdAt; // La fecha de creación de la reseña

  Review({
    required this.restaurant,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  // Método para crear una reseña desde un Map
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      restaurant: json['restaurant'],
      comment: json['comment'],
      rating: json['rating'],
      createdAt: DateTime.parse(
          json['createdAt']), // Convierte la fecha del JSON a DateTime
    );
  }

  // Método para convertir una reseña a un Map
  Map<String, dynamic> toJson() {
    return {
      'restaurant': restaurant,
      'comment': comment,
      'rating': rating,
      'createdAt':
          createdAt.toIso8601String(), // Convierte DateTime a String ISO 8601
    };
  }
}
