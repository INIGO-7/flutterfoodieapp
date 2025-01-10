import 'package:flutter/material.dart';

class RestaurantDetails extends StatelessWidget {
  final String img;
  final String title;
  final String address;
  final double rating;
  final List<Map<String, dynamic>> reviews;

  RestaurantDetails({
    required this.img,
    required this.title,
    required this.address,
    required this.rating,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and Basic Info
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                img,
                height: 250.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              address,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12.0),
            Row(
              children: [
                Icon(Icons.star, color: Colors.yellow[700], size: 22.0),
                SizedBox(width: 4.0),
                Text(
                  rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 4.0),
                Text(
                  "(${reviews.length} reviews)",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            Divider(height: 32.0, color: Colors.grey[300]),

            // Reviews Section
            Text(
              "Customer Reviews",
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16.0),
            reviews.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.account_circle,
                                      size: 30.0, color: Colors.grey[600]),
                                  SizedBox(width: 8.0),
                                  Text(
                                    review['username'] ?? 'Anonymous',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    review['date'] ?? 'N/A',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                review['comment'] ?? 'No comment provided.',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black87),
                              ),
                              SizedBox(height: 12.0),
                              Row(
                                children: List.generate(
                                  5,
                                  (starIndex) => Icon(
                                    Icons.star,
                                    color: starIndex < review['rating']
                                        ? Colors.yellow[700]
                                        : Colors.grey[400],
                                    size: 20.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      "No reviews available.",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
