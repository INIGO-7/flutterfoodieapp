import 'package:flutter/material.dart';
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
                title: Text(restaurantName),
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
                  // Rating Section
                  RatingSection(rating: averageRating),
                  
                  const SizedBox(height: 24),
                  
                  // Location Section (placeholder for Google Maps)
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LocationTile(location: location),
                  
                  // Placeholder for Google Maps
                  Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Google Maps will be implemented here'),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Reviews Section
                  const Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...reviews.map((review) => ReviewTile(review: review)),
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
            backgroundColor: Color(0xFF5563FF),
          ),
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      )
    );
  }
}