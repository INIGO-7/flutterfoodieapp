import 'package:flutter/material.dart';
import 'package:flutter_foodybite/widgets/trending_item.dart';
import 'restaurant_screen.dart';
import 'package:flutter_foodybite/util/review_service.dart';
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
        elevation: 0.0,
        title: Text("Trending Restaurants"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 10.0,
        ),
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
                final reviews = reviewsByRestaurant[title] ?? [];
                final rating = restaurantRatings[title] ?? 0.0;

                //TODO: make this work with the
                // final reviews = (reviews['reviews'] as List).map((review) => Review(
                //   reviewerName: review['reviewerName'] as String,
                //   rating: review['rating'] as double,
                //   comment: review['comment'] as String,
                //   avatarPath: review['avatarPath'] as String          
                // )).toList();

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantScreen(
                          restaurantName: title!,
                          //TODO: edit this to work
                          imageUrl: '',
                          reviews: [],
                          latitude: 0.0,
                          longitude: 0.0,
                          address: ''
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
