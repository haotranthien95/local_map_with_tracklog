/// Represents a map tile source/style configuration
class MapStyle {
  final String id;
  final String name;
  final String tileUrlTemplate;
  final String attribution;

  const MapStyle({
    required this.id,
    required this.name,
    required this.tileUrlTemplate,
    required this.attribution,
  });

  /// Standard OpenStreetMap style
  static const standard = MapStyle(
    id: 'standard',
    name: 'Standard',
    tileUrlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: '© OpenStreetMap contributors',
  );

  /// Satellite/Imagery style (using ESRI World Imagery)
  static const satellite = MapStyle(
    id: 'satellite',
    name: 'Satellite',
    tileUrlTemplate:
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    attribution: '© ESRI',
  );

  /// Terrain/Topographic style (using OpenTopoMap)
  static const terrain = MapStyle(
    id: 'terrain',
    name: 'Terrain',
    tileUrlTemplate: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
    attribution: '© OpenTopoMap contributors',
  );

  /// List of all predefined map styles
  static const List<MapStyle> all = [standard, satellite, terrain];

  /// Get a map style by ID, returns standard if not found
  static MapStyle getById(String id) {
    return all.firstWhere(
      (style) => style.id == id,
      orElse: () => standard,
    );
  }

  static String getMapIdFromUrlTemplate({String? urlTemplate}) {
    for (var style in all) {
      if (style.tileUrlTemplate == urlTemplate) {
        return style.id;
      }
    }
    return standard.id;
  }
}
