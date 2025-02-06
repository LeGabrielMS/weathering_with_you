import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static const _baseUrlDirect = 'https://api.openweathermap.org/geo/1.0/direct';
  static const _baseUrlReverse =
      'https://api.openweathermap.org/geo/1.0/reverse';
  final String apiKey;

  GeocodingService(this.apiKey);

  Future<Map<String, dynamic>> getCoordinates(String location) async {
    final url = Uri.parse('$_baseUrlDirect?q=$location&limit=1&appid=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        return {
          'name': data[0]['name'],
          'lat': data[0]['lat'],
          'lon': data[0]['lon'],
          'state': data[0]['state'],
          'country': data[0]['country'],
        };
      } else {
        throw Exception('Location not found');
      }
    } else {
      throw Exception('Failed to fetch coordinates');
    }
  }

  Future<Map<String, dynamic>> getCoordinatesFromLatLon(
      double lat, double lon) async {
    final url =
        Uri.parse('$_baseUrlReverse?lat=$lat&lon=$lon&limit=1&appid=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        return {
          'name': data[0]['name'],
          'lat': lat,
          'lon': lon,
          'state': data[0]['state'],
          'country': data[0]['country'],
        };
      } else {
        throw Exception('Failed to reverse geocode the location');
      }
    } else {
      throw Exception('Failed to fetch location data');
    }
  }
}
