class Review {
  
  final String username;
  final String restaurant;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? avatarPath;

  const Review({
    required this.restaurant,
    required this.username,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.avatarPath,
  });

  // Método para crear una reseña desde un Map
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      restaurant: json['restaurant'],
      comment: json['comment'],
      rating: json['rating'],
      createdAt: DateTime.parse(
          json['createdAt']), // Convierte la fecha del JSON a DateTime
      username: json['username'], // Obtiene el nombre de usuario del JSON
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
      'username': username, // Agrega el nombre de usuario al JSON
    };
  }
}
