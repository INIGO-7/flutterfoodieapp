import 'package:flutter/material.dart';
import 'restaurant_screen.dart';
import '../util/review.dart';

class Notifications extends StatelessWidget {
  Notifications({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> notifications = [
    {
      'image': 'assets/food2.jpeg',
      'title': 'El Sombrerito',
      'description': 'Craving something spicy? Our Sriracha-inspired dishes bring the heat!',
      'restaurantData': { 
        'imageUrl': 'assets/food2.jpeg',
        'location': 'Fischgässel 4, 93047 Regensburg',
        'reviews': [
          {
            'reviewerName': 'Roger',
            'rating': 4.5,
            'comment': 'The dining experience was pretty authentic and the personal was great!',
            'avatarPath': 'assets/character9.jpeg'
          },
          {
            'reviewerName': 'Charles',
            'rating': 3.0,
            'comment': 'The dining experience was pretty authentic and the personal was nice.',
            'avatarPath': 'assets/character7.jpeg'
          },
        ],
      }
    },
    {
      'image': 'assets/food3.jpeg',
      'title': 'Burgerheart Regensburg',
      'description': 'Dive into the ultimate flavor with our new Smoky BBQ Bacon Burger!',
    },
    {
      'image': 'assets/food6.jpeg',
      'title': 'Andoni\'s Bistro',
      'description': 'Our new Dry-Aged Tomahawk will take your steak experience to a new level.',
    },
    {
      'image': 'assets/food1.jpeg',
      'title': 'Montevideo',
      'description': 'Looking for a light meal? Our salads are perfect for a guilt-free indulgence!',
    },
    {
      'image': 'assets/food7.jpeg',
      'title': 'Happy Jones',
      'description': 'We are guilty of having the best tasting pizza in all of Regensburg... Come try!',
    },
    {
      'image': 'assets/food6.jpeg',
      'title': 'Andoni\'s Bistro',
      'description': 'Our new Dry-Aged Tomahawk will take your steak experience to a new level.',
    },
    {
      'image': 'assets/food1.jpeg',
      'title': 'Montevideo',
      'description': 'Looking for a light meal? Our salads are perfect for a guilt-free indulgence!',
    },
    {
      'image': 'assets/food7.jpeg',
      'title': 'Happy Jones',
      'description': 'We are guilty of having the best tasting pizza in all of Regensburg... Come try!',
    }
  ];

  void _navigateToRestaurant(BuildContext context, Map<String, dynamic> notification) {
    final restaurantData = notification['restaurantData'] as Map<String, dynamic>;
    final reviews = (restaurantData['reviews'] as List).map((review) => Review(
          reviewerName: review['reviewerName'] as String,
          rating: review['rating'] as double,
          comment: review['comment'] as String,
          avatarPath: review['avatarPath'] as String          
        )).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantScreen(
          restaurantName: notification['title'],
          imageUrl: restaurantData['imageUrl'],
          reviews: reviews,
          location: restaurantData['location'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: notifications.length + 1, // Add 1 for the footer
        itemBuilder: (context, index) {
          if (index < notifications.length) {
            final notification = notifications[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(notification['image']!),
                    radius: 30,
                  ),
                  title: Text(
                    notification['title']!,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    notification['description']!,
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                  onTap: () {
                    if (notification['restaurantData'] != null) {
                      _navigateToRestaurant(context, notification);  // Pass the whole notification
                    }
                  },
                ),
              ),
            );
          } else {
            // Footer message
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Center(
                child: Text(
                  'No notifications remaining!',
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}