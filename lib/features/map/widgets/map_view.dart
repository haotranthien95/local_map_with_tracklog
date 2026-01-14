import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';

import 'package:local_map_with_tracklog/features/map/data/marker_store.dart';
import 'package:local_map_with_tracklog/features/map/models/marker.dart';
import 'package:local_map_with_tracklog/features/map/models/marker_style.dart';
import 'package:local_map_with_tracklog/features/map/widgets/marker_bottom_sheet.dart';
import 'package:local_map_with_tracklog/models/device_location.dart';
import 'package:local_map_with_tracklog/models/map_style.dart';
import 'package:local_map_with_tracklog/models/track.dart' as model;
import 'package:local_map_with_tracklog/utils/extension.dart';
import 'package:local_map_with_tracklog/utils/pair.dart';
import 'package:local_map_with_tracklog/utils/prevent_load_map.dart';
import 'package:local_map_with_tracklog/widgets/live_compass.dart';

class MapView extends StatefulWidget {
  final MapStyle mapStyle;
  final List<model.Track> tracks;
  final LatLng? initialCenter;
  final double initialZoom;
  final ValueChanged<model.LatLngBounds>? onMapMoved;
  final DeviceLocation? deviceLocation;
  final bool showLocationIndicator;
  final bool showMapInfo;
  final String? markerUserId;

  const MapView({
    super.key,
    required this.mapStyle,
    this.tracks = const [],
    this.initialCenter,
    this.initialZoom = 13.0,
    this.onMapMoved,
    this.deviceLocation,
    this.showLocationIndicator = false,
    this.showMapInfo = true,
    this.markerUserId,
  });

  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final fm.MapController _mapController = fm.MapController();
  final MarkerStore _markerStore = MarkerStore();

