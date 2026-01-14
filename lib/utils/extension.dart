import 'package:flutter_map/flutter_map.dart';
import 'package:local_map_with_tracklog/utils/pair.dart';

extension CoordinatesExtension on TileCoordinates {
  bool matchWith(Tripple<int, int, int> tripple) {
    return x == tripple.second && y == tripple.third && z == tripple.first;
  }
}
