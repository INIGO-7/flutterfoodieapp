import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../util/app_constants.dart';

import '../widgets/rating_section.dart';
import '../util/review.dart';
import '../widgets/review_tile.dart';

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
  final String location;

  // Calculate average rating from reviews
  double get averageRating {
    if (reviews.isEmpty) return 0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
  }

  void _launchMaps(String location) async {
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$location');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25
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
                  
                  // Location Section (placeholder for Google Maps)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // Placeholder for Google Maps
                  GestureDetector(
                    onTap: () {
                      _launchMaps(location);
                    },
                    child: Container(
                      height: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppConstants.secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Google Maps will be implemented here'),
                      ),
                    ),
                  ),

                  LocationTile(location: location),
                  
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
              // TODO: Implement reservation functionality
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
      )
    );
  }
}