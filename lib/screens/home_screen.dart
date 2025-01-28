import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/weather_bloc.dart';
import '../helpers/weather_helpers.dart';
import '../widgets/weather_row.dart';
import '../widgets/weather_section.dart';
import '../widgets/forecast_section.dart';
import 'location_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Helper function to determine greeting based on location's time zone
  String getLocalizedGreeting(Duration timezoneOffset) {
    final currentUtcTime = DateTime.now().toUtc();
    final localTime = currentUtcTime.add(timezoneOffset);

    final hour = localTime.hour;

    if (hour >= 5 && hour < 12) {
      return "Selamat Pagi!"; // Morning
    } else if (hour >= 12 && hour < 15) {
      return "Selamat Siang!"; // Noon
    } else if (hour >= 15 && hour < 18) {
      return "Selamat Sore!"; // Afternoon
    } else {
      return "Selamat Malam!"; // Night
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 1.2 * kToolbarHeight, 40, 20),
        child:
            BlocBuilder<WeatherBloc, WeatherState>(builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: state is WeatherBlocSuccess
                      ? () async {
                          final weatherBloc = context.read<WeatherBloc>();

                          final selectedLocation = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LocationSelectionScreen(),
                            ),
                          );

                          if (selectedLocation != null) {
                            weatherBloc.add(FetchWeather(
                              latitude: selectedLocation['lat'],
                              longitude: selectedLocation['lon'],
                            ));
                          }
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      state is WeatherBlocLoading
                          ? "Loading..."
                          : state is WeatherBlocSuccess
                              ? "${state.weather.areaName}"
                              : "Unable to fetch location",
                      style: TextStyle(
                        color: state is WeatherBlocSuccess
                            ? Colors.white
                            : Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        decoration: state is WeatherBlocSuccess
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (state is WeatherBlocSuccess) ...[
                  // Localized Greeting
                  Text(
                    getLocalizedGreeting(state.timezoneOffset),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: getWeatherIcon(state.weather.weatherConditionCode!),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      '${state.weather.temperature?.celsius?.round()}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "${state.weather.weatherMain}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Localized Date with 24-Hour Format
                  Center(
                    child: Text(
                      DateFormat("EEEE, d MMMM y | HH:mm").format(
                        DateTime.now().toUtc().add(state.timezoneOffset),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Weather Details Section
                  const Text(
                    'Weather Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  WeatherSection(
                    rows: [
                      WeatherRow(
                        title: 'Sunrise',
                        assetPath: 'assets/weather/Sunny.json',
                        value: DateFormat('HH:mm').format(state.sunriseLocal),
                      ),
                      WeatherRow(
                        title: 'Sunset',
                        assetPath: 'assets/weather/Night.json',
                        value: DateFormat('HH:mm').format(state.sunsetLocal),
                      ),
                      WeatherRow(
                        title: 'Max Temp.',
                        assetPath: 'assets/weather/Max_temp.json',
                        value: '${state.weather.tempMax?.celsius?.round()}°C',
                      ),
                      WeatherRow(
                        title: 'Min Temp.',
                        assetPath: 'assets/weather/Min_temp.json',
                        value: '${state.weather.tempMin?.celsius?.round()}°C',
                      ),
                      WeatherRow(
                        title: 'Pressure',
                        assetPath: 'assets/weather/Pressure.json',
                        value: '${state.weather.pressure?.round()} hPa',
                      ),
                      WeatherRow(
                        title: 'Humidity',
                        assetPath: 'assets/weather/Humidity.json',
                        value: '${state.weather.humidity?.round()}%',
                      ),
                      WeatherRow(
                        title: 'Wind',
                        assetPath: 'assets/weather/Wind.json',
                        value: '${state.weather.windSpeed} km/h',
                      ),
                      WeatherRow(
                        title: 'Air Quality',
                        assetPath: 'assets/weather/Air_pollution.json',
                        value: '${state.airPollution} AQI',
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 5-Day Forecast Section
                  const Text(
                    '5-Day Forecast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ForecastSection(forecast: state.forecast),
                ] else if (state is WeatherBlocLoading) ...[
                  const Center(child: CircularProgressIndicator()),
                ] else if (state is WeatherBlocFailure) ...[
                  Center(
                    child: Text(
                      'Error: ${state.error}',
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}
