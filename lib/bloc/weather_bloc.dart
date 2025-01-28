import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:weather/weather.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'dart:convert';

import '../data/my_data.dart';
import '../utils/geocoding_service.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherFactory _weatherFactory;
  final GeocodingService _geocodingService;

  WeatherBloc()
      : _weatherFactory = WeatherFactory(apiKey, language: Language.INDONESIAN),
        _geocodingService = GeocodingService(apiKey),
        super(WeatherBlocInitial()) {
    on<FetchWeather>(_onFetchWeather);
    on<RefreshWeather>(_onRefreshWeather);
    on<SearchLocation>(_onSearchLocation);
  }

  Future<void> _onFetchWeather(
      FetchWeather event, Emitter<WeatherState> emit) async {
    emit(WeatherBlocLoading());

    try {
      // Fetch all weather data, including adjusted sunrise/sunset
      final data = await _fetchAllWeatherData(
        latitude: event.latitude,
        longitude: event.longitude,
      );

      emit(WeatherBlocSuccess(
        weather: data['weather'],
        forecast: data['forecast'],
        airPollution: data['airPollution'],
        sunriseLocal: data['sunriseLocal'],
        sunsetLocal: data['sunsetLocal'],
        timezoneOffset: data['timezoneOffset'],
      ));
    } catch (error) {
      emit(WeatherBlocFailure(error.toString()));
    }
  }

  Future<void> _onRefreshWeather(
      RefreshWeather event, Emitter<WeatherState> emit) async {
    try {
      // Fetch all weather data, including adjusted sunrise/sunset
      final data = await _fetchAllWeatherData(
        latitude: event.latitude,
        longitude: event.longitude,
      );

      emit(WeatherBlocSuccess(
        weather: data['weather'],
        forecast: data['forecast'],
        airPollution: data['airPollution'],
        sunriseLocal: data['sunriseLocal'],
        sunsetLocal: data['sunsetLocal'],
        timezoneOffset: data['timezoneOffset'],
      ));
    } catch (error) {
      emit(WeatherBlocFailure(error.toString()));
    }
  }

  Future<void> _onSearchLocation(
      SearchLocation event, Emitter<WeatherState> emit) async {
    emit(WeatherBlocLoading());

    try {
      final location =
          await _geocodingService.getCoordinates(event.locationName);

      final data = await _fetchAllWeatherData(
        latitude: location['lat'],
        longitude: location['lon'],
      );

      emit(WeatherBlocSuccess(
        weather: data['weather'],
        forecast: data['forecast'],
        airPollution: data['airPollution'],
        sunriseLocal: data['sunriseLocal'],
        sunsetLocal: data['sunsetLocal'],
        timezoneOffset: data['timezoneOffset'],
      ));
    } catch (error) {
      emit(WeatherBlocFailure(error.toString()));
    }
  }

  Future<Map<String, dynamic>> _fetchAllWeatherData({
    required double latitude,
    required double longitude,
  }) async {
    // Fetch current weather
    final Weather currentWeather =
        await _weatherFactory.currentWeatherByLocation(latitude, longitude);

    // Fetch additional details from the raw API
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Extract timezone offset and adjust sunrise/sunset times
      final timezoneOffset = data['timezone'] as int; // Offset in seconds
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

      // Return the complete weather data
      return {
        'weather': currentWeather,
        'forecast': await _fetchForecast(latitude, longitude),
        'airPollution': await _fetchAirPollution(latitude, longitude),
        'sunriseLocal': sunriseLocal,
        'sunsetLocal': sunsetLocal,
        'timezoneOffset': Duration(seconds: timezoneOffset),
      };
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchForecast(
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

  Future<int> _fetchAirPollution(double lat, double lon) async {
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
}
