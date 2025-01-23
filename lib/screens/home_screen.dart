import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/weather_bloc.dart';
import '../helpers/weather_helpers.dart';
import '../widgets/weather_row.dart';
import '../widgets/weather_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 1.2 * kToolbarHeight, 40, 20),
        child:
            BlocBuilder<WeatherBloc, WeatherState>(builder: (context, state) {
          if (state is WeatherBlocLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WeatherBlocSuccess) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${state.weather.areaName}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getGreeting(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Center(
                    child: getWeatherIcon(state.weather.weatherConditionCode!),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      '${state.weather.temperature?.celsius?.round()}°C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "${state.weather.weatherMain}",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(height: 5),
                  Center(
                    child: Text(
                      DateFormat("EEEE, d MMMM y").format(state.weather.date!),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                  const SizedBox(height: 20),
                  WeatherSection(
                    rows: [
                      WeatherRow(
                        title: 'Sunrise',
                        assetPath: 'assets/weather/Sunny.json',
                        value: DateFormat()
                            .add_jm()
                            .format(state.weather.sunrise!),
                      ),
                      WeatherRow(
                        title: 'Sunset',
                        assetPath: 'assets/weather/Night.json',
                        value:
                            DateFormat().add_jm().format(state.weather.sunset!),
                      ),
                    ],
                  ),
                  WeatherSection(
                    rows: [
                      WeatherRow(
                          title: 'Max Temp.',
                          assetPath: 'assets/weather/Max_temp.json',
                          value:
                              '${state.weather.tempMax?.celsius?.round()}°C'),
                      WeatherRow(
                          title: 'Min Temp.',
                          assetPath: 'assets/weather/Min_temp.json',
                          value:
                              '${state.weather.tempMin?.celsius?.round()}°C'),
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
                    ],
                  ),
                ],
              ),
            );
          } else if (state is WeatherBlocFailure) {
            return Center(
              child: Text(
                'Error: ${state.error}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }),
      ),
    );
  }
}
