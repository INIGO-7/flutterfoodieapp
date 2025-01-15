import 'package:flutter/material.dart';
import 'restaurant_screen.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';

import '../util/review.dart';
import '../util/user_service.dart';
import 'package:flutter_foodybite/screens/login.dart';
import 'package:flutter_foodybite/util/review_service.dart';

class Notifications extends StatefulWidget {
  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  List<Map<String, dynamic>> notifications = [];
  bool isLoggedIn = false;

  final ReviewService reviewService = ReviewService();
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    initializeScreen();
  }

  Future<void> initializeScreen() async {
    await checkLoginStatus(); // Verifica el estado de inicio de sesión
    if (isLoggedIn) {
      await loadNotifications(); // Carga reservas solo si el usuario está logueado
    }
  }

  Future<void> checkLoginStatus() async {
    bool loggedInStatus = await userService.isUserLoggedIn(); // Llama a la función isUserLoggedIn
    setState(() {
      isLoggedIn = loggedInStatus;
    });
  }

  Future<List<Map<String, dynamic>>> loadNotifications() async {
    try {
      // Get the currently logged-in username
      String? username = await userService.getLoggedUserName();

      // Load and decode the notifications JSON file
      final String notifications_string = await rootBundle.loadString('notifications.json');
      final List<dynamic> notifications_data = json.decode(notifications_string);

      // Filter notifications by the logged-in user's name
      final filteredNotifications = notifications_data.where((notification) {
        return notification['receiver'] == username;
      }).toList();

      // Load and decode the restaurants JSON file
      final String restaurantsString = await rootBundle.loadString('restaurants_data.json');
      final List<dynamic> restaurantsData = json.decode(restaurantsString);

      // Map filtered notifications to include restaurant data
      final List<Map<String, dynamic>> result = filteredNotifications.map((notification) {
        final restaurantData = restaurantsData.firstWhere(
          (restaurant) => restaurant['title'] == notification['sender'],
          orElse: () => null,
        );


        // If no matching restaurant is found, skip this notification
        if (restaurantData == null) return null;

        // Construct the final map
        return {
          'id': notification['id'],
          'img': restaurantData['img'],
          'sender': notification['sender'],
          'latitude': restaurantData['latitude'],
          'longitude': restaurantData['longitude'],
          'address': restaurantData['address'],
          'message': notification['message']
        };
      }).whereType<Map<String, dynamic>>().toList(); // Remove null values

      return result;
    } catch (e) {
      print('Error loading notifications: $e');
      return [];
    }
  }

  Future<void> deleteNotification(String id) async {
    final directory = Directory.current;

    // Path to the notifications.json file
    final notificationsPath = '${directory.path}/notifications.json';
    final notificationsFile = File(notificationsPath);

    // Check if the file exists
    if (await notificationsFile.exists()) {
      try {
        // Read the file content and decode it
        final notificationsFileContent = await notificationsFile.readAsString();
        final notificationsData = json.decode(notificationsFileContent) as List<dynamic>;

        // Find and remove the notification with the given id
        notificationsData.removeWhere((notification) =>
            notification is Map<String, dynamic> && notification['id'] == id);

        // Write the updated notifications list back to the file
        await notificationsFile.writeAsString(json.encode(notificationsData), flush: true);
        
      } catch (e) {
        print('Error while deleting notification: $e');
      }
    } else {
      print('Notifications file does not exist.');
    }
  }


  void _navigateToRestaurant(BuildContext context, Map<String, dynamic> notification) async {

    bool isDataReady = notification['sender'] != '' && 
                  notification['sender'] != null && 
                  notification['sender'] != 'Untitled';

    if (!isDataReady) {
      // Show a snackbar or some other feedback that this restaurant's details aren't available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restaurant details not available yet'),
        ),
      );
      return;
    }

    // Get the reviews
    List<Review> reviews = await reviewService.getReviewsByRestaurant(notification["sender"]);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantScreen(
          restaurantName: notification['sender'],
          imageUrl: notification['img'],
          reviews: reviews,
          latitude: notification['latitude'],
          longitude: notification['longitude'],
          address: notification['address']
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Your Reservations'),
          automaticallyImplyLeading: false, // Elimina la flecha de retroceso
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center, // Asegura que el texto esté centrado
                child: Text(
                  'You must be logged in to view your reservations.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center, // Centra el texto dentro del widget
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()), // Asegúrate de importar LoginScreen
                ).then((_) {
                  checkLoginStatus();
                  if (isLoggedIn) {
                    loadNotifications();
                  }
                });
                }, // Aquí deberías añadir la acción para iniciar sesión
                child: Text('Login'),
              ),
            ],
          ),
        ),
      );
    } else {
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
                            backgroundImage: notification['img'] != null
                                ? AssetImage(notification['img'])
                                : null,
                            radius: 30,
                          ),
                          title: Text(
                            notification['sender'] ?? 'Untitled',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            notification['message'] ?? '',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 13,
                            ),
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary, // Background color
                              padding: EdgeInsets.zero, // Removes padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0), // Button shape
                              ),
                            ),
                            onPressed: () async {
                              if (notification['id'] != null) {
                                deleteNotification(notification['id']);
                                setState(() {}); // Refresh the UI after deletion
                              } else {
                                print('Notification ID is null');
                              }
                            },
                            child: SizedBox(
                              width: 80, // Fixed width
                              height: double.infinity, // Occupies full height of the notification
                              child: Center(
                                child: Text(
                                  'Delete',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
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
}