  late LatLng _currentCenter;
  late double _currentZoom;
  List<MapMarker> _markers = [];
  bool _loadingMarkers = false;

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialCenter ?? const LatLng(51.5, -0.09);
    _currentZoom = widget.initialZoom;
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    setState(() => _loadingMarkers = true);
    final loaded = await _markerStore.loadMarkers(userId: widget.markerUserId);
    if (!mounted) return;
    setState(() {
      _markers = loaded;
      _loadingMarkers = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        fm.FlutterMap(
          mapController: _mapController,
          options: fm.MapOptions(
            initialCenter: widget.initialCenter ?? const LatLng(51.5, -0.09),
            initialZoom: widget.initialZoom,
            maxZoom: 17,
            minZoom: 0,
            interactionOptions: const fm.InteractionOptions(),
            onPositionChanged: (position, hasGesture) {
              setState(() {
                _currentCenter = position.center ?? _currentCenter;
                _currentZoom = position.zoom ?? _currentZoom;
              });

              if (hasGesture && widget.onMapMoved != null) {
                final bounds = _mapController.camera.visibleBounds;
                widget.onMapMoved!(model.LatLngBounds(
                  north: bounds.north,
                  south: bounds.south,
                  east: bounds.east,
                  west: bounds.west,
                ));
              }
            },
            onLongPress: (_, latLng) => _handleLongPress(latLng),
          ),
          children: [
            fm.TileLayer(
              urlTemplate: widget.mapStyle.tileUrlTemplate,
              tileProvider: CachedNetworkTileProvider(),
              userAgentPackageName: 'com.example.local_map_with_tracklog',
            ),
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
            if (_markers.isNotEmpty)
              fm.MarkerLayer(
                markers: _markers.map((marker) {
                  final style = MarkerStyleCatalog.byKey(marker.iconKey);
                  final color = _colorFromHex(marker.colorHex);
                  return fm.Marker(
                    point: marker.toLatLng(),
                    width: 200,
                    height: 64,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(style.icon, color: color, size: 32),
                        Text(
                          marker.name,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 11, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                  );
                }).toList(),
                rotate: true,
              ),
            if (widget.showLocationIndicator && widget.deviceLocation != null)
              fm.MarkerLayer(
                markers: [
                  fm.Marker(
                    point: widget.deviceLocation!.toLatLng(),
                    width: 40,
                    height: 40,
                    child: LiveCompass(
                      size: 40,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ringColor: Colors.transparent,
                      northColor: Theme.of(context).colorScheme.error,
                      textColor: Colors.white70,
                      isActive: widget.deviceLocation?.isActive ?? false,
                    ),
                  ),
                ],
              ),
            fm.RichAttributionWidget(
              attributions: [
                fm.TextSourceAttribution(widget.mapStyle.attribution),
              ],
            ),
          ],
        ),
        if (widget.showMapInfo)
          Positioned(
            left: 64,
            bottom: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Text(
                'Type: ${widget.mapStyle.name}\n'
                'Zoom: ${_currentZoom.toStringAsFixed(1)}\n'
                'Lat: ${_currentCenter.latitude.toStringAsFixed(4)}°\n'
                'Lng: ${_currentCenter.longitude.toStringAsFixed(4)}°',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
              ),
            ),
          ),
        if (widget.showMapInfo)
          Positioned(
            left: 8,
            bottom: 8,
            child: LiveCompass(
              size: 52,
              backgroundColor: Colors.black.withOpacity(0.7),
              ringColor: Colors.grey.shade800,
              northColor: Colors.red.shade400,
              textColor: Colors.white70,
            ),
          ),
        if (_loadingMarkers)
          const Positioned(
            right: 12,
            bottom: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  Future<void> _handleLongPress(LatLng latLng) async {
    final marker = await showAddMarkerBottomSheet(
      context: context,
      position: latLng,
      styles: MarkerStyleCatalog.all,
      defaultStyle: MarkerStyleCatalog.defaultStyle,
      defaultColor: const Color(0xFFE53935),
    );

    if (marker == null) return;

    setState(() {
      _markers = [..._markers, marker];
    });
    await _markerStore.saveMarkers(_markers, userId: widget.markerUserId);
  }

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

  void centerOnLocation(LatLng location) {
    _mapController.move(location, _mapController.camera.zoom);
  }

  void zoomIn() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
  }

  void zoomOut() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
  }

  void toNorth() {
    _mapController.rotate(0.0);
  }

  Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) {
      buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
    } else if (hex.length == 9) {
      buffer.write(hex.replaceFirst('#', ''));
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class CachedNetworkTileProvider extends fm.TileProvider {
  @override
  ImageProvider getImage(fm.TileCoordinates coordinates, fm.TileLayer options) {
    if (isTileInBlockedArea(
        x: coordinates.x,
        y: coordinates.y,
        z: coordinates.z,
        aLat: 18.87835787992078,
        aLng: 109.46651797921687,
        bLat: 7.263019296696502,
        bLng: 116.67536515933477)) {
      return const AssetImage('assets/tiles/blocked_tile.png');
    }
    final templeteCheck = checkTemplete(options.urlTemplate!, coordinates);
    if (templeteCheck != null) {
      return AssetImage(
          'assets/maps/${MapStyle.getMapIdFromUrlTemplate(urlTemplate: options.urlTemplate)}/${templeteCheck.first}/${templeteCheck.second}/${templeteCheck.third}.png');
    }
    final url = options.urlTemplate!
        .replaceAll('{z}', coordinates.z.toString())
        .replaceAll('{x}', coordinates.x.toString())
        .replaceAll('{y}', coordinates.y.toString());

    return CachedNetworkImageProvider(url);
  }

  Tripple<int, int, int>? checkTemplete(String urlTemplate, fm.TileCoordinates coordinates) {
    if (urlTemplate == MapStyle.standard.tileUrlTemplate) {
      return markerZoomNormalLimits.any((tripple) => coordinates.matchWith(tripple))
          ? Tripple(coordinates.z, coordinates.x, coordinates.y)
          : null;
    } else if (urlTemplate == MapStyle.terrain.tileUrlTemplate) {
      return markerZoomTerrainLimits.any((tripple) => coordinates.matchWith(tripple))
          ? Tripple(coordinates.z, coordinates.x, coordinates.y)
          : null;
    } else {
      return null;
    }
  }
}

const List<Tripple<int, int, int>> markerZoomNormalLimits = [
  Tripple(0, 0, 0),
  Tripple(1, 1, 0),
  Tripple(2, 3, 1),
  Tripple(3, 6, 3),
  Tripple(4, 13, 7),
  Tripple(5, 25, 14),
  Tripple(5, 26, 14),
  Tripple(5, 25, 15),
  Tripple(5, 26, 15),
  Tripple(6, 51, 28),
  Tripple(6, 52, 28),
  Tripple(6, 51, 29),
  Tripple(6, 52, 29),
  Tripple(6, 52, 30),
  Tripple(7, 103, 57),
  Tripple(7, 104, 60),
  Tripple(8, 207, 115),
  Tripple(8, 207, 116),
  Tripple(8, 208, 121),
  Tripple(5, 27, 15),
];

const List<Tripple<int, int, int>> markerZoomTerrainLimits = [
  Tripple(0, 0, 0),
  Tripple(7, 104, 58),
  Tripple(7, 104, 57),
  Tripple(7, 103, 58),
  Tripple(7, 103, 57),
  Tripple(7, 103, 60),
  Tripple(7, 104, 60),
  Tripple(6, 51, 28),
  Tripple(6, 51, 29),
  Tripple(6, 52, 28),
  Tripple(6, 52, 29),
  Tripple(6, 52, 30),
  Tripple(1, 1, 0),
  Tripple(4, 12, 7),
  Tripple(4, 13, 7),
  Tripple(3, 6, 3),
  Tripple(2, 3, 1),
  Tripple(5, 26, 14),
  Tripple(5, 26, 15),
  Tripple(5, 25, 14),
  Tripple(5, 25, 15),
];
