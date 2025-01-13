import 'package:flutter/material.dart';
import 'package:flutter_foodybite/widgets/trending_item.dart';
import 'restaurant_screen.dart';
import 'package:flutter_foodybite/util/review_service.dart';
import 'package:flutter_foodybite/util/review.dart';
import 'package:flutter_foodybite/util/restaurants.dart';

class Trending extends StatefulWidget {
  @override
  _TrendingState createState() => _TrendingState();
}

class _TrendingState extends State<Trending> {
  final ReviewService _reviewService = ReviewService();
  Map<String, List<Map<String, dynamic>>> reviewsByRestaurant = {};
  Map<String, double> restaurantRatings = {};

  @override
  void initState() {
    super.initState();
    _loadReviewsAndRatings();
  }

  Future<void> _loadReviewsAndRatings() async {
    final reviews = await _reviewService.loadReviews();
    final Map<String, List<Map<String, dynamic>>> groupedReviews = {};
    final Map<String, List<double>> ratingsMap = {};

    for (var review in reviews) {
      final restaurant = review['restaurant'] as String;
      final rating = review['rating'] as double;

      if (!groupedReviews.containsKey(restaurant)) {
        groupedReviews[restaurant] = [];
      }
      groupedReviews[restaurant]?.add(review);

      if (!ratingsMap.containsKey(restaurant)) {
        ratingsMap[restaurant] = [];
      }
      ratingsMap[restaurant]?.add(rating);
    }

    final Map<String, double> computedRatings = {};
    ratingsMap.forEach((restaurant, ratings) {
      computedRatings[restaurant] =
          ratings.reduce((a, b) => a + b) / ratings.length;
    });

    setState(() {
      reviewsByRestaurant = groupedReviews;
      restaurantRatings = computedRatings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trending Restaurants'.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true, // Centra el texto
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10.0),
        child: ListView(
          children: [
            ListView.builder(
              primary: false,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: restaurants.length,
              itemBuilder: (BuildContext context, int index) {
                final restaurant = restaurants[index];
                final title = restaurant["title"];
                final rating = restaurantRatings[title] ?? 0.0;
                final imageUrl = restaurant["img"] ?? '';
                final address = restaurant["address"] ?? '';
                final latitude =
                    double.parse(restaurant["latitude"].toString());
                final longitude =
                    double.parse(restaurant["longitude"].toString());

                // Convertimos las reseñas de mapa a objetos Review
                final reviews = reviewsByRestaurant[title] ?? [];
                List<Review> reviewList = reviews.map((reviewMap) {
                  return Review(
                    username: reviewMap['username'],
                    restaurant: reviewMap['restaurant'],
                    rating: reviewMap['rating'],
                    comment: reviewMap['comment'],
                    avatarPath: reviewMap['avatarPath'],
                    createdAt: DateTime.parse(reviewMap['createdAt']),
                  );
                }).toList();

                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantScreen(
                            restaurantName: title!,
                            imageUrl: imageUrl,
                            location: {
                              'latitude': latitude,
                              'longitude': longitude,
                              'address': address,
                            },
                          ),
                        ),
                      );
                    },
                    child: TrendingItem(
                      img: imageUrl,
                      title: title!,
                      address: address,
                      rating: rating.toStringAsFixed(1),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
