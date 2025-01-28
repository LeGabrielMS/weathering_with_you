part of 'weather_bloc.dart';

sealed class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class FetchWeather extends WeatherEvent {
  final double latitude;
  final double longitude;

  const FetchWeather({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [latitude, longitude];
}

class RefreshWeather extends WeatherEvent {
  final double latitude;
  final double longitude;

  const RefreshWeather({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [latitude, longitude];
}

class SearchLocation extends WeatherEvent {
  final String locationName;

  const SearchLocation(this.locationName);

  @override
  List<Object> get props => [locationName];
}
