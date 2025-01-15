import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class OSMMapContainer extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String address;

  const OSMMapContainer({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.address
  }) : super(key: key);

  void _launchMaps(String address) async {
    print('launch maps clicked! address: $address');
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$address');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: latitude != 0 && longitude != 0
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(latitude, longitude),
                  zoom: 15,
                  interactiveFlags: InteractiveFlag.none,
                  onTap: (_, __) {
                    _launchMaps(address); // Trigger map click to launch maps
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(latitude, longitude),
                        builder: (ctx) => const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const Center(
              child: Text('OpenStreetMap not working'),
            ),
    );
  }
}