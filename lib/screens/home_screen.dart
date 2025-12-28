import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/map_style.dart';
import '../models/track.dart' as model;
import '../services/tile_cache_service.dart';
import '../services/file_picker_service.dart';
import '../services/track_parser_service.dart';
import '../widgets/map_view.dart';

/// Main home screen with map display and storage warning
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TileCacheService _cacheService = TileCacheServiceImpl();
  final FilePickerService _filePickerService = FilePickerServiceImpl();
  final TrackParserService _trackParserService = TrackParserServiceImpl();
  final GlobalKey<MapViewState> _mapViewKey = GlobalKey<MapViewState>();

  MapStyle _currentMapStyle = MapStyle.standard;
  final List<model.Track> _tracks = [];
  bool _hasCheckedStorageWarning = false;

  @override
  void initState() {
    super.initState();
    _checkStorageWarning();
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
        initialCenter: const LatLng(51.5, -0.09), // Default to London
        initialZoom: 13.0,
        onMapMoved: (bounds) {
          // Map moved, tiles will be cached automatically by cached_network_image
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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

      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importing track...')),
      );

      // Parse the track file
      final track = await _trackParserService.parseTrackFile(file);

      // Add track to list and update UI
      setState(() {
        _tracks.add(track);
      });

      // Auto-zoom to track bounds
      _mapViewKey.currentState?.fitBounds(track.bounds);

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Track "${track.name}" imported successfully'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _tracks.remove(track);
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
