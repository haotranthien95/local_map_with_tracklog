/// Type of location being displayed on the map
enum LocationType {
  /// Current GPS location from device
  current,

  /// Last known cached location when GPS unavailable
  lastKnown,

  /// Default fallback location (Ho Chi Minh City)
  defaultLocation,
}
