import 'package:geolocator/geolocator.dart';

import '../data/api_key.dart';
import 'geocoding_service.dart';

class LocationService {
  static Future<Position> determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied. Please enable them in settings.';
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw 'Location services are disabled. Please enable them.';
    }

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
