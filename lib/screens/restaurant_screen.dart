import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/reservations.dart';
import 'package:flutter_foodybite/util/review.dart';

import '../util/user_service.dart';
import '../widgets/rating_section.dart';
import '../widgets/review_tile.dart';
import '../widgets/location_tile.dart';
import '../widgets/osm_map.dart';

class RestaurantScreen extends StatefulWidget {
  final String restaurantName;
  final String imageUrl;
  final List<Review> reviews;
  final Map<String, dynamic> location;

  const RestaurantScreen({
    Key? key,
    required this.restaurantName,
    required this.imageUrl,
    required this.reviews,
    required this.location,
  }) : super(key: key);

  @override
  _RestaurantScreenState createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final userService = UserService();
    bool loggedInStatus = await userService.isUserLoggedIn();
    setState(() {
      isLoggedIn = loggedInStatus;
    });
  }

  double get averageRating {
    if (widget.reviews.isEmpty) return 0;
    return widget.reviews.map((r) => r.rating).reduce((a, b) => a + b) / widget.reviews.length;
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
                  // Show top two reviews
                  ReviewTile(reviews: widget.reviews),

                  OSMMapContainer(
                    latitude: widget.location['latitude'],
                    longitude: widget.location['longitude'],
                    address: widget.location['address']
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    child: LocationTile(location: widget.location['address']),
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
                        restaurantAddress: widget.location['address'], 
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
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
