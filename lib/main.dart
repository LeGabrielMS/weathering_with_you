import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import 'bloc/weather_bloc.dart';
import 'screens/home_screen.dart';
import 'utils/location_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late Future<Position> _positionFuture;
  bool _locationPreviouslyOff = false; // Track if location was previously off

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _positionFuture = LocationService.determinePosition();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // Check if location services were previously off
      if (_locationPreviouslyOff) {
        final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
        if (isLocationEnabled) {
          setState(() {
            _positionFuture = LocationService.determinePosition();
            _locationPreviouslyOff = false; // Reset the flag
          });
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _positionFuture = LocationService.determinePosition();
              });
            },
            child: const Text('Retry'),
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
          future: _positionFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snap.hasError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showErrorDialog(snap.error.toString());
              });

              // Mark location as previously off
              _locationPreviouslyOff = true;

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
