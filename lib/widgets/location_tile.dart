import 'package:flutter/material.dart';

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
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary
              ),
              children: [
                TextSpan(
                  text: location,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.secondary,
                    decoration: TextDecoration.underline,
                    decorationColor: Theme.of(context).colorScheme.secondary,
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