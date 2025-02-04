import 'package:geolocator/geolocator.dart';

import '../data/api_key.dart';
import 'geocoding_service.dart';

class LocationService {
  static Future<Position> determinePosition() async {
    LocationPermission permission;

    // Step 1: Check and request location permissions first.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied.
      throw 'Location permissions are permanently denied. Please enable them in settings.';
    }

    // Step 2: Check if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Prompt the user to enable location services.
      await Geolocator.openLocationSettings();
      throw 'Location services are disabled. Please enable them.';
    }

    // Step 3: Permissions are granted, and location services are enabled.
    return await Geolocator.getCurrentPosition();
  }

  static Future<Map<String, dynamic>> fetchCurrentLocation() async {
    final position = await determinePosition();
    return await GeocodingService(apiKey).getCoordinatesFromLatLon(
      position.latitude,
      position.longitude,
    );
  }

  static Future<Map<String, dynamic>> searchLocation(String query) async {
    return await GeocodingService(apiKey).getCoordinates(query);
  }
}
