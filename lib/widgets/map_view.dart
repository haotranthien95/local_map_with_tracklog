import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/map_style.dart';
import '../models/track.dart' as model;

/// Main map display widget with flutter_map integration
class MapView extends StatefulWidget {
  final MapStyle mapStyle;
  final List<model.Track> tracks;
  final LatLng? initialCenter;
  final double initialZoom;
  final ValueChanged<model.LatLngBounds>? onMapMoved;

  const MapView({
    super.key,
    required this.mapStyle,
    this.tracks = const [],
    this.initialCenter,
    this.initialZoom = 13.0,
    this.onMapMoved,
  });

  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final fm.MapController _mapController = fm.MapController();

  @override
  Widget build(BuildContext context) {
    return fm.FlutterMap(
      mapController: _mapController,
      options: fm.MapOptions(
        initialCenter: widget.initialCenter ?? const LatLng(51.5, -0.09),
        initialZoom: widget.initialZoom,
        onPositionChanged: (position, hasGesture) {
          if (hasGesture && widget.onMapMoved != null) {
            // Calculate visible bounds when map moves
            final bounds = _mapController.camera.visibleBounds;
            widget.onMapMoved!(model.LatLngBounds(
              north: bounds.north,
              south: bounds.south,
              east: bounds.east,
              west: bounds.west,
            ));
          }
        },
      ),
      children: [
        // Tile layer with network caching via cached_network_image
        fm.TileLayer(
          urlTemplate: widget.mapStyle.tileUrlTemplate,
          tileProvider: CachedNetworkTileProvider(),
          userAgentPackageName: 'com.example.local_map_with_tracklog',
        ),

        // Track overlays
        if (widget.tracks.isNotEmpty)
          fm.PolylineLayer(
            polylines: widget.tracks.map((track) {
              return fm.Polyline(
                points: track.coordinates.map((point) => point.toLatLng()).toList(),
                strokeWidth: 3.0,
                color: track.color,
              );
            }).toList(),
          ),

        // Attribution layer
        fm.RichAttributionWidget(
          attributions: [
            fm.TextSourceAttribution(widget.mapStyle.attribution),
          ],
        ),
      ],
    );
  }

  /// Move map to show all tracks
  void fitBounds(model.LatLngBounds bounds, {double padding = 50.0}) {
    final latLngBounds = fm.LatLngBounds(
      LatLng(bounds.south, bounds.west),
      LatLng(bounds.north, bounds.east),
    );

    _mapController.fitCamera(
      fm.CameraFit.bounds(
        bounds: latLngBounds,
        padding: EdgeInsets.all(padding),
      ),
    );
  }
}

/// Tile provider that uses cached_network_image for caching
class CachedNetworkTileProvider extends fm.TileProvider {
  @override
  ImageProvider getImage(fm.TileCoordinates coordinates, fm.TileLayer options) {
    // Build tile URL from template
    final url = options.urlTemplate!
        .replaceAll('{z}', coordinates.z.toString())
        .replaceAll('{x}', coordinates.x.toString())
        .replaceAll('{y}', coordinates.y.toString());
    return CachedNetworkImageProvider(url);
  }
}
