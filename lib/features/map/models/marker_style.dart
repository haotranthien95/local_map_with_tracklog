import 'package:flutter/material.dart';

class MarkerStyle {
  final String key;
  final IconData icon;
  final String label;

  const MarkerStyle({
    required this.key,
    required this.icon,
    required this.label,
  });
}

class MarkerStyleCatalog {
  static const MarkerStyle defaultStyle = MarkerStyle(
    key: 'pin-default',
    icon: Icons.place,
    label: 'Pin',
  );

  static const List<MarkerStyle> all = [
    MarkerStyle(key: 'pin-default', icon: Icons.place, label: 'Pin'),
    MarkerStyle(key: 'flag', icon: Icons.flag, label: 'Flag'),
    MarkerStyle(key: 'star', icon: Icons.star, label: 'Star'),
    MarkerStyle(key: 'location', icon: Icons.location_on, label: 'Location'),
  ];

  static MarkerStyle byKey(String key) {
    return all.firstWhere((style) => style.key == key, orElse: () => defaultStyle);
  }
}
