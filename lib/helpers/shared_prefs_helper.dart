import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const _savedLocationsKey = 'saved_locations';

  // Save a location to SharedPreferences
  static Future<void> saveLocation(Map<String, dynamic> location) async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocations = prefs.getStringList(_savedLocationsKey) ?? [];

    // Avoid duplicates
    if (!savedLocations.any((loc) => loc.startsWith(location['name']))) {
      savedLocations
          .add('${location['name']},${location['lat']},${location['lon']}');
      await prefs.setStringList(_savedLocationsKey, savedLocations);
    }
  }

  // Load all saved locations
  static Future<List<Map<String, dynamic>>> loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocations = prefs.getStringList(_savedLocationsKey) ?? [];

    return savedLocations.map((loc) {
      final parts = loc.split(',');
      return {
        'name': parts[0],
        'lat': double.parse(parts[1]),
        'lon': double.parse(parts[2])
      };
    }).toList();
  }

  // Remove saved locations
  static Future<void> removeLocation(Map<String, dynamic> location) async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocations = prefs.getStringList(_savedLocationsKey) ?? [];

    final updatedLocations = savedLocations.where((loc) {
      final parts = loc.split(',');
      return !(parts[0] == location['name'] &&
          parts[1] == location['lat'].toString() &&
          parts[2] == location['lon'].toString());
    }).toList();

    await prefs.setStringList(_savedLocationsKey, updatedLocations);
  }
}
