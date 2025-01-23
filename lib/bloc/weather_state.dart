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
  final List<Map<String, dynamic>> forecast; // 5-day forecast
  final int airPollution; // Air Quality Index

  const WeatherBlocSuccess({
    required this.weather,
    required this.forecast,
    required this.airPollution,
  });

  @override
  List<Object> get props => [weather, forecast, airPollution];
}
