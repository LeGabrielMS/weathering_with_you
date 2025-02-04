import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:weather/weather.dart';

import '../services/weather_service.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherService _weatherRepository;

  WeatherBloc()
      : _weatherRepository = WeatherService(),
        super(WeatherBlocInitial()) {
    on<FetchWeather>(_onFetchWeather);
    on<RefreshWeather>(_onRefreshWeather);
    on<SearchLocation>(_onSearchLocation);
  }

  Future<void> _onFetchWeather(
      FetchWeather event, Emitter<WeatherState> emit) async {
    emit(WeatherBlocLoading());

    try {
      final data = await _weatherRepository.fetchAllWeatherData(
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
      final data = await _weatherRepository.fetchAllWeatherData(
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
          await _weatherRepository.searchLocation(event.locationName);

      final data = await _weatherRepository.fetchAllWeatherData(
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
}
