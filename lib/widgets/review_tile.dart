import 'package:flutter/material.dart';
import '../util/review.dart';

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

    final hasReviews = reviews.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasReviews)
            ...topReviews.map((review) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4), // Reduced bottom padding
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center, // Center aligns avatar with text
                        children: [
                          CircleAvatar(
                            radius: 27,
                            backgroundImage: review.avatarPath != null
                                ? AssetImage(review.avatarPath!)
                                : null,
                            child: review.avatarPath == null
                                ? Text(
                                    review.username[0],
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16), // Reduced horizontal spacing
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min, // Ensures the text doesn't expand unnecessarily
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${review.username} - ${review.rating}',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 3), // Reduced spacing
                                    Icon(
                                      Icons.star,
                                      color: Theme.of(context).colorScheme.secondary,
                                      size: 18,
                                    ), // Slightly smaller icon
                                  ],
                                ),
                                const SizedBox(height: 2), // Reduced spacing between name and comment
                                Text(
                                  review.comment,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSecondary,
                                    fontSize: 14,
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
                    if (review != topReviews.last)
                      const Divider(
                        color: Colors.white,
                        height: 16, // Reduced height for less vertical spacing
                        thickness: 1,
                      ),
                  ],
                )),
          if (!hasReviews)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'No reviews available yet',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 4), // Space between reviews and button

          // "Go to reviews" button
          Center(
            child: TextButton(
              onPressed: () {
                // Navigate to the reviews page
                Navigator.pushNamed(context, '/reviews');
              },
              child: Text(
                hasReviews ? 'Go to reviews' : 'Be the first!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}