import 'dart:math' as math;

/// Returns true if tile (x,y,z) is inside the bounding box defined by pointA & pointB.
/// pointA/pointB are (lat, lng) in degrees.
///
/// Notes:
/// - Uses Web Mercator (OSM XYZ).
/// - Handles bounding boxes crossing the International Date Line.
bool isTileInBlockedArea({
  required int x,
  required int y,
  required int z,
  required double aLat,
  required double aLng,
  required double bLat,
  required double bLng,
}) {
  // ---- helpers ----
  double clampLat(double lat) {
    const maxLat = 85.05112878;
    return lat.clamp(-maxLat, maxLat);
  }

  double normLng(double lng) {
    // normalize to [-180, 180)
    var v = lng;
    while (v >= 180) v -= 360;
    while (v < -180) v += 360;
    return v;
  }

  int lonToTileX(double lng, int z) {
    final n = 1 << z;
    final xx = ((lng + 180.0) / 360.0 * n).floor();
    return xx.clamp(0, n - 1);
  }

  int latToTileY(double lat, int z) {
    final n = 1 << z;
    final latRad = lat * math.pi / 180.0;
    final yy =
        ((1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) / 2.0 * n).floor();
    return yy.clamp(0, n - 1);
  }

  bool inRange(int v, int min, int max) => v >= min && v <= max;

  // ---- validate tile bounds ----
  final n = 1 << z;
  if (x < 0 || x >= n || y < 0 || y >= n) return false;
  if (z < 8) return false; // only block for zoom levels 8 and above

  // ---- normalize + clamp input points ----
  final lat1 = clampLat(aLat);
  final lat2 = clampLat(bLat);
  final lng1 = normLng(aLng);
  final lng2 = normLng(bLng);

  // ---- lat range (simple) ----
  final y1 = latToTileY(lat1, z);
  final y2 = latToTileY(lat2, z);
  final yMin = math.min(y1, y2);
  final yMax = math.max(y1, y2);
  final inY = inRange(y, yMin, yMax);

  if (!inY) return false;

  // ---- lng range (may cross dateline) ----
  // Detect dateline crossing by shortest-arc logic:
  // If the span between lng1 and lng2 is > 180 degrees, the box crosses the dateline.
  final diff = (lng1 - lng2).abs();
  final crossesDateLine = diff > 180.0;

  final x1 = lonToTileX(lng1, z);
  final x2 = lonToTileX(lng2, z);

  if (!crossesDateLine) {
    final xMin = math.min(x1, x2);
    final xMax = math.max(x1, x2);
    return inRange(x, xMin, xMax);
  } else {
    // Example: lng1=170, lng2=-170 => blocked area wraps around the edge
    // That means x is blocked if it's in [0..min(x1,x2)] OR [max(x1,x2)..n-1]
    final leftMax = math.min(x1, x2);
    final rightMin = math.max(x1, x2);
    return x <= leftMax || x >= rightMin;
  }
}
