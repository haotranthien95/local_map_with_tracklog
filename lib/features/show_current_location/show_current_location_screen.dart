import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'models/location_data.dart';
import 'services/location_service.dart';
import 'constants/default_location.dart';
import 'widgets/location_banner.dart';

/// Screen that shows current user location or default Ho Chi Minh City location on map
class ShowCurrentLocationScreen extends StatefulWidget {
  const ShowCurrentLocationScreen({super.key});

  @override
  State<ShowCurrentLocationScreen> createState() => _ShowCurrentLocationScreenState();
}

class _ShowCurrentLocationScreenState extends State<ShowCurrentLocationScreen> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();

  LocationData? _currentLocationData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  /// Initialize location on screen load
  Future<void> _initializeLocation() async {
    setState(() => _isLoading = true);

    final locationData = await _locationService.getBestAvailableLocation();

    if (mounted) {
      setState(() {
        _currentLocationData = locationData;
        _isLoading = false;
      });

      // Animate map to determined location with smooth transition
      _mapController.move(
        locationData.coordinates,
        DefaultLocationConstants.defaultZoom,
      );
    }
  }

  /// Handle manual location refresh with smooth animation
  Future<void> _refreshLocation() async {
    final locationData = await _locationService.getBestAvailableLocation();

    if (mounted) {
      setState(() {
        _currentLocationData = locationData;
      });

      // Animate to new location smoothly
      _mapController.move(
        locationData.coordinates,
        DefaultLocationConstants.defaultZoom,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLocation,
            tooltip: 'Refresh location',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Map display
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        _currentLocationData?.coordinates ?? DefaultLocationConstants.coordinates,
                    initialZoom: DefaultLocationConstants.defaultZoom,
                    minZoom: 5,
                    maxZoom: 18,
                  ),
                  children: [
                    // Tile layer (OpenStreetMap)
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.local_map_with_tracklog',
                      maxZoom: 19,
                    ),

                    // Marker layer
                    if (_currentLocationData != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentLocationData!.coordinates,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_on,
                              size: 40,
                              color:
                                  _currentLocationData!.isUserLocation ? Colors.blue : Colors.red,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Location banner at bottom
                if (_currentLocationData != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: LocationBanner(
                      message: _currentLocationData!.bannerMessage,
                      isUserLocation: _currentLocationData!.isUserLocation,
                    ),
                  ),
              ],
            ),
    );
  }
}
