import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/reservations.dart';
import 'package:flutter_foodybite/screens/reviews.dart';
import 'package:flutter_foodybite/util/review.dart';
import 'package:flutter_foodybite/widgets/location_tile.dart';

import '../util/user_service.dart';
import '../widgets/rating_section.dart';
import '../widgets/review_tile.dart';
import '../widgets/osm_map.dart';

class RestaurantScreen extends StatefulWidget {
  final String restaurantName;
  final String imageUrl;
  final List<Review>? reviews;
  final double latitude;
  final double longitude;
  final String address;

  const RestaurantScreen({
    Key? key,
    required this.restaurantName,
    required this.imageUrl,
    this.reviews,
    required this.latitude,
    required this.longitude,
    required this.address
  }) : super(key: key);

  @override
  _RestaurantScreenState createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  bool isLoggedIn = false;
  double? _averageRating;

  // Variable to store the Future of reviews
  Future<List<Review>>? _reviewsFuture;

  Future<void> _checkLoginStatus() async {
    final userService = UserService();
    bool loggedInStatus = await userService.isUserLoggedIn();
    setState(() {
      isLoggedIn = loggedInStatus;
    });
  }

  // Modified to return List<Review> instead of List<Map<String, dynamic>>
  Future<List<Review>> loadReviews() async {
    final reviewService = ReviewService();
    final reviewsData = await reviewService.loadReviews();

    // Filter reviews where restaurant matches the current restaurant
    final filteredReviews = reviewsData.where((reviewData) {
      return reviewData['restaurant'] ==
          widget.restaurantName; // Only keep reviews for the current restaurant
    }).toList();

    // Map each Map<String, dynamic> into a Review object
    return filteredReviews.map((reviewData) {
      return Review(
        restaurant: widget.restaurantName, // Use the restaurant name
        username: reviewData['username'] as String,
        rating: reviewData['rating'] as double,
        comment: reviewData['comment'] as String,
        avatarPath: reviewData['avatarPath'] as String,
        createdAt: DateTime.parse(reviewData['createdAt']
            as String), // Assuming createdAt is a string in the data
      );
    }).toList();
  }

  // Calculate the average rating
  Future<void> calculateAverageRating() async {
    List<Review> reviews = await loadReviews();

    if (reviews.isNotEmpty) {
      _averageRating =
          reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    } else {
      _averageRating = 0;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _reviewsFuture = loadReviews(); // Initialize the Future for reviews
    calculateAverageRating();
  }

  double get averageRating {
    return _averageRating ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // App Bar with image
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              iconTheme: IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.restaurantName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.white
                  ),
                ),
                background: Padding(
                  padding: const EdgeInsets.all(10), // 10px padding all around
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15), // rounded corners
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.2),
                        BlendMode.darken,
                      ),
                      child: Image.asset(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([ 
                  // Add space
                  const SizedBox(height: 10),
                  // Rating section with avg stars visualization and text
                  RatingSection(rating: averageRating),
                  // More space
                  const SizedBox(height: 14),
                  // FutureBuilder for loading reviews
                  FutureBuilder<List<Review>>(
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
                        return ReviewTile(reviews: reviews);
                      } else {
                        return const Center(
                          child: Text('No reviews available'),
                        );
                      }
                    },
                  ),
                  OSMMapContainer(
                    latitude: widget.latitude,
                    longitude: widget.longitude,
                    address: widget.address
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    child: LocationTile(location: widget.address)
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),

        // Floating Reservation Button
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: FloatingActionButton.extended(
                onPressed: isLoggedIn ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationScreen(
                        restaurantName: widget.restaurantName, 
                        restaurantAddress: widget.address, 
                        restaurantImage: widget.imageUrl
                      )
                    ),
                  );
                } : null, // Only enabled if the user is logged in
                label: Text(
                  'RESERVE NOW',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary
                    ),
                ),
                icon: Icon(
                  Icons.calendar_today, 
                  color: Theme.of(context).colorScheme.onPrimary
                  ),
                backgroundColor: isLoggedIn 
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.secondary.withOpacity(0.5), // Lighter color if not logged in
              ),
            ),
            if (!isLoggedIn)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'You must be logged in to make a reservation.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 12,
                  ),
                ),
              ),
            // "Go to Reviews" button
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
