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
  bool isLoading = true;

  final ReviewService reviewService = ReviewService();
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    initializeScreen();
  }

  Future<void> initializeScreen() async {
    setState(() {
      isLoading = true;
    });
    await checkLoginStatus();
    if (isLoggedIn) {
      final loadedNotifications = await loadNotifications();
      setState(() {
        notifications = loadedNotifications;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkLoginStatus() async {
    bool loggedInStatus = await userService.isUserLoggedIn();
    setState(() {
      isLoggedIn = loggedInStatus;
    });
  }

  Future<List<Map<String, dynamic>>> loadNotifications() async {
    try {
      String? username = await userService.getLoggedUserName();

      // Load notifications from the file system instead of assets
      final directory = Directory.current;
      final notificationsPath = '${directory.path}/notifications.json';
      final notificationsFile = File(notificationsPath);

      if (!await notificationsFile.exists()) {
        print('Notifications file not found');
        return [];
      }

      final String notificationsString = await notificationsFile.readAsString();
      final List<dynamic> notificationsData = json.decode(notificationsString);

      final filteredNotifications = notificationsData.where((notification) {
        return notification['receiver'] == username;
      }).toList();

      print(filteredNotifications);

      // Still load restaurants from assets as it's static
      final String restaurantsString =
          await rootBundle.loadString('restaurants_data.json');
      final List<dynamic> restaurantsData = json.decode(restaurantsString);

      final List<Map<String, dynamic>> result = filteredNotifications
          .map((notification) {
            final restaurantData = restaurantsData.firstWhere(
              (restaurant) => restaurant['title'] == notification['sender'],
              orElse: () => null,
            );

            if (restaurantData == null) return null;

            return {
              'id': notification['id'],
              'img': restaurantData['img'],
              'sender': notification['sender'],
              'latitude': restaurantData['latitude'],
              'longitude': restaurantData['longitude'],
              'address': restaurantData['address'],
              'message': notification['message']
            };
          })
          .whereType<Map<String, dynamic>>()
          .toList()
          .reversed
          .toList();

      return result;
    } catch (e) {
      print('Error loading notifications: $e');
      return [];
    }
  }

  Future<void> deleteNotification(String id) async {
    setState(() {
      isLoading = true;
    });

    final directory = Directory.current;
    final notificationsPath = '${directory.path}/notifications.json';
    final notificationsFile = File(notificationsPath);

    if (await notificationsFile.exists()) {
      try {
        final notificationsFileContent = await notificationsFile.readAsString();
        final notificationsData =
            json.decode(notificationsFileContent) as List<dynamic>;

        notificationsData.removeWhere((notification) =>
            notification is Map<String, dynamic> && notification['id'] == id);

        await notificationsFile.writeAsString(json.encode(notificationsData),
            flush: true);

        // Reload notifications after deletion
        final updatedNotifications = await loadNotifications();
        setState(() {
          notifications = updatedNotifications;
          isLoading = false;
        });
      } catch (e) {
        print('Error while deleting notification: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('Notifications file does not exist.');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToRestaurant(
      BuildContext context, Map<String, dynamic> notification) async {
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
    List<Review> reviews =
        await reviewService.getReviewsByRestaurant(notification["sender"]);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantScreen(
            restaurantName: notification['sender'],
            imageUrl: notification['img'],
            reviews: reviews,
            latitude: notification['latitude'],
            longitude: notification['longitude'],
            address: notification['address']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'YOUR Notifications'.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green,
          centerTitle: true, // Centra el texto
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  'You must be logged in to view your notifications.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    ).then((_) => initializeScreen());
                  },
                  child: Text('Sign in'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'YOUR Notifications'.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green,
          centerTitle: true, // Centra el texto
        ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            )
          : notifications.isEmpty
              ? Center(
                  child: Text(
                    'No notifications!',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: notifications.length, // Removed the +1
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 12.0,
                        right: 12.0,
                        top: index == 0 ? 14.0 : 4.0,
                        bottom: 4.0,
                      ),
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
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
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: () async {
                              if (notification['id'] != null) {
                                await deleteNotification(notification['id']);
                              } else {
                                print('Notification ID is null');
                              }
                            },
                            child: SizedBox(
                              width: 80,
                              height: double.infinity,
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
                  },
                ),
    );
  }
}
