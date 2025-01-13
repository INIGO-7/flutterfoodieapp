import 'package:flutter/material.dart';

class RatingSection extends StatelessWidget {
  final double rating;

  const RatingSection({
    Key? key,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            Container(
              height: 8,
              width: 235,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.primary
                  ],
                  stops: [
                    rating / 5, // Filled portion of the gradient
                    rating / 5, // Ensures the unfilled portion is white
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Stars
            Row(
              children: List.generate(5, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8), // Spacing between stars
                  child: Icon(
                    index < rating.floor() ? Icons.star : Icons.star_border,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 32,
                  ),
                );
              }),
            ),
          ],
        ),
        // Rating text
        Text(
          '${rating.toStringAsFixed(1)} / 5 stars',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }
}