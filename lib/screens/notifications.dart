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
          location: locationData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: loadNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading notifications',
                style: TextStyle(color: Colors.grey[500]),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    color: Colors.grey[900],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: notification['image'] != null 
                          ? AssetImage(notification['image'])
                          : null,
                        radius: 30,
                      ),
                      title: Text(
                        notification['title'] ?? 'Untitled',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        notification['description'] ?? '',
                        style: TextStyle(color: Colors.grey[300]),
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
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
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