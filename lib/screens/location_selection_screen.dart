import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/my_data.dart';

import '../helpers/shared_prefs_helper.dart';
import '../utils/geocoding_service.dart';
import '../utils/location_service.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _savedLocations = [];
  Map<String, dynamic>? _currentLocation; // For the pinned current location
  Map<String, dynamic>? _previewedLocation; // For previewing search results
  bool _isLoading = false; // Show loading spinner for search
  String _errorMessage = ''; // For handling errors

  @override
  void initState() {
    super.initState();
    _fetchAndSaveCurrentLocation(); // Fetch current location
    _loadSavedLocations(); // Load saved locations
  }

  Future<void> _fetchAndSaveCurrentLocation() async {
    try {
      final position = await LocationService.determinePosition();
      final geocodedLocation =
          await GeocodingService(apiKey).getCoordinatesFromLatLon(
        position.latitude,
        position.longitude,
      );

      // Update the current location
      setState(() {
        _currentLocation = geocodedLocation;
      });

      // Add to saved locations if not already present
      SharedPrefsHelper.saveLocation(geocodedLocation);
      _loadSavedLocations();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch current location: $e';
      });
    }
  }

  Future<void> _loadSavedLocations() async {
    final savedLocations = await SharedPrefsHelper.loadSavedLocations();
    setState(() {
      // Ensure current location is always pinned at the top
      _savedLocations = savedLocations
          .where((loc) =>
              loc['lat'] != _currentLocation?['lat'] &&
              loc['lon'] != _currentLocation?['lon'])
          .toList();
    });
  }

  Future<void> _searchLocation(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear previous error messages
    });

    try {
      final result = await GeocodingService(apiKey).getCoordinates(query);
      setState(() {
        _isLoading = false;
        _previewedLocation = result; // Preview the first result
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Location not found: $e';
      });
    }
  }

  Future<void> _saveLocation(Map<String, dynamic> location) async {
    await SharedPrefsHelper.saveLocation(location);
    _loadSavedLocations(); // Reload saved locations to reflect changes
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location saved!')),
      );
    }
  }

  Future<void> _removeLocation(Map<String, dynamic> location) async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocations = prefs.getStringList('saved_locations') ?? [];

    // Remove the location from SharedPreferences
    final updatedLocations = savedLocations.where((loc) {
      final parts = loc.split(',');
      return !(parts[0] == location['name'] &&
          parts[1] == location['lat'].toString() &&
          parts[2] == location['lon'].toString());
    }).toList();

    await prefs.setStringList('saved_locations', updatedLocations);
    _loadSavedLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Select Location",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search for a location...",
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[900],
                suffixIcon: _isLoading
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () {
                          _searchLocation(_searchController.text.trim());
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Error Message
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),

            // Current Location (Pinned)
            if (_currentLocation != null) ...[
              const Text(
                "Current Location:",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListTile(
                title: Text(
                  _currentLocation!['name'],
                  style: const TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context, _currentLocation);
                },
              ),
              const Divider(color: Colors.grey),
            ],

            // Saved Locations
            if (_savedLocations.isNotEmpty) ...[
              const Text(
                "Saved Locations:",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _savedLocations.length,
                  itemBuilder: (context, index) {
                    final location = _savedLocations[index];
                    return ListTile(
                      title: Text(
                        location['name'],
                        style: const TextStyle(color: Colors.black),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeLocation(location),
                      ),
                      onTap: () {
                        Navigator.pop(context, location);
                      },
                    );
                  },
                ),
              ),
            ],

            // Previewed Location
            if (_previewedLocation != null) ...[
              const Divider(color: Colors.grey),
              const Text(
                "Previewed Location:",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListTile(
                title: Text(
                  _previewedLocation!['name'],
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    _saveLocation(_previewedLocation!);
                  },
                  child: const Text("Save"),
                ),
                onTap: () {
                  Navigator.pop(context, _previewedLocation);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
