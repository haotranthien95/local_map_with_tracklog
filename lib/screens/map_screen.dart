import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../models/map_style.dart';
import '../models/track.dart' as model;
import '../models/tracklog_metadata.dart';
import '../models/device_location.dart';
import '../services/tile_cache_service.dart';
import '../services/file_picker_service.dart';
import '../services/track_parser_service.dart';
import '../services/location_service.dart';
import '../services/tracklog_storage_service.dart';
import 'package:local_map_with_tracklog/features/map/widgets/map_view.dart';
import '../widgets/tracklog_dialogs.dart';
import 'tracklog_list_screen.dart';

/// Map screen with map display and storage warning
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TileCacheService _cacheService = TileCacheServiceImpl();
  final FilePickerService _filePickerService = FilePickerServiceImpl();
  final TrackParserService _trackParserService = TrackParserServiceImpl();
  final LocationService _locationService = LocationServiceImpl();
  final TracklogStorageService _storageService = TracklogStorageServiceImpl();
  final GlobalKey<MapViewState> _mapViewKey = GlobalKey<MapViewState>();

  MapStyle _currentMapStyle = MapStyle.standard;
  final List<model.Track> _tracks = [];
  List<TracklogMetadata> _tracklogMetadata = [];
  bool _hasCheckedStorageWarning = false;
  DeviceLocation? _currentLocation;
  StreamSubscription<DeviceLocation?>? _locationSubscription;
  bool firstTime = false;

  @override
  void initState() {
    super.initState();
    _loadPersistedTracklogs();
    _checkStorageWarning();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    // Request location permission
    final hasPermission = await _locationService.requestPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Subscribe to location updates
    _locationSubscription = _locationService.locationStream.listen(
      (location) {
        if (mounted && location != null) {
          setState(() {
            _currentLocation = location;
          });
          if (!firstTime) {
            firstTime = true;
            // Center map on initial location
            _mapViewKey.currentState?.centerOnLocation(location.toLatLng());
          }
        }
      },
    );
  }

  /// Load tracklogs from persistent storage
  Future<void> _loadPersistedTracklogs() async {
    try {
      // Load metadata
      _tracklogMetadata = await _storageService.loadAllMetadata();

      // Load visible tracks
      for (final metadata in _tracklogMetadata.where((m) => m.isVisible)) {
        try {
          final track = await _storageService.loadTrack(metadata.id);
          setState(() {
            _tracks.add(track);
          });
        } catch (e) {
          // Log individual track loading failure but continue with others
          print('Error loading track ${metadata.name}: $e');
        }
      }
    } catch (e) {
      print('Error loading tracklogs: $e');
      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load saved tracklogs'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _locationService.dispose();
    super.dispose();
  }

  Future<void> _checkStorageWarning() async {
    if (_hasCheckedStorageWarning) return;

    final shouldWarn = await _cacheService.shouldShowStorageWarning();
    if (shouldWarn && mounted) {
      _showStorageWarningDialog();
    }

    _hasCheckedStorageWarning = true;
  }

  void _showStorageWarningDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Warning'),
        content: const Text(
          'Your map cache is using a significant amount of storage space (≥80% threshold). '
          'Would you like to clear some old tiles to free up space?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _clearCache();
            },
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    await _cacheService.clearCache();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared successfully')),
      );
      setState(() {
        _hasCheckedStorageWarning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Map with Track Log'),
        actions: [
          // Tracklog list button
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _openTracklogList,
          ),
          // Storage info button
          IconButton(
            icon: const Icon(Icons.storage),
            onPressed: _showStorageInfo,
          ),
          // Map style selector
          PopupMenuButton<MapStyle>(
            icon: const Icon(Icons.layers),
            onSelected: (style) {
              setState(() {
                _currentMapStyle = style;
              });
            },
            itemBuilder: (context) {
              return MapStyle.all.map((style) {
                return PopupMenuItem(
                  value: style,
                  child: ListTile(
                    title: Text(style.name),
                    trailing: _currentMapStyle.id == style.id ? const Icon(Icons.check) : null,
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: MapView(
        key: _mapViewKey,
        mapStyle: _currentMapStyle,
        tracks: _tracks,
        initialCenter:
            _currentLocation?.toLatLng() ?? const LatLng(11.551356596401469, 108.52344619476199),
        initialZoom: 13.0,
        deviceLocation: _currentLocation,
        showLocationIndicator: true,
        onMapMoved: (bounds) {
          // Map moved, tiles will be cached automatically by cached_network_image
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Center on location button
          FloatingActionButton(
            heroTag: 'to_north',
            onPressed: () {
              _mapViewKey.currentState?.toNorth();
            },
            child: const Icon(Icons.north_sharp),
          ),
          const SizedBox(height: 16),
          if (_currentLocation != null)
            FloatingActionButton(
              heroTag: 'center_location',
              onPressed: () {
                _mapViewKey.currentState?.centerOnLocation(_currentLocation!.toLatLng());
              },
              child: const Icon(Icons.my_location),
            ),
          if (_currentLocation != null) const SizedBox(height: 16),
          // Import track button
          FloatingActionButton(
            heroTag: 'import',
            onPressed: _importTrack,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          // Refresh storage warning check
          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: () {
              setState(() {
                _hasCheckedStorageWarning = false;
              });
              _checkStorageWarning();
            },
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  /// Import a track file (GPX, KML, etc.)
  Future<void> _importTrack() async {
    try {
      // Pick a track file
      final file = await _filePickerService.pickTrackFile([
        'gpx',
        'kml',
        'kmz',
        'geojson',
        'json',
        'fit',
        'tcx',
        'csv',
        'nmea',
        'txt',
      ]);

      if (file == null) {
        return; // User cancelled
      }

      // Show name dialog before parsing
      if (!mounted) return;
      final name = await showNameDialog(context);

      if (name == null) {
        // User cancelled, don't import
        return;
      }

      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importing track...')),
      );

      // Parse the track file
      final track = await _trackParserService.parseTrackFile(file);

      // Create new track with user-entered name and default blue color
      final namedTrack = model.Track(
        id: track.id,
        name: name,
        coordinates: track.coordinates,
        importedFrom: track.importedFrom,
        format: track.format,
        importedAt: track.importedAt,
        color: const Color(0xFF2196F3), // Default blue color
        isVisible: true,
        metadata: track.metadata,
      );

      // Save to persistent storage
      await _storageService.saveTracklog(namedTrack);

      // Add track to list and update UI
      setState(() {
        _tracks.add(namedTrack);
        _tracklogMetadata.add(TracklogMetadata.fromTrack(namedTrack));
      });

      // Auto-zoom to track bounds
      _mapViewKey.currentState?.fitBounds(namedTrack.bounds);

      // Show success message with custom name
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Track "$name" imported successfully'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _tracks.remove(namedTrack);
              });
            },
          ),
        ),
      );
    } catch (e) {
      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import track: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Open tracklog list screen
  Future<void> _openTracklogList() async {
    final selectedId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => TracklogListScreen(
          tracklogs: _tracklogMetadata,
          onUpdateMetadata: (metadata) async {
            try {
              // Update storage
              await _storageService.updateMetadata(metadata);

              // Update local metadata list
              setState(() {
                final index = _tracklogMetadata.indexWhere((m) => m.id == metadata.id);
                if (index != -1) {
                  _tracklogMetadata[index] = metadata;
                }
              });

              // Update track in memory if loaded
              final trackIndex = _tracks.indexWhere((t) => t.id == metadata.id);
              if (trackIndex != -1) {
                final track = _tracks[trackIndex];
                final updatedTrack = model.Track(
                  id: track.id,
                  name: metadata.name,
                  color: metadata.color,
                  isVisible: metadata.isVisible,
                  coordinates: track.coordinates,
                  importedFrom: track.importedFrom,
                  format: track.format,
                  importedAt: track.importedAt,
                );

                setState(() {
                  _tracks[trackIndex] = updatedTrack;
                });
              }
            } catch (e) {
              // Show error message if update fails
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update tracklog: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          onDeleteTracklog: (id) async {
            try {
              // Delete from storage
              await _storageService.deleteTracklog(id);

              // Remove from local lists
              setState(() {
                _tracklogMetadata.removeWhere((m) => m.id == id);
                _tracks.removeWhere((t) => t.id == id);
              });
            } catch (e) {
              // Show error message if deletion fails
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete tracklog: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );

    // User tapped a tracklog - center map on it
    if (selectedId != null && mounted) {
      model.Track? track;

      if (_tracks.any((t) => t.id == selectedId)) {
        track = _tracks.firstWhere((t) => t.id == selectedId);
      } else {
        // Load track if not in memory
        track = await _storageService.loadTrack(selectedId);
        setState(() {
          _tracks.add(track!);
        });
      }

      _mapViewKey.currentState?.fitBounds(track.bounds);
    }
  }

  Future<void> _showStorageInfo() async {
    final cacheInfo = await _cacheService.getCacheInfo();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cache Storage Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Size: ${cacheInfo.totalSizeMB.toStringAsFixed(2)} MB'),
            Text('Tile Count: ${cacheInfo.tileCount}'),
            if (cacheInfo.storageUsagePercent != null)
              Text(
                'Storage Usage: ${cacheInfo.storageUsagePercent!.toStringAsFixed(1)}%',
              ),
            const SizedBox(height: 16),
            Text(
              cacheInfo.shouldShowWarning
                  ? '⚠️ Storage warning threshold reached'
                  : '✓ Storage usage is normal',
              style: TextStyle(
                color: cacheInfo.shouldShowWarning ? Colors.orange : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (cacheInfo.tileCount > 0)
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _clearCache();
              },
              child: const Text('Clear Cache'),
            ),
        ],
      ),
    );
  }
}
