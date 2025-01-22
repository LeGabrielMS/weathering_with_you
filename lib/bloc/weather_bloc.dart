import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';

import '../data/my_data.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherFactory _weatherFactory;

  WeatherBloc()
      : _weatherFactory = WeatherFactory(apiKey, language: Language.INDONESIAN),
        super(WeatherBlocInitial()) {
    on<FetchWeather>(_onFetchWeather);
  }

  Future<void> _onFetchWeather(
      FetchWeather event, Emitter<WeatherState> emit) async {
    emit(WeatherBlocLoading()); // Emit loading state

    try {
      // Fetch weather by location
      Weather weather = await _weatherFactory.currentWeatherByLocation(
        event.position.latitude,
        event.position.longitude,
      );

      emit(WeatherBlocSuccess(weather));
    } catch (error) {
      // Emit failure state with error message
      emit(WeatherBlocFailure(error.toString()));
    }
  }
}
