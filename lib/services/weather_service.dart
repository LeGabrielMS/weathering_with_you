import 'dart:convert';
import 'package:weather/weather.dart';

import 'dart:math' as math;
import 'package:http/http.dart' as http;

import 'geocoding_service.dart';
import '../data/api_key.dart';

class WeatherService {
  final WeatherFactory _weatherFactory;
  final GeocodingService _geocodingService;

  WeatherService()
      : _weatherFactory = WeatherFactory(apiKey, language: Language.INDONESIAN),
        _geocodingService = GeocodingService(apiKey);

  Future<Map<String, dynamic>> fetchAllWeatherData({
    required double latitude,
    required double longitude,
  }) async {
    final Weather currentWeather =
        await _weatherFactory.currentWeatherByLocation(latitude, longitude);

    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final timezoneOffset = data['timezone'] as int;
      final sunriseUtc = DateTime.fromMillisecondsSinceEpoch(
        data['sys']['sunrise'] * 1000,
        isUtc: true,
      );
      final sunsetUtc = DateTime.fromMillisecondsSinceEpoch(
        data['sys']['sunset'] * 1000,
        isUtc: true,
      );

      final sunriseLocal = sunriseUtc.add(Duration(seconds: timezoneOffset));
      final sunsetLocal = sunsetUtc.add(Duration(seconds: timezoneOffset));

      return {
        'weather': currentWeather,
        'forecast': await fetchForecast(latitude, longitude),
        'airPollution': await fetchAirPollution(latitude, longitude),
        'sunriseLocal': sunriseLocal,
        'sunsetLocal': sunsetLocal,
        'timezoneOffset': Duration(seconds: timezoneOffset),
      };
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  Future<List<Map<String, dynamic>>> fetchForecast(
      double lat, double lon) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final groupedForecast = <String, Map<String, dynamic>>{};
      for (var item in data['list']) {
        final date = item['dt_txt'].split(' ')[0];
        final tempMin = (item['main']['temp_min'] as num?)?.toDouble() ?? 0.0;
        final tempMax = (item['main']['temp_max'] as num?)?.toDouble() ?? 0.0;

        groupedForecast.update(
          date,
          (existing) => {
            'date': date,
            'temp_min': math.min(existing['temp_min'] as double, tempMin),
            'temp_max': math.max(existing['temp_max'] as double, tempMax),
            'icon': existing['icon'],
            'description': existing['description'],
          },
          ifAbsent: () => {
            'date': date,
            'temp_min': tempMin,
            'temp_max': tempMax,
            'icon': item['weather'][0]['icon'],
            'description': item['weather'][0]['description'],
          },
        );
      }

      return groupedForecast.values.toList();
    } else {
      throw Exception('Failed to fetch forecast data');
    }
  }

  Future<int> fetchAirPollution(double lat, double lon) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['list'][0]['main']['aqi'];
    } else {
      throw Exception('Failed to fetch air pollution data');
    }
  }

  Future<Map<String, dynamic>> searchLocation(String locationName) async {
    return await _geocodingService.getCoordinates(locationName);
  }
}
