import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../bloc/weather_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Helper to determine greeting based on time
  String getGreeting() {
    final hour = DateTime.now().hour;
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

  // Helper to get weather icon dynamically based on weather code and time
  Widget getWeatherIcon(int code) {
    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour >= 18;

    if (code >= 200 && code < 300) {
      return Lottie.asset('assets/weather/Thunderstorm.json');
    } else if (code >= 300 && code < 600) {
      return Lottie.asset(isNight
          ? 'assets/weather/Raining_night.json'
          : 'assets/weather/Raining.json');
    } else if (code >= 600 && code < 700) {
      return Lottie.asset('assets/weather/Cloudy.json');
    } else if (code >= 700 && code < 800) {
      return Lottie.asset('assets/weather/Cloudy.json');
    } else if (code == 800) {
      return Lottie.asset(
          isNight ? 'assets/weather/Night.json' : 'assets/weather/Sunny.json');
    } else if (code > 800 && code <= 804) {
      return Lottie.asset(isNight
          ? 'assets/weather/Cloudy_night.json'
          : 'assets/weather/Cloudy_sun.json');
    } else {
      return Lottie.asset(
          isNight ? 'assets/weather/Night.json' : 'assets/weather/Sunny.json');
    }
  }

  // Helper to create rows for sunrise/sunset, temperature, etc.
  Widget buildRow(String title, String assetPath, String value) {
    return Row(
      children: [
        Lottie.asset(assetPath, width: 50),
        SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
            ),
            SizedBox(height: 3),
            Text(
              value,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(40, 1.2 * kToolbarHeight, 40, 20),
        child:
            BlocBuilder<WeatherBloc, WeatherState>(builder: (context, state) {
          if (state is WeatherBlocLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is WeatherBlocSuccess) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${state.weather.areaName}",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w300),
                ),
                SizedBox(height: 8),
                Text(
                  getGreeting(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                Center(
                  child: getWeatherIcon(state.weather.weatherConditionCode!),
                ),
                Center(
                  child: Text(
                    '${state.weather.temperature?.celsius?.round()}°C',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 55,
                        fontWeight: FontWeight.w600),
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
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildRow(
                      'Sunrise',
                      'assets/weather/Sunny.json',
                      DateFormat().add_jm().format(state.weather.sunrise!),
                    ),
                    buildRow(
                      'Sunset',
                      'assets/weather/Night.json',
                      DateFormat().add_jm().format(state.weather.sunset!),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Divider(color: Colors.grey),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildRow(
                      'Temp. Max',
                      'assets/weather/Max_temp.json',
                      '${state.weather.tempMax?.celsius?.round()}°C',
                    ),
                    buildRow(
                      'Temp. Min',
                      'assets/weather/Min_temp.json',
                      '${state.weather.tempMin?.celsius?.round()}°C',
                    ),
                  ],
                ),
              ],
            );
          } else if (state is WeatherBlocFailure) {
            return Center(
              child: Text(
                'Error: ${state.error}',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }),
      ),
    );
  }
}
