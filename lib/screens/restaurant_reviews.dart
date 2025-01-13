import 'package:flutter/material.dart';
import 'package:flutter_foodybite/util/review.dart';
import 'package:flutter_foodybite/util/review_service.dart';

class RestaurantReviewsScreen extends StatefulWidget {
  final String restaurantName;

  const RestaurantReviewsScreen({Key? key, required this.restaurantName})
      : super(key: key);

  @override
  _RestaurantReviewsScreenState createState() =>
      _RestaurantReviewsScreenState();
}

class _RestaurantReviewsScreenState extends State<RestaurantReviewsScreen> {
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _loadReviews();
  }

  Future<List<Review>> _loadReviews() async {
    final reviewService = ReviewService();
    final reviewsData = await reviewService.loadReviews();

    // Filtramos las reseñas donde el restaurante coincida con el actual
    final filteredReviews = reviewsData.where((reviewData) {
      return reviewData['restaurant'] == widget.restaurantName;
    }).toList();

    // Convertimos cada Map<String, dynamic> a un objeto Review
    return filteredReviews.map((reviewData) {
      return Review(
        restaurant: widget.restaurantName,
        username: reviewData['username'] as String,
        rating: reviewData['rating'] as double,
        comment: reviewData['comment'] as String,
        avatarPath: reviewData['avatarPath'] as String?,
        createdAt: DateTime.parse(reviewData['createdAt'] as String),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '${widget.restaurantName} Reviews'.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Review>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading reviews',
                style: TextStyle(color: Colors.grey[500]),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            final reviews = snapshot.data!;
            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return ReviewTileWithoutButton(reviews: [reviews[index]]);
              },
            );
          } else {
            return const Center(
              child: Text('No reviews available'),
            );
          }
        },
      ),
    );
  }
}

// ReviewTileWithoutButton widget definido dentro del mismo archivo
class ReviewTileWithoutButton extends StatelessWidget {
  final List<Review> reviews;

  const ReviewTileWithoutButton({
    Key? key,
    required this.reviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ordenamos las reseñas por rating en orden descendente y tomamos las dos principales
    final topReviews = (reviews..sort((a, b) => b.rating.compareTo(a.rating)))
        .take(2)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...topReviews.map((review) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4), // Reducido el padding inferior
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Alineación centrada
                      children: [
                        CircleAvatar(
                          radius: 27,
                          backgroundImage: review.avatarPath != null
                              ? AssetImage(review.avatarPath!)
                              : null,
                          child: review.avatarPath == null
                              ? Text(
                                  review.username[0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(
                            width: 16), // Espaciado horizontal reducido
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize
                                .min, // Minimiza la expansión innecesaria
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${review.username} - ${review.rating}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 3), // Espaciado reducido
                                  const Icon(Icons.star,
                                      color: Colors.yellow,
                                      size:
                                          18), // Icono de estrella más pequeño
                                ],
                              ),
                              const SizedBox(
                                  height:
                                      2), // Espaciado reducido entre nombre y comentario
                              Text(
                                review.comment,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (review != topReviews.last)
                    const Divider(
                      color: Colors.white,
                      height: 16, // Espaciado vertical reducido
                      thickness: 1,
                    ),
                ],
              )),
        ],
      ),
    );
  }
}
