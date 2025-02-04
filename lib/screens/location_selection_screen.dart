import 'package:flutter/material.dart';
import '../helpers/shared_prefs_helper.dart';
import '../services/location_service.dart';
import '../widgets/location_list_widget.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _savedLocations = [];
  Map<String, dynamic>? _currentLocation;
  Map<String, dynamic>? _previewedLocation;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAndSaveCurrentLocation();
    _loadSavedLocations();
  }

  Future<void> _fetchAndSaveCurrentLocation() async {
    try {
      final geocodedLocation = await LocationService.fetchCurrentLocation();
      setState(() {
        _currentLocation = geocodedLocation;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch current location: $e';
      });
    }
  }

  Future<void> _loadSavedLocations() async {
    final savedLocations = await SharedPrefsHelper.loadSavedLocations();
    setState(() {
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
      _errorMessage = '';
    });

    try {
      final result = await LocationService.searchLocation(query);
      setState(() {
        _isLoading = false;
        _previewedLocation = result;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Location not found: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Select Location"),
        backgroundColor: Colors.white10,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search for a location...",
                suffixIcon: _isLoading
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () =>
                            _searchLocation(_searchController.text.trim()),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            // Handle Errors
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 30),

            // Expandable Scrollable List
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Previewed Location
                    if (_previewedLocation != null)
                      LocationList(
                        title: "Previewed Location",
                        locations: [_previewedLocation!],
                        onSelect: (loc) => Navigator.pop(context, loc),
                        onRemove: (_) {},
                        showSaveButton: true,
                        onSave: (loc) async {
                          await SharedPrefsHelper.saveLocation(loc);
                          _loadSavedLocations();
                        },
                      ),

                    const SizedBox(height: 20),

                    // Saved Locations
                    if (_savedLocations.isNotEmpty)
                      LocationList(
                        title: "Saved Locations",
                        locations: _savedLocations,
                        onSelect: (loc) => Navigator.pop(context, loc),
                        onRemove: (loc) async {
                          await SharedPrefsHelper.removeLocation(loc);
                          _loadSavedLocations();
                        },
                      ),

                    const SizedBox(height: 20),

                    // Current Location
                    if (_currentLocation != null)
                      LocationList(
                        title: "Current Location",
                        locations: [_currentLocation!],
                        onSelect: (loc) => Navigator.pop(context, loc),
                        onRemove:
                            (_) {}, // Keep empty since current location shouldn't be removable
                        showRemoveButton: false,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
