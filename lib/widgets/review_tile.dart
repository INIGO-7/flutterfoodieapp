import 'package:flutter/material.dart';
import '../util/review.dart';
import '../util/app_constants.dart';

class ReviewTile extends StatelessWidget {
  final List<Review> reviews;

  const ReviewTile({
    Key? key,
    required this.reviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sort reviews by rating in descending order and take the top 2
    final topReviews = (reviews..sort((a, b) => b.rating.compareTo(a.rating)))
        .take(2)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: AppConstants.secondaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display top two reviews
          ...topReviews.map((review) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: review.avatarPath != null
                              ? AssetImage(review.avatarPath!)
                              : null,
                          child: review.avatarPath == null
                              ? Text(
                                  review.reviewerName[0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${review.reviewerName} - ${review.rating}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.star,
                                      color: AppConstants.accentColor, size: 20),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                review.comment,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (review != topReviews.last) // Add white divider except for last review
                    const Divider(
                      color: Colors.white,
                      height: 24,
                      thickness: 1,
                    ),
                ],
              )),
          const SizedBox(height: 4), // Space between reviews and button

          // "Go to reviews" button
          Center(
            child: TextButton(
              onPressed: () {
                // Navigate to the reviews page
                Navigator.pushNamed(context, '/reviews');
              },
              child: const Text(
                'Go to reviews',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppConstants.accentColor, // Highlight button color
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class LocationTile extends StatelessWidget {
  final String location;

  const LocationTile({
    Key? key,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.red),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            location,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}