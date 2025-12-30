import 'package:latlong2/latlong.dart';

class MapMarker {
  final String id;
  final double lat;
  final double lng;
  final String name;
  final String iconKey;
  final String colorHex;
  final int createdAt;
  final int updatedAt;

  const MapMarker({
    required this.id,
    required this.lat,
    required this.lng,
    required this.name,
    required this.iconKey,
    required this.colorHex,
    required this.createdAt,
    required this.updatedAt,
  });

  LatLng toLatLng() => LatLng(lat, lng);

  Map<String, dynamic> toJson() => {
        'id': id,
        'lat': lat,
        'lng': lng,
        'name': name,
        'iconKey': iconKey,
        'colorHex': colorHex,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory MapMarker.fromJson(Map<String, dynamic> json) {
    return MapMarker(
      id: json['id'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      name: json['name'] as String,
      iconKey: json['iconKey'] as String,
      colorHex: json['colorHex'] as String,
      createdAt: (json['createdAt'] as num).toInt(),
      updatedAt: (json['updatedAt'] as num).toInt(),
    );
  }

  MapMarker copyWith({
    String? name,
    String? iconKey,
    String? colorHex,
    int? updatedAt,
  }) {
    return MapMarker(
      id: id,
      lat: lat,
      lng: lng,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
