import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'dart:convert';

import '../data/my_data.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherFactory _weatherFactory;

  WeatherBloc()
      : _weatherFactory = WeatherFactory(apiKey, language: Language.INDONESIAN),
        super(WeatherBlocInitial()) {
    on<FetchWeather>(_onFetchWeather);
    on<RefreshWeather>(_onRefreshWeather); // New event
  }

  Future<void> _onFetchWeather(
      FetchWeather event, Emitter<WeatherState> emit) async {
    emit(WeatherBlocLoading());

    try {
      // Fetch current weather
      Weather currentWeather = await _weatherFactory.currentWeatherByLocation(
        event.position.latitude,
        event.position.longitude,
      );

      List<Map<String, dynamic>> forecast = [];
      int airPollution = 0;

      // Fetch 5-day forecast
      try {
        forecast = await _fetchForecast(
          event.position.latitude,
          event.position.longitude,
        );
      } catch (e) {
        forecast = []; // Default to empty forecast on failure
      }

      // Fetch air pollution data
      try {
        airPollution = await _fetchAirPollution(
          event.position.latitude,
          event.position.longitude,
        );
      } catch (e) {
        airPollution = 0; // Default to 0 AQI on failure
      }

      emit(WeatherBlocSuccess(
        weather: currentWeather,
        forecast: forecast,
        airPollution: airPollution,
      ));
    } catch (error) {
      emit(WeatherBlocFailure(error.toString()));
    }
  }

  Future<void> _onRefreshWeather(
      RefreshWeather event, Emitter<WeatherState> emit) async {
    try {
      // Fetch updated weather data
      Weather currentWeather = await _weatherFactory.currentWeatherByLocation(
        event.position.latitude,
        event.position.longitude,
      );

      // Fetch 5-day forecast
      final forecast = await _fetchForecast(
        event.position.latitude,
        event.position.longitude,
      );

      // Fetch air pollution data
      final airPollution = await _fetchAirPollution(
        event.position.latitude,
        event.position.longitude,
      );

      emit(WeatherBlocSuccess(
        weather: currentWeather,
        forecast: forecast,
        airPollution: airPollution,
      ));
    } catch (error) {
      // Emit failure state with error message
      emit(WeatherBlocFailure(error.toString()));
    }
  }

  Future<List<Map<String, dynamic>>> _fetchForecast(
      double lat, double lon) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Group by day
      final groupedForecast = <String, Map<String, dynamic>>{};
      for (var item in data['list']) {
        final date = item['dt_txt'].split(' ')[0]; // Extract the date
        final tempMin =
            (item['main']['temp_min'] as num?) ?? 0.0; // Default to 0.0
        final tempMax =
            (item['main']['temp_max'] as num?) ?? 0.0; // Default to 0.0

        if (!groupedForecast.containsKey(date)) {
          groupedForecast[date] = {
            'date': date,
            'temp_min': tempMin,
            'temp_max': tempMax,
            'icon': item['weather'][0]['icon'],
            'description': item['weather'][0]['description'],
          };
        } else {
          groupedForecast[date]!['temp_min'] = math.min(
            groupedForecast[date]!['temp_min'] as double,
            tempMin.toDouble(),
          );
          groupedForecast[date]!['temp_max'] = math.max(
            groupedForecast[date]!['temp_max'] as double,
            tempMax.toDouble(),
          );
        }
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
      return data['list'][0]['main']['aqi']; // Air Quality Index (1 to 5)
    } else {
      throw Exception('Failed to fetch air pollution data');
    }
  }
}
