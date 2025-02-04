import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

/// Determines greeting text based on the provided timezone offset.
String getLocalizedGreeting(Duration timezoneOffset) {
  final localTime = DateTime.now().toUtc().add(timezoneOffset);
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

/// Formats date-time based on the provided timezone offset.
String getFormattedDate(Duration timezoneOffset) {
  final localTime = DateTime.now().toUtc().add(timezoneOffset);
  return DateFormat("EEEE, d MMMM y | HH:mm").format(localTime);
}

/// Returns a Lottie weather icon based on the weather code and time.
Widget getWeatherIcon(int code) {
  final hour = DateTime.now().hour;
  final isNight = hour < 6 || hour >= 18;

  // Group 2xx: Thunderstorm
  if (code >= 200 && code < 300) {
    return Lottie.asset('assets/weather/Thunderstorm.json');

    // Group 3xx: Drizzle | Group 5xx: Rain
  } else if (code >= 300 && code < 600) {
    return Lottie.asset(isNight
        ? 'assets/weather/Raining_night.json'
        : 'assets/weather/Raining.json');

    // Group 6xx: Snow
  } else if (code >= 600 && code < 700) {
    return Lottie.asset(isNight
        ? 'assets/weather/Snow_night.json'
        : 'assets/weather/Snow_sunny.json');

    // Group 7xx: Atmosphere
  } else if (code >= 700 && code < 800) {
    return Lottie.asset('assets/weather/Mist.json');

    // Group 800: Clear
  } else if (code == 800) {
    return Lottie.asset(
        isNight ? 'assets/weather/Night.json' : 'assets/weather/Sunny.json');

    // Group 80x: Clouds
  } else if (code > 800 && code <= 804) {
    return Lottie.asset(isNight
        ? 'assets/weather/Cloudy_night.json'
        : 'assets/weather/Cloudy_sun.json');

    // Default.
  } else {
    return Lottie.asset(
        isNight ? 'assets/weather/Night.json' : 'assets/weather/Sunny.json');
  }
}
