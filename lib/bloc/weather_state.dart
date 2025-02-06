part of 'weather_bloc.dart';

sealed class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object> get props => [];
}

final class WeatherBlocInitial extends WeatherState {}

final class WeatherBlocLoading extends WeatherState {}

final class WeatherBlocFailure extends WeatherState {
  final String error;

  const WeatherBlocFailure(this.error);

  @override
  List<Object> get props => [error];
}

final class WeatherBlocSuccess extends WeatherState {
  final Weather weather;
  final List<Map<String, dynamic>> forecast;
  final int airPollution;
  final Duration timezoneOffset;
  final DateTime sunriseLocal;
  final DateTime sunsetLocal;

  const WeatherBlocSuccess({
    required this.weather,
    required this.forecast,
    required this.airPollution,
    required this.timezoneOffset,
    required this.sunriseLocal,
    required this.sunsetLocal,
  });

  @override
  List<Object> get props => [
        weather,
        forecast,
        airPollution,
        timezoneOffset,
        sunriseLocal,
        sunsetLocal,
      ];
}
