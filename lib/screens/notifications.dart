import 'package:flutter/material.dart';

class Notifications extends StatelessWidget {

  Notifications({Key? key}) : super(key: key);


  final List<Map<String, String>> notifications = [
    {
      'image': 'assets/food2.jpeg',
      'title': 'El Sombrerito',
      'description': 'Craving something spicy? Our Sriracha-inspired dishes bring the heat!',
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
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
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'No notifications remaining!',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
