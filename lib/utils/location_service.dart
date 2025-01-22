import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Prompt the user to enable location services.
      await Geolocator.openLocationSettings();
      throw 'Location services are disabled. Please enable them.';
    }

    // Check and request location permissions.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever.
      throw 'Location permissions are permanently denied. Please enable them in settings.';
    }

    // Return the current position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
