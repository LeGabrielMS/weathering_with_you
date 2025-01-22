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

  const WeatherBlocSuccess(this.weather);

  @override
  List<Object> get props => [weather];
}
