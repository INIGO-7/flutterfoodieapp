import 'package:flutter/material.dart';
import 'restaurant_screen.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '../util/review.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  
  Future<List<dynamic>> loadNotifications() async {
    try {
      // Load the JSON file as a string
      final String jsonString = await rootBundle.loadString('notifications.json');  // Make sure your file has .json extension
      //Decode the json and return it
      Map<String, dynamic> jsonData = json.decode(jsonString);
      return jsonData['notifications'] as List<dynamic>;

    } catch (e) {
      print('Error loading notifications: $e');
      return [];
    }
  }

  void _navigateToRestaurant(BuildContext context, Map<String, dynamic> notification) {
    // First check if restaurantData exists
    final restaurantData = notification['restaurantData'];
    if (restaurantData == null) {
      // Show a snackbar or some other feedback that this restaurant's details aren't available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restaurant details not available yet'),
        ),
      );
      return;
    }

    final locationData = restaurantData['location'] as Map<String, dynamic>;
    final reviews = (restaurantData['reviews'] as List).map((review) => Review(
          restaurant: notification['title'],
          username: review['reviewerName'] as String,
          rating: review['rating'] as double,
          comment: review['comment'] as String,
          avatarPath: review['avatarPath'] as String,
          createdAt: DateTime.now(),   //FIX         
        )).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantScreen(
          restaurantName: notification['title'],
          imageUrl: restaurantData['imageUrl'],
          reviews: reviews,
          location: locationData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary
            ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: loadNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading notifications',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary
                  ),
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          return ListView.builder(
            itemCount: notifications.length + 1,
            itemBuilder: (context, index) {
              if (index < notifications.length) {
                final notification = notifications[index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: 12.0, // Fixed horizontal padding
                    right: 12.0, // Fixed horizontal padding
                    top: index == 0 ? 14.0 : 4.0, // Extra top padding for the first card
                    bottom: 4.0, // Fixed bottom padding
                  ),
                  child: Card(
                    color: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: 
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: notification['image'] != null 
                            ? AssetImage(notification['image'])
                            : null,
                          radius: 30,
                        ),
                        title: Text(
                          notification['title'] ?? 'Untitled',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          notification['description'] ?? '',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 13
                          ),
                        ),
                      onTap: () {
                        _navigateToRestaurant(context, notification);
                      },
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Center(
                    child: Text(
                      'No notifications remaining!',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}