import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/reservations.dart';

import '../util/app_constants.dart';
import '../widgets/rating_section.dart';
import '../util/review.dart';
import '../widgets/review_tile.dart';
import '../widgets/osm_map.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({
    Key? key,
    required this.restaurantName,
    required this.imageUrl,
    required this.reviews,
    required this.location,
  }) : super(key: key);

  final String restaurantName;
  final String imageUrl;
  final List<Review> reviews;
  final Map<String, dynamic> location;

  double get averageRating {
    if (reviews.isEmpty) return 0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // App Bar with image
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  restaurantName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.white
                  ),
                ),
                background: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 10),
                  RatingSection(rating: averageRating),
                  const SizedBox(height: 14),
                  ReviewTile(reviews: reviews),

                  OSMMapContainer(
                    latitude: location['latitude'],
                    longitude: location['longitude'],
                    address: location['address']
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    child: LocationTile(location: location['address']),
                  ),

                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),

        // Floating Reservation Button
        floatingActionButton: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReservationScreen(
                    restaurantName: restaurantName, 
                    restaurantAddress: location['address'], 
                    restaurantImage: imageUrl
                  )
                ),
              );
            },
            label: const Text(
              'RESERVE NOW',
              style: TextStyle(color: Colors.black),
            ),
            icon: const Icon(Icons.calendar_today, color: Colors.black),
            backgroundColor: AppConstants.accentColor,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}