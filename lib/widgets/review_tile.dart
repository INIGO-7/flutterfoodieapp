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
                              style: const TextStyle(
                                color: Colors.white,
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 3), // Reduced spacing
                              const Icon(Icons.star,
                                  color: AppConstants.accentColor, size: 18), // Slightly smaller icon
                            ],
                          ),
                          const SizedBox(height: 2), // Reduced spacing between name and comment
                          Text(
                            review.comment,
                            style: const TextStyle(
                              color: Colors.grey,
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
        // const Icon(Icons.location_on, color: AppConstants.accentColor), // Uncomment if needed
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: 'Located at - ',
              style: AppConstants.robotoFlexBlack,
              children: [
                TextSpan(
                  text: location,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppConstants.accentColor,
                    decoration: TextDecoration.underline,
                    decorationColor: AppConstants.accentColor,
                    decorationThickness: 1.5
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}