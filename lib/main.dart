import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import 'bloc/weather_bloc.dart';
import 'screens/home_screen.dart';
import 'utils/location_service.dart'; // Import the utility class

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder<Position>(
          future: LocationService.determinePosition(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snap.hasError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showErrorDialog(context, snap.error.toString());
              });
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Please enable location services.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              );
            } else if (snap.hasData) {
              final position = snap.data!;
              context.read<WeatherBloc>().add(FetchWeather(position: position));
              return const HomeScreen();
            } else {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Unexpected error occurred.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
