import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Determines greeting text based on the current time.
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

/// Returns a Lottie weather icon based on the weather code and time.
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
    return Lottie.asset(isNight
        ? 'assets/weather/Night.json'
        : 'assets/weather/Sunny.json');
  } else if (code > 800 && code <= 804) {
    return Lottie.asset(isNight
        ? 'assets/weather/Cloudy_night.json'
        : 'assets/weather/Cloudy_sun.json');
  } else {
    return Lottie.asset(isNight
        ? 'assets/weather/Night.json'
        : 'assets/weather/Sunny.json');
  }
}
