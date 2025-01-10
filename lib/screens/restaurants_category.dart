import 'package:flutter/material.dart';
import 'package:flutter_foodybite/widgets/trending_item.dart'; // Asegúrate de importar TrendingItem
import 'restaurant_details.dart'; // Asegúrate de importar RestaurantDetails
import 'package:flutter_foodybite/util/review_service.dart';

class RestaurantCategory extends StatefulWidget {
  final String categoryName;
  final List<Map<String, dynamic>> filteredRestaurants;

  RestaurantCategory(
      {required this.categoryName, required this.filteredRestaurants});

  @override
  _RestaurantCategoryState createState() => _RestaurantCategoryState();
}

class _RestaurantCategoryState extends State<RestaurantCategory> {
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
        elevation: 0.0,
        title: Text(widget.categoryName), // Mostrar el nombre de la categoría
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10.0),
        child: ListView(
          children: widget.filteredRestaurants.map((restaurant) {
            final title = restaurant["title"];
            final reviews = reviewsByRestaurant[title] ?? [];
            final rating = restaurantRatings[title] ?? 0.0;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantDetails(
                      img: restaurant["img"]!,
                      title: title!,
                      address: restaurant["address"]!,
                      rating: rating,
                      reviews: reviews,
                    ),
                  ),
                );
              },
              child: TrendingItem(
                img: restaurant["img"]!,
                title: title!,
                address: restaurant["address"]!,
                rating: rating.toStringAsFixed(1),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
